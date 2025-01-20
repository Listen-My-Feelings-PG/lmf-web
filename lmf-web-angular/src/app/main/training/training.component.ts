import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { LibrosaTsFeatures, Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';
import { PlayerComponent } from "../../player/player.component";
import * as tf from '@tensorflow/tfjs';

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
    console.log('Inicializando modelo...');
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset();
    console.log(`Variables activas: ${tf.memory().numTensors}`);
    if (this.model) {
      this.model.dispose();
      this.model = null;
    }
    if (!this.model) {
      this.model = tf.sequential();

      this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [129, 20000] })); //el ultimo eje y representa la intensidad del tempo. Normalizala con los valores del espectrograma
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
    function trigger() {
      let item = that.songs.iterator.next();
      if (item.done)
        return checkPool(item);
      item.value.userScore = 0;
      item.value.tsPrediction = null;
      that.http.post('upload/file', item.value, true).subscribe({
        next: (data: any) => {
          let listSong = mode == 'train' ? that.songs.listForTrain[item.value.listIndex] : that.songs.listForPredict[item.value.listIndex];
          listSong.statusStorage = 'uploaded';
          listSong.id = data.row.id;
          checkPool(item);
        },
        error: (error) => {
          let listSong = that.songs.listForTrain[item.value.listIndex];
          listSong.statusStorage = 'error';
          listSong.statusErrReason = error.status == 403 ? 'duplicated' : 'other';
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

    evt.currentFiles.forEach((item: any) => {
      const song: Song = {
        name: item.name,
        type: 'file',
        file: item,
        link: '',
        userScore: null,
        tsPrediction: null,
        statusStorage: 'local'
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
      console.log(`this.triggerTsfeaturesRequest('${mode}')...`);
      trigger();
    }

    function trigger() {
      let item = that.tsFeatures.iterator.next();
      if (item.done)
        return checkPool(item);
      let songIndex = that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'].findIndex((obj) => obj.id == item.value.id);
      let songTarget = that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][songIndex];
      that.http.get(`download/tsfeatures?value=${item.value.id}`, true).subscribe({
        next: async (data) => {
          songTarget.tsFeaturesDimensions = that.getTsFeaturesDimensions(data);

          const tensorResources = {
            features: data,
            songId: item.value.id,
            userScore: item.value.userScore
          }

          if (mode == 'train') {
            console.log('Iniciando entrenamiento para la canción con ID:', tensorResources.songId);
            //Hacer este calculo en el servidor (No debe haver ninguna tarea de normalización aqui, salvo la normalización del tempo)
            let maxValue = 0;
            tensorResources.features.mel_spectrogram.forEach((itemY: any, indexY: any) => {
              itemY.forEach((itemX: any, indexX: any) => {
                if (indexX > 0 && itemX > itemY[indexX - 1]) {
                  maxValue = itemX;
                }
              });
            });
            console.log('Valor máximo:', maxValue);

            /*const inputTensor = tf.tensor2d(tensorResources.features.mel_spectrogram); 

            const outputTensor = tf.tensor1d([tensorResources.userScore]); 
            await that.model?.fit(inputTensor.expandDims(0), outputTensor, { epochs: 50, batchSize: 1 }); 

            inputTensor.dispose();
            outputTensor.dispose();
            */checkPool(item);

          } else {

            console.log('Iniciando predicción para la canción con ID:', tensorResources.songId);
            const inputTensorRaw = tf.tensor2d(tensorResources.features.mel_spectrogram);

            const melFlattened = inputTensorRaw.flatten();
            const inputTensor = melFlattened.concat(tf.tensor1d([tensorResources.features.tempo]));

            const prediction = that.model?.predict(inputTensor.expandDims(0)) as tf.Tensor;
            const predictedScore = prediction.dataSync()[0];

            songTarget.tsPrediction = predictedScore;
            that.http.post('upload/prediction', { id: tensorResources.songId, prediction: predictedScore }).subscribe({
              next: (res) => {
                console.log(`Predicción para la nueva canción: ${predictedScore}`, res);

                inputTensorRaw.dispose();
                inputTensor.dispose();
                prediction.dispose();
                checkPool(item);
              }, error: (error) => {
                console.error('Error al enviar la predicción:', error);
                inputTensorRaw.dispose();
                inputTensor.dispose();
                prediction.dispose();
                checkPool(item);
              }
            })

          }
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
        console.log(`Variables activas: ${tf.memory().numTensors}`);
      }
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
