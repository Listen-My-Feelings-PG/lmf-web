import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { LibrosaTsFeatures, Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';
import { PlayerComponent } from "../../player/player.component";
//import * as tf from '@tensorflow/tfjs';

@Component({
  selector: 'app-training',
  standalone: true,
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule,
    PlayerComponent
  ],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  urlSongPlaying: string;
  songs: {
    list: Array<Song>, //Lista principal
    pool: Array<Song>,
    busy: boolean,
    iterator: any
  }

  tsFeatures: {
    poolSongs: Array<{
      id: number,
      userScore: number
    }>,
    busy: boolean,
    iterator: any
  }

  rating: {
    stars: Array<number>,
    blocked: boolean
  }

  model: /*tf.Sequential |*/ undefined;

  constructor(
    private http: HttpService,
  ) {
    this.tsFeatures = {
      poolSongs: [],
      busy: false,
      iterator: null
    }

    this.urlSongPlaying = '';
    this.songs = {
      list: [],
      pool: [],
      busy: false,
      iterator: null
    }

    this.rating = {
      stars: [0, 1, 2],
      blocked: false
    }

    this.songs.iterator = this.songs.pool[Symbol.iterator]();
    /*this.model = tf.sequential();
    this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [128, 20000] }));
    this.model.add(tf.layers.flatten());
    this.model.add(tf.layers.dense({ units: 32, activation: 'relu' }));
    this.model.add(tf.layers.dense({ units: 1, activation: 'linear' })); // Salida para predecir el score

    this.model.compile({
      optimizer: 'adam',
      loss: 'meanSquaredError',
      metrics: ['mse']
    });*/
  }

  ngOnInit(): void {
    this.http.get('songs/list').subscribe({
      next: (res) => {
        this.songs.list = res.data;
      }
    });
  }

  private triggerUploadRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkUploadPool(item);
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'uploaded';
        listSong.id = data.row.id;
        this.checkUploadPool(item);
      },
      error: (error) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'error';
        listSong.errReason = error.status == 403 ? 'duplicated' : 'other';
        this.checkUploadPool(item);
      }
    });
  }

  private checkUploadPool(item: any) {
    if (!item.done)
      this.triggerUploadRequest();
    else {
      this.songs.pool = [];
      this.songs.busy = false;
    }
  }

  onFilesSelected(evt: any) {
    evt.currentFiles.forEach((item: any) => {
      const song: Song = {
        name: item.name,
        type: 'file',
        file: item,
        link: '',
        userScore: null,
        tsScore: null,
        status: 'local'
      }
      this.songs.list.push(song);
      this.songs.pool.push({ ...song, listIndex: this.songs.list.length - 1 });
    });

    if (!this.songs.busy) {
      this.songs.iterator = this.songs.pool[Symbol.iterator]();
      this.songs.busy = true;
      this.triggerUploadRequest();
    }
  }

  rate(indexSong: number, rate: number): void {
    let song = this.songs.list[indexSong];
    if (!this.rating.blocked || song.userScore != rate) {
      this.http.post('rate/song', { id: song.id, score: rate }, false, this.rating.blocked).subscribe({
        next: (res) => {
          song.userScore = res.score;
        }
      });
    }
  }

  play(listIndex: number) {
    const s = this.songs.list[listIndex];
    this.urlSongPlaying = `http://localhost:3000/songs/song/mp3?value=${s.id}`;
  }

  getSongTsFeatures() {
    const songsRated: Array<{
      id: number,
      userScore: number
    }> = this.songs.list.filter(
      (obj) => obj.userScore !== null &&
        obj.userScore > 0 &&
        obj.tsFeaturesDimensions === undefined &&
        obj.id
    ).map((obj) => ({ id: obj.id as number, userScore: obj.userScore as number }));
    this.tsFeatures.poolSongs = songsRated;
    if (!this.tsFeatures.busy) {
      this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
      this.tsFeatures.busy = true;
      this.triggerTsfeaturesRequest();
      console.log('triggerTsfeaturesRequest disparado...');
    }
  }

  private triggerTsfeaturesRequest() {
    let item = this.tsFeatures.iterator.next();
    if (item.done)
      return this.checkTsFeaturesPool(item);
    let songIndex = this.songs.list.findIndex((obj) => obj.id == item.value.id);
    this.http.get(`download/tsfeatures?value=${item.value.id}`, true).subscribe({
      next: (data) => {
        let tensorResources = {
          features: data,
          songId: item.value.id,
          userScore: item.value.userScore
        }

        //const inputTensor = tf.tensor2d(tensorResources.features.mel_spectrogram);
        //const outputTensor = tf.tensor1d([tensorResources.userScore]);

        /*this.model.fit(inputTensor.expandDims(0), outputTensor, { epochs: 10, batchSize: 1 }).then((result) => {
          console.log(`Entrenamiento completado para la canción con ID: ${tensorResources.songId}`, result);
          this.songs.list[songIndex].tsFeaturesDimensions = this.getTsFeaturesDimensions(data);

          inputTensor.dispose();
          outputTensor.dispose();
          this.checkTsFeaturesPool(item);

        }).catch((error) => {
          console.error('Ocurrió un error al entrenar el modelo', error);
          inputTensor.dispose();
          outputTensor.dispose();*/
          this.checkTsFeaturesPool(item);/*
        });*/
      },
      error: (error) => {
        console.log('error', error);
        this.songs.list[songIndex].tsFeaturesDimensions = 'error';
        this.songs.list[songIndex].tsFeaturesErrReason = 'other';
        this.checkTsFeaturesPool(item);
      }
    });
  }

  private checkTsFeaturesPool(item: any) {
    if (!item.done)
      this.triggerTsfeaturesRequest();
    else {
      this.tsFeatures.poolSongs = [];
      this.tsFeatures.busy = false
      console.log('Pool finalizado');
    }
  }

  stopTsFeaturesPool() {
    this.tsFeatures.poolSongs = [];
    this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
  }

  getTsFeaturesDimensions(data: LibrosaTsFeatures) {
    let validColumns = 0;
    data.mel_spectrogram.forEach((item) => {
      item.forEach((value) => {
        if (value > 0)
          validColumns++;
      });
    });
    return validColumns;
  }
}
