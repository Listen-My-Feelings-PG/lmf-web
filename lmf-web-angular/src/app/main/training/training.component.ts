import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { LibrosaTsFeatures, Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';
import { PlayerComponent } from "../../player/player.component";
import * as tf from '@tensorflow/tfjs';
import { SongFeaturesService } from '../../_services/song-features.service';

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

  model!: tf.Sequential | null;

  constructor(
    private http: HttpService,
    private songFeaturesService: SongFeaturesService
  ) {
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
    console.info('Inicializando modelo...');
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset();
    console.info(`Variables activas: ${tf.memory().numTensors}`);
    if (this.model) {
      this.model.dispose();
      this.model = null;
    }
    if (!this.model) {
      this.model = tf.sequential();

      this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [129, 20000] }));
      this.model.add(tf.layers.flatten());
      this.model.add(tf.layers.dense({ units: 32, activation: 'relu' }));
      this.model.add(tf.layers.dense({ units: 1, activation: 'linear' }));

      await this.model.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError',
        metrics: ['mae']
      });
    }
    this.http.get('songs/list').subscribe({
      next: (res) => {
        this.songs.listForTrain = res.data.filter((obj: any) => obj.userScore !== null && obj.tsPrediction === null);
        this.songs.listForPredict = res.data.filter((obj: any) => obj.userScore === null && (obj.tsPrediction === null || obj.tsPrediction >= 0));
      }
    });
  }

  uploadSongsProcess(evt: any, mode: 'train' | 'predict') {
    const that = this;
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
      const list = mode == 'train' ? this.songs.listForTrain : this.songs.listForPredict;
      this.songs.listForTrain.push(song);
      this.songs.pool.push({ ...song, listIndex: list.length - 1 });
    });

    if (!this.songs.busy) {
      this.songs.iterator = this.songs.pool[Symbol.iterator]();
      this.songs.busy = true;
      trigger();
    }
    function trigger() {
      let item = that.songs.iterator.next();
      if (item.done)
        return checkPool(item);
      item.value.userScore = 0;
      item.value.tsPrediction = null;
      that.http.post('upload/file', item.value, true).subscribe({
        next: (data: any) => {
          let listSong = that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][item.value.listIndex];
          listSong.storageStatus = 'uploaded';
          listSong.id = data.row.id;
          checkPool(item);
        },
        error: (error) => {
          let listSong = that.songs.listForTrain[item.value.listIndex];
          listSong.storageStatus = 'error';
          listSong.storageStatusErrReason = error.status == 403 ? 'duplicated' : 'other';
          checkPool(item);
        }
      });
    }

    function checkPool(item: any) {
      if (!item.done)
        trigger();
      else {
        that.songs.pool = [];
        that.songs.busy = false;
      }
    }
  }

  rate(indexSong: number, rate: number, mode: 'train' | 'predict'): void {
    let song = mode == 'train' ? this.songs.listForTrain[indexSong] : this.songs.listForPredict[indexSong];
    if (!this.rating.blocked || song.userScore != rate) {
      this.http.post('rate/song', { id: song.id, score: rate }, false, this.rating.blocked).subscribe({
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

  getSongTsFeatures(mode: 'train' | 'predict') {

    const that = this;

    const songsRated: Array<{
      id: number,
      userScore: number
    }> = this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'].filter(
      (obj) => (mode == 'train' && (obj.userScore !== null &&
        obj.userScore > 0 &&
        obj.tsFeaturesDimensions === undefined &&
        obj.id)) || (mode == 'predict' &&
          obj.id && obj.userScore === null)
    ).map((obj) => ({ id: obj.id as number, userScore: obj.userScore as number }));

    this.tsFeatures.poolSongs = songsRated;

    if (!this.tsFeatures.busy) {
      this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
      this.tsFeatures.busy = true;
      trigger();
    }

    function trigger() {
      let item = that.tsFeatures.iterator.next();
      if (item.done)
        return checkPool(item);
      let songIndex = that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'].findIndex((obj) => obj.id == item.value.id);
      let songTarget = that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][songIndex];
      that.http.get(`download/tsfeatures?value=${item.value.id}`, true).subscribe({
        next: (res) => {
          const tensorResources = {
            features: res,
            songId: item.value.id,
            userScore: item.value.userScore
          }

          that.songFeaturesService.customizeSpectrogram(
            tensorResources.features.mel_spectrogram,
            tensorResources.features.tempo,
            false
          ).then(async (data) => {
            songTarget.tsFeaturesDimensions = data.lastIndex - data.firstIndex;
            const mel_spectrogram_resized = data.resized;
            if (mode == 'train') {
              console.info('Iniciando entrenamiento para la canción con ID:', tensorResources.songId);
              console.log(
                'mel_spectrogram_resized',
                mel_spectrogram_resized.length,
                mel_spectrogram_resized[0].length, '|',
                data.firstIndex, data.lastIndex, '|',
                tensorResources.userScore ** 4
              );
              const inputTensor = tf.tensor2d(mel_spectrogram_resized);
              const outputTensor = tf.tensor1d([tensorResources.userScore]);
              await that.model?.fit(inputTensor.expandDims(0), outputTensor, { epochs: [1, 16, 81][tensorResources.userScore - 1], batchSize: 1 });
              /**Epocas (mejor a peor):
               * -tensorResources.userScore ** 4
               * -tensorResources.userScore ** 3 */

              inputTensor.dispose();
              outputTensor.dispose();
              checkPool(item);

            } else {
              console.info('Iniciando predicción para la canción con ID:', tensorResources.songId);

              const inputTensor = tf.tensor2d(mel_spectrogram_resized);
              const prediction = that.model?.predict(inputTensor.expandDims(0)) as tf.Tensor;
              const predictedScore = prediction.dataSync()[0];

              songTarget.tsPrediction = predictedScore;
              that.http.post('upload/prediction', { id: tensorResources.songId, prediction: predictedScore }).subscribe({
                next: (res) => {
                  inputTensor.dispose();
                  prediction.dispose();
                  checkPool(item);
                }, error: (error) => {
                  console.error('Error al enviar la predicción:', error);
                  inputTensor.dispose();
                  prediction.dispose();
                  checkPool(item);
                }
              })
            }
          });
        },
        error: (error) => {
          console.error('Error al obtener características:', error);
          that.songs.listForTrain[songIndex].tsFeaturesDimensions = 'error';
          that.songs.listForTrain[songIndex].tsFeaturesErrReason = 'other';
          checkPool(item);
        }
      });
    }

    function checkPool(item: any) {
      if (!item.done)
        trigger();
      else {
        that.tsFeatures.poolSongs = [];
        that.tsFeatures.busy = false;
        console.info('Pool finalizado');
        console.info(`Variables activas: ${tf.memory().numTensors}`);
      }
    }
  }

  stopTsFeaturesPool() {
    this.tsFeatures.poolSongs = [];
    this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
  }


}
