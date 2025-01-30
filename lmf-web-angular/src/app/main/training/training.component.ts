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
    FormsModule
  ],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  playlists: {
    list: Array<Playlist>,
    selected: Playlist | null,
    default: Playlist | null
  }
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
    private tsService: TensorflowService
  ) {
    this.playlists = {
      list: [],
      selected: null,
      default: null
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
    this.http.post('playlist/get-list', { all: true }, true).subscribe({
      next: (res) => {
        this.playlists.list = res.data.map((obj: any) => new Playlist(obj.name, [], obj.isDefault, obj.id));
        console.log('res:', res);
      }
    });
    ////////////////////////////////////////////
    this.http.get('songs/list').subscribe({
      next: (res) => {
        this.songs.listForTrain = res.data.filter((obj: any) => obj.tsInitStatus === 'train' || obj.tsInitStatus === 'retrain');
        this.songs.listForPredict = res.data.filter((obj: any) => obj.tsInitStatus === 'predict');
      }
    });
  }

  uploadSongsProcess(evt: any, mode: 'train' | 'predict') {
    const mainList = this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'];
    evt.currentFiles.forEach((item: any) => {
      const song: Song = {
        name: item.name,
        type: 'file',
        file: item,
        userScore: null,
        tsPrediction: null,
        storageStatus: 'local',
        tsStatus: null,
        tsInitStatus: mode,
        listIndex: null
      }
      mainList.push(song);
      this.songService.addToPoolSongsForUpload({ ...song, listIndex: mainList.length - 1 });
    });

    this.songService.uploadSongsToServer((error: boolean, data: any) => {
      if (error) {
        mainList[data.listIndex].storageStatus = 'error';
        mainList[data.listIndex].storageStatusErrReason = data.storageStatusErrReason;
      } else if (!data.completed) {
        mainList[data.listIndex].id = data.id;
        mainList[data.listIndex].storageStatus = 'uploaded';
      }
    });
  }

  rate(indexSong: number, rate: number, mode: 'train' | 'predict'): void {
    const song = this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][indexSong];
    if (!this.rating.blocked || song.userScore != rate) {
      this.http.post('rate/song', { id: song.id, score: rate }, true).subscribe({
        next: (res) => {
          song.userScore = res.score;
        }
      });
    }
  }

  play(listIndex: number, mode: 'train' | 'predict') {
    const s = mode == 'train' ? this.songs.listForTrain[listIndex] : this.songs.listForPredict[listIndex];
    this.urlSongPlaying = `http://localhost:3000/songs/song/mp3?value=${s.id}`;
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


}
