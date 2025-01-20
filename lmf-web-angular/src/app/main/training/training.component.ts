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
    console.log('Inicializando componente de entrenamiento...');
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset(); // Limpia el backend para evitar conflictos
    console.log(`Variables activas: ${tf.memory().numTensors}`);
    if (this.model) {
      this.model.dispose(); // Elimina el modelo anterior
      this.model = null;    // Asegúrate de que no se reutilice accidentalmente
    }
    if (!this.model) {
      this.model = tf.sequential();
      //this.model.dispose();
      this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [128, 20000] }));
      this.model.add(tf.layers.flatten());
      this.model.add(tf.layers.dense({ units: 32, activation: 'relu' }));
      this.model.add(tf.layers.dense({ units: 1, activation: 'linear' })); // Salida para predecir el score

      await this.model.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError', // Pérdida común para regresión
        metrics: ['mae'] // Error absoluto medio para seguimiento
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
      that.http.get(`download/tsfeatures?value=${item.value.id}`, true).subscribe({ //El mismo request se hace tanto para el entrenamiento como para la predicción
        next: async (data) => {
          that.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][songIndex].tsFeaturesDimensions = that.getTsFeaturesDimensions(data);
          let tensorResources = {
            features: data, //Objeto con las características de la canción
            songId: item.value.id, //ID de la canción
            userScore: item.value.userScore //Calificación del usuario. Esta no importa cuando el modo es 'predict'
          }
          if (mode == 'train') {
            console.log('Iniciando entrenamiento para la canción con ID:', tensorResources.songId);
            const inputTensor/*Raw*/ = tf.tensor2d(tensorResources.features.mel_spectrogram); //Proceso de normalización omitido porque el script de Python ya lo hizo
            //const minVal = tf.min(inputTensorRaw);
            //const maxVal = tf.max(inputTensorRaw);
            //const inputTensor = inputTensorRaw.sub(minVal).div(maxVal.sub(minVal));
            const outputTensor = tf.tensor1d([tensorResources.userScore]); //Convierte la calificación del usuario en un tensor de salida
            await that.model?.fit(inputTensor.expandDims(0), outputTensor, { epochs: 50, batchSize: 1 }); //Entrena el modelo con los tensores de entrada y salida
            //Libera la memoria de los tensores
            //inputTensorRaw.dispose();
            inputTensor.dispose();
            outputTensor.dispose();
            checkPool(item);//Continúa con la siguiente canción
          } else { //Si el mode no es 'train', entonces es 'predict'
            console.log('Iniciando predicción para la canción con ID:', tensorResources.songId);
            const inputTensorRaw = tf.tensor2d(tensorResources.features.mel_spectrogram); //Convierte las características de la canción en un tensor
            const minVal = tf.min(inputTensorRaw);
            const maxVal = tf.max(inputTensorRaw);
            const inputTensor = inputTensorRaw.sub(minVal).div(maxVal.sub(minVal)); //Convierte las características de la canción en un tensor
            const prediction = that.model?.predict(inputTensor.expandDims(0)) as tf.Tensor; //Realiza la predicción con el modelo entrenado
            const predictedScore = prediction.dataSync()[0]; //Obtiene el valor de la predicción
            that.songs.listForPredict[songIndex].tsPrediction = predictedScore; //Asigna la predicción a la canción

            console.log(`Predicción para la nueva canción: ${predictedScore}`);
            //Libera la memoria de los tensores
            inputTensorRaw.dispose();
            inputTensor.dispose();
            prediction.dispose();
            checkPool(item);//Continúa con la siguiente canción
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
