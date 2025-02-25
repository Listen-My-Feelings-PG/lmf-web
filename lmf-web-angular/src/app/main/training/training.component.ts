import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { Playlist, Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';
import { SongService } from '../../_services/song.service';
import { TensorflowService } from '../../_services/tensorflow.service';
import { ChipModule } from 'primeng/chip';
import { BadgeModule } from 'primeng/badge';
import { ListboxModule } from 'primeng/listbox';
import { FormsModule } from '@angular/forms';
import { TableModule } from 'primeng/table';
import { ButtonGroupModule } from 'primeng/buttongroup';
import { PlayerService } from '../../_services/player.service';
import { InputSwitchModule } from 'primeng/inputswitch';
import { DialogModule } from 'primeng/dialog';
import { TooltipModule } from 'primeng/tooltip';

@Component({
  selector: 'app-training',
  standalone: true,
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule,
    ChipModule,
    BadgeModule,
    ListboxModule,
    FormsModule,
    TableModule,
    ButtonGroupModule,
    InputSwitchModule,
    DialogModule,
    TooltipModule
  ],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  playlists: {
    list: Array<Playlist>,
    selected: Playlist | null,
    default: Playlist | null,
    loaded: boolean
  }
  idSongPlaying: number;
  playlistModal: {
    visible: boolean,
    name: string,
    mode: 'new' | 'edit'
  }
  rating: {
    stars: Array<number>,
    blocked: boolean
  }

  constructor(
    private http: HttpService,
    public songService: SongService,
    private tsService: TensorflowService,
    private playerService: PlayerService
  ) {
    this.playlistModal = {
      visible: false,
      name: '',
      mode: 'new'
    }
    this.idSongPlaying = 0;
    this.playlists = {
      list: [],
      selected: null,
      default: null,
      loaded: false
    }
    this.rating = {
      stars: [0, 1, 2],
      blocked: false
    }
  }

  async ngOnInit(): Promise<void> {
    this.playerService.getPlayerEmmitterIdSong().subscribe({ next: (id) => this.idSongPlaying = id });
    //Primero se deben cargar los pesos del modelo global
    this.http.post('playlist/get-all', { all: true }, true).subscribe({
      next: (res) => {
        const list: Array<any> = res.data.list;
        if (list.length > 0) {
          const defaultPlaylist = list.find((obj) => obj.isDefault);
          if (defaultPlaylist) {
            this.playlists.default = new Playlist(defaultPlaylist.name, [], [], null, true, defaultPlaylist.id);
            this.playlists.selected = this.playlists.default;
            this.loadPlaylist(defaultPlaylist.id, true);
          } else {
            console.error('Defualt playlist not found');
            this.http.setToast('error', 'Error al cargar listas', 'Default playlist not found');
          }
          this.playlists.list = list.filter((obj) => !obj.isDefault).map((obj) => new Playlist(obj.name, [], [], null, false, obj.id));
          this.tsService.epochsConfig('set', res.data.tsConfig.epochs);
          this.tsService.init();
        } else {
          console.error('Default playlist not found');
          this.http.setToast('error', 'No se encontraron listas de reproducción', 'Default playlist not found');
        }
      }
    });
  }

  setPlaylist(confirm: boolean, mode?: 'new' | 'edit'): void {
    if (confirm) {
      this.http.post('playlist/create', { name: this.playlistModal.name }, true).subscribe({
        next: (res) => {
          this.playlists.list.push(new Playlist(this.playlistModal.name, [], [], null, false, res.data.id));
          this.playlistModal.visible = false;
        }
      });
    } else {
      this.playlistModal.mode = mode || 'new';
      this.playlistModal.visible = true;
    }
  }

  loadPlaylist(idPlaylist: number, isDefault: boolean): void {
    this.http.get(`songs/list-by-idPlaylist?value=${idPlaylist}`, true).subscribe({
      next: (res: any) => {
        const list: Array<Song> = res.data;
        if (isDefault && this.playlists.default)
          this.playlists.default.songs = list;
        else if (this.playlists.selected)
          this.playlists.selected.songs = list;
      }
    });
  }

  uploadSongs(evt: any, mode: 'train' | 'predict'): void {
    const list = this.playlists.selected?.songs as Array<Song>;
    evt.currentFiles.forEach((item: any) => {
      const song: Song = {
        name: item.name,
        type: 'file',
        file: item,
        userScore: null,
        tsPrediction: null,
        storageStatus: 'local',
        tsStatus: null,
        tsInitStatus: mode
      }
      list.push(song);
      this.songService.addToPoolSongsForUpload({ ...song });
    });

    this.songService.uploadSongsToServer(list, this.playlists.selected?.id as number, (error: boolean, data: any, index: number) => {
      if (error) {
        list[index].storageStatus = 'error';
        list[index].storageStatusErrReason = data.storageStatusErrReason;
      } else if (!data.completed) {
        list[index].id = data.id;
        list[index].storageStatus = 'uploaded';
      }
    });
  }

  rate(indexSong: number, rate: number): void {
    const song = this.playlists.selected?.songs[indexSong];
    if (song && (!this.rating.blocked || song.userScore != rate))
      this.http.post('rate/song', { id: song.id, score: rate }, true).subscribe({
        next: (res) => song.userScore = res.data.score
      });
  }

  play(listIndex: number) {
    const song = this.playlists.selected?.songs[listIndex] || null;
    const listForQueue = this.playlists.selected?.songs || [];
    this.playerService.addToListQueue(listForQueue);
    this.playerService.setPlayerEvent('play', song);
  }

  async trainModel(mode: 'single' | 'all', index?: number): Promise<void> {
    await this.tsService.newModel(false);
    let actualTrainedIdSongsList: Array<number> = [];
    let list: Array<number> = []
    if (mode == 'single') {
      this.playlists.selected!.songs[index as number].tsStatus = 'training';
      list = [this.playlists.selected?.songs[index as number].id as number];
    } else {
      list = (
        this.playlists.selected?.songs.filter(
          (obj) => (obj.tsInitStatus == 'train' || obj.tsInitStatus == 'retrain' || 'error') && obj.tsStatus === null
        ).map((obj) => {
          obj.tsStatus = 'training';
          return obj.id;
        }) || []
      ).filter((id): id is number => id !== undefined)
    }

    this.songService.extractFeaturesFromSongs(
      list, (error, data, done, idSong, next) => {
        if (!done) {
          const song = this.playlists.selected?.songs.find((obj) => obj.id == idSong) as Song;
          if (error) {
            if (data.error) {
              switch (data.error.status) {
                case 501:
                  this.http.setToast(
                    'warn',
                    'Extracción de características en espera',
                    `Las características de la canción con id ${idSong} aun no han sido extraídas. 
                     Por favor, espere hasta que el servidor haya completado la extracción.`,
                    7000
                  );
                  song.tsStatus = null;
                  break;
                case 404:
                  if (mode == 'single')
                    this.http.setToast(
                      'error',
                      'Características de la canción no encontradas',
                      `El archivo con las características de la canción con id ${idSong} no ha sido encontrado en el servidor.`,
                      7000
                    );
                  song.tsStatus = 'error';
                  song.tsStatusErrReason = 'features-notfound';
                  break;
                default:
                  if (mode == 'single')
                    this.http.setToast(
                      'error',
                      'Error en la extración de características',
                      `Error al extraer las características de la canción con id ${idSong}.`,
                      7000
                    );
                  song.tsStatus = 'error';
                  song.tsStatusErrReason = 'features-notfound';
                  break;
              }
              updateStatusTask(song).then(() => {
                if (next)
                  next();
              });
            }
          } else {
            this.songService.customizeSpectrogram(data.mel_spectrogram, data.tempo, false).then((customized) => {
              const spectrogram = customized.resized;
              try {
                const epochs = this.tsService.epochsConfig('get') as { score1: number, score2: number, score3: number };
                const epochsNum = epochs['score' + song.userScore as keyof typeof epochs];
                this.tsService.trainSong(false, spectrogram, song.userScore as number, epochsNum).then(() => {
                  song.tsStatus = 'trained';
                  /*updateStatusTask(song).then(()=>{
                    actualTrainedIdSongsList.push(song.id as number);*/
                  if (next)
                    next();
                  //});
                }).catch((error) => {
                  console.error('Ocurrió un error al entrenar el modelo:', error, song);
                  if (mode == 'single')
                    this.http.setToast('error', 'Error al entrenar la canción', `Error al entrenar la canción con id ${idSong}`);
                  song.tsStatus = 'error';
                  song.tsStatusErrReason = 'training-error';
                  updateStatusTask(song).then(() => {
                    if (next)
                      next();
                  });
                });
              } catch (error) {
                song.tsStatus = 'error';
                song.tsStatusErrReason = 'training-error';
                if (mode == 'single')
                  this.http.setToast('error', 'Error al entrenar la canción', `Error al entrenar la canción con id ${idSong}`);
                updateStatusTask(song).then((res) => {
                  if (res === null) {
                    song.storageStatus = 'error';
                    song.storageStatusErrReason = 'other';
                  }
                  if (next)
                    next();
                });
              }
            }).catch((error) => {
              console.error(error);
              song.tsStatus = 'error';
              song.tsStatusErrReason = 'customize-error';
              if (mode == 'single')
                this.http.setToast('error', 'Error al personalizar el espectrograma de la canción', `Error al personalizar el espectrograma de la canción con id ${idSong}`);
              updateStatusTask(song).then((res) => {
                if (res === null) {
                  song.storageStatus = 'error';
                  song.storageStatusErrReason = 'other';
                }
                if (next)
                  next();
              });
            });
          }
        } else {
          const weights = this.tsService.getModelWeights(false);
          const blob = new Blob([JSON.stringify(weights)], { type: 'application/json' });
          const file = new File([blob], 'model-weights.json', { type: 'application/json' });
          const plSelected = this.playlists.selected as Playlist;
          this.http.post('upload/model-weights', { file, playList: { id: plSelected.id, isDefault: plSelected.isDefault } }, {
            key: 'default',
            severity: 'error',
            summary: 'Error al actualizar modelo',
            detail: 'Ocurrió un error al actualizar los pesos del modelo'
          }).subscribe({
            next: (res) => {
              this.playlists.selected?.songs.find((obj) => obj.storageStatus == 'error' || obj.tsStatus == 'error') ?
                this.http.setToast('warn', 'Error al entrenar el modelo', 'Algunas canciones no pudieron ser entrenadas') :
                this.http.setToast('success', 'Entrenamiento completado', 'El modelo ha sido entrenado con éxito');
            }, error: (error) => {
              console.error('Error al subir los pesos del modelo:', error);
              this.playlists.selected?.songs.find((obj) => obj.storageStatus == 'error' || obj.tsStatus == 'error') ?
                this.http.setToast('warn', 'Error al entrenar el modelo', 'Algunas canciones no pudieron ser entrenadas') :
                this.http.setToast('success', 'Entrenamiento completado', 'El modelo ha sido entrenado con éxito');
              actualTrainedIdSongsList.forEach((id) => {
                const song = this.playlists.selected?.songs.find((obj) => obj.id == id) as Song;
                song.tsStatus = 'error';
                song.tsStatusErrReason = 'training-error';
              })
            }
          });
        }
      });
    const that = this;
    function updateStatusTask(song: Song) {
      return that.updateSongStatusOnServer(
        song.id as number,
        song.tsStatus,
        song.tsInitStatus,
        song.storageStatus,
        song.tsPrediction,
        song.userScore
      )
    }
  }

  updateSongStatusOnServer(
    idSong: number,
    tsStatus: Song['tsStatus'],
    tsInitStatus: Song['tsInitStatus'],
    storageStatus: Song['storageStatus'],
    tsPrediction: Song['tsPrediction'],
    userScore: Song['userScore']
  ): Promise<any> {
    return new Promise((resolve) => {
      this.http.post('songs/update-status', {
        idSong,
        tsStatus,
        tsInitStatus,
        storageStatus,
        tsPrediction,
        userScore
      }, true).subscribe({
        next: (res) => resolve(res),
        error: (error) => {
          console.error('Error al actualizar el estado de la canción en el servidor:', error);
          resolve(null);
        }
      });
    })
  }

  showTooltipError(tsStatusErrReason: Song['tsStatusErrReason']): string {
    switch (tsStatusErrReason) {
      case 'features-notfound':
        return 'El archivo con las características de esta canción no ha sido encontrado en el servidor';
      case 'customize-error':
        return 'Error al personalizar el espectrograma de la canción';
      case 'training-error':
        return 'Error al entrenar la canción';
      default:
        return 'Error desconocido';
    }
  }
}
