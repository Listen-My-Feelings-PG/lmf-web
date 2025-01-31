import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { LibrosaTsFeatures, Playlist, Song } from '../../_models/all.model';
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
    InputSwitchModule
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
  ////////////////////////////////////////////
  urlSongPlaying: string;
  songs: {
    listForTrain: Array<Song>, //Lista principal
    listForPredict: Array<Song>
    pool: Array<Song>,
    busy: boolean,
    iterator: any
  }

  tsFeatures: {
    poolSongs: Array<{
      id: number,
      userScore: number | null
    }>,
    busy: boolean,
    iterator: any
  }

  rating: {
    stars: Array<number>,
    blocked: boolean
  }

  constructor(
    private http: HttpService,
    private songService: SongService,
    private tsService: TensorflowService,
    private playerService: PlayerService
  ) {
    this.idSongPlaying = 0;
    this.playlists = {
      list: [],
      selected: null,
      default: null,
      loaded: false
    }
    ////////////////////////////////////////////
    this.tsFeatures = {
      poolSongs: [],
      busy: false,
      iterator: null
    }

    this.urlSongPlaying = '';
    this.songs = {
      listForTrain: [],
      listForPredict: [],
      pool: [],
      busy: false,
      iterator: null
    }

    this.rating = {
      stars: [0, 1, 2],
      blocked: false
    }

  }

  async ngOnInit(): Promise<void> {
    this.playerService.getPlayerEmmitteridSong().subscribe({ next: (id) => this.idSongPlaying = id });
    this.http.post('playlist/get-all', { all: true }, true).subscribe({
      next: (res) => {
        const dl = res.data.find((obj: any) => obj.isDefault);

      }
    });
    ////////////////////////////////////////////
  }

  loadPlaylist(idPlaylist: number, isDefault: boolean): void {
    this.http.get(`songs/list-by-id-playlist?value=${idPlaylist}`, true).subscribe({
      next: (res: any) => {
        if (res.data) {

        }
      }
    });
  }

  uploadSongs(evt: any) {
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
        tsInitStatus: 'train'
      }
      list.push(song);
      this.songService.addToPoolSongsForUpload({ ...song });
    });

    this.songService.uploadSongsToServer(this.playlists.selected?.id as number, (error: boolean, data: any, index: number) => {
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
        next: (res) => song.userScore = res.score
      });
  }

  play(listIndex: number) {
    const song = this.playlists.selected?.songs[listIndex] || null;
    const listForQueue = this.playlists.selected?.songs || [];
    this.playerService.addToListQueue(listForQueue);
    this.playerService.setPlayerEvent('play', song);
  }

  async getSongTsFeatures(mode: 'train' | 'predict') {
    const list = this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'];
    await this.tsService.loadModel();
    this.songService.extractFeaturesFromSongs(
      list.map((obj) => obj.id).filter((id): id is number => id !== undefined),
      (
        error: boolean,
        features: LibrosaTsFeatures,
        completed: boolean,
        idSong: number | null,
        next: Function
      ) => {
        if (!completed) {
          if (!error) {
            this.songService.customizeSpectrogram(features.mel_spectrogram, features.tempo, false).then(async (customized) => {
              const spectrogram = customized.resized;
              if (mode == 'train') {
                const actualSong = list.find((obj) => obj.id == idSong);
                try {
                  await this.tsService.trainSong(spectrogram, actualSong?.userScore as number);
                  if (actualSong)
                    actualSong.tsStatus = 'trained';
                  next();
                } catch (error) {
                  if (actualSong)
                    actualSong.tsStatus = 'error';
                  next();
                }
              } else {
                next();
              }
            }).catch((error) => {
              console.error(error);
              next();
            })
          } else {
            console.error('Error al extraer características:', features);
            next();
          }
        }
      }
    );
  }

  stopTsFeaturesPool() {
    this.tsFeatures.poolSongs = [];
    this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
  }


  getStatusTraduction(storageStatus: string, tsStatus: string, tsInitStatus: string): string {
    return `${{
      'local': 'Carga',
      'uploading': 'Cargando',
      'uploaded': 'Cargado',
      'downloading': 'Descargando',
      'downloaded': 'Descargado',
      'error': 'Error'
    }[storageStatus]}|${{
      'training': 'Entrenando',
      'trained': 'Entrenado',
      'predicting': 'Prediciendo',
      'predicted': 'Predicho',
      'retrained': 'Reentrenado',
      'error': 'Error'
    }[tsStatus] || ''}|${{
      'train': 'Entrenar',
      'predict': 'Predecir',
      'retrain': 'Reentrenar'
    }[tsInitStatus]}`
  };


}
