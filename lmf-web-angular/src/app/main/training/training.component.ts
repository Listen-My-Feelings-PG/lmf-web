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

  private triggerUploadRequest(mode: 'train' | 'predict') {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkUploadPool(item, mode);
    item.value.userScore = 0;
    item.value.tsPrediction = null;
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        let listSong = mode == 'train' ? this.songs.listForTrain[item.value.listIndex] : this.songs.listForPredict[item.value.listIndex];
        listSong.statusStorage = 'uploaded';
        listSong.id = data.row.id;
        this.checkUploadPool(item, mode);
      },
      error: (error) => {
        let listSong = this.songs.listForTrain[item.value.listIndex];
        listSong.statusStorage = 'error';
        listSong.statusErrReason = error.status == 403 ? 'duplicated' : 'other';
        this.checkUploadPool(item, mode);
      }
    });
  }

  private checkUploadPool(item: any, mode: 'train' | 'predict') {
    if (!item.done)
      this.triggerUploadRequest(mode);
    else {
      this.songs.pool = [];
      this.songs.busy = false;
    }
  }

  uploadFromInput(evt: any, mode: 'train' | 'predict') {
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
      this.triggerUploadRequest(mode);
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
    console.log('poolSongs', this.tsFeatures.poolSongs, mode);
    if (!this.tsFeatures.busy) {
      this.tsFeatures.iterator = this.tsFeatures.poolSongs[Symbol.iterator]();
      this.tsFeatures.busy = true;
      console.log(`this.triggerTsfeaturesRequest('${mode}')...`);
      this.triggerTsfeaturesRequest(mode);
    }
  }

  private triggerTsfeaturesRequest(mode: 'train' | 'predict') {
    let item = this.tsFeatures.iterator.next();
    if (item.done)
      return this.checkTsFeaturesPool(item, mode);
    let songIndex = this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'].findIndex((obj) => obj.id == item.value.id);
    this.http.get(`download/tsfeatures?value=${item.value.id}`, true).subscribe({ //El mismo request se hace tanto para el entrenamiento como para la predicción
      next: async (data) => {
        this.songs[mode == 'train' ? 'listForTrain' : 'listForPredict'][songIndex].tsFeaturesDimensions = this.getTsFeaturesDimensions(data);
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
          await this.model?.fit(inputTensor.expandDims(0), outputTensor, { epochs: 50, batchSize: 1 }); //Entrena el modelo con los tensores de entrada y salida
          //Libera la memoria de los tensores
          //inputTensorRaw.dispose();
          inputTensor.dispose();
          outputTensor.dispose();
          this.checkTsFeaturesPool(item, mode);//Continúa con la siguiente canción
        } else { //Si el mode no es 'train', entonces es 'predict'
          console.log('Iniciando predicción para la canción con ID:', tensorResources.songId);
          const inputTensorRaw = tf.tensor2d(tensorResources.features.mel_spectrogram); //Convierte las características de la canción en un tensor
          const minVal = tf.min(inputTensorRaw);
          const maxVal = tf.max(inputTensorRaw);
          const inputTensor = inputTensorRaw.sub(minVal).div(maxVal.sub(minVal)); //Convierte las características de la canción en un tensor
          const prediction = this.model?.predict(inputTensor.expandDims(0)) as tf.Tensor; //Realiza la predicción con el modelo entrenado
          const predictedScore = prediction.dataSync()[0]; //Obtiene el valor de la predicción
          this.songs.listForPredict[songIndex].tsPrediction = predictedScore; //Asigna la predicción a la canción
          console.log(`Predicción para la nueva canción: ${predictedScore}`);
          //Libera la memoria de los tensores
          inputTensorRaw.dispose();
          inputTensor.dispose();
          prediction.dispose();
          this.checkTsFeaturesPool(item, mode);//Continúa con la siguiente canción
        }
      },
      error: (error) => {
        console.error('Error al obtener características:', error);
        this.songs.listForTrain[songIndex].tsFeaturesDimensions = 'error';
        this.songs.listForTrain[songIndex].tsFeaturesErrReason = 'other';
        this.checkTsFeaturesPool(item, mode);
      }
    });

  }

  private checkTsFeaturesPool(item: any, mode: 'train' | 'predict') {
    if (!item.done)
      this.triggerTsfeaturesRequest(mode);
    else {
      this.tsFeatures.poolSongs = [];
      this.tsFeatures.busy = false;
      console.info('Pool finalizado');
      console.log(`Variables activas: ${tf.memory().numTensors}`);
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
