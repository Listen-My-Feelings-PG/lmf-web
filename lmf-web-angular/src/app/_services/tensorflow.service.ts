import { Injectable } from '@angular/core';
import * as tf from '@tensorflow/tfjs';
import { SpectrogramSpecs } from './song.service';

@Injectable({
  providedIn: 'root'
})
export class TensorflowService {
  private pools: {
    forTrain: Array<{
      idSong: number,
      score: number,
      features: Array<Array<number>>
    }>,
    forPredict: Array<{
      idSong: number,
      score: number | null
      features: Array<Array<number>>
    }>
  }

  busyFlags: {
    forTrain: boolean,
    forPredict: boolean
  }

  iterators: {
    forTrain: any,
    forPredict: any
  }

  epochsNumber: {
    score1: number,
    score2: number,
    score3: number
  }
  /**Se manejan dos modelos: */
  private globalModel!: tf.Sequential | null; //El global (donde se entrenan todas las canciones de todas las playlists)
  private plModel!: tf.Sequential | null; //El de playlist

  constructor() {
    this.epochsNumber = {
      score1: 0,
      score2: 0,
      score3: 0
    }
    this.pools = {
      forTrain: [],
      forPredict: []
    };
    this.busyFlags = {
      forTrain: false,
      forPredict: false
    };
    this.iterators = {
      forTrain: null,
      forPredict: null
    };
  }

  init(): void {
    console.info('Inicializando Tensorflow...');
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset();
    if (this.globalModel) {
      this.globalModel.dispose();
      this.globalModel = null;
    }

    if (this.plModel) {
      this.plModel.dispose();
      this.plModel = null;
    }

    console.info(`Tensorflow inicializado. Variables activas: ${tf.memory().numTensors}`);
  }

  epochsConfig(mode: 'get' | 'set', epochs?: {
    score1: number,
    score2: number,
    score3: number
  }): number | { score1: number, score2: number, score3: number } {
    if (mode == 'set') {
      if (epochs)
        this.epochsNumber = epochs;
      return 0;
    } else
      return this.epochsNumber;
  }

  getModelWeights(global: boolean): Array<Array<number>> | null {
    if (this[global ? 'globalModel' : 'plModel']) {
      const weights = this[global ? 'globalModel' : 'plModel']?.getWeights().map(w => w.arraySync());
      return weights as Array<Array<number>>;
    } else
      return null;
  }

  setModelWeights(global: boolean, weights: Array<Array<number>>): Promise<string> {
    return new Promise((resolve, reject) => {
      if (this[global ? 'globalModel' : 'plModel']) {
        try {
          this[global ? 'globalModel' : 'plModel']?.setWeights(weights.map(w => tf.tensor(w)));
          resolve('Pesos cargados');
        } catch (error) {
          console.error('Error al cargar los pesos en el modelo', error);
          reject(error);
        }
      } else
        reject('Modelo no cargado');
    })
  }

  newModel(global: boolean): Promise<string> { //Se elige el modelo a cargar (Validar que no se vuelva a cargar si ya lo está)
    return new Promise((resolve) => {
      this[global ? 'globalModel' : 'plModel'] = tf.sequential();
      this[global ? 'globalModel' : 'plModel']?.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [129, 20000] }));
      this[global ? 'globalModel' : 'plModel']?.add(tf.layers.flatten());
      this[global ? 'globalModel' : 'plModel']?.add(tf.layers.dense({ units: 32, activation: 'relu' }));
      this[global ? 'globalModel' : 'plModel']?.add(tf.layers.dense({ units: 1, activation: 'linear' }));

      this[global ? 'globalModel' : 'plModel']?.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError',
        metrics: ['mae']
      });
      resolve('Modelo cargado');
    });
  }

  predict(global: boolean) {

  }

  trainSong(
    global: boolean,
    mel_spectrogram: Array<Array<number>>,
    score: number,
    epochs: number
  ) {
    return new Promise<void>((resolve, reject) => {
      if (!this[global ? 'globalModel' : 'plModel']) {
        reject({ message: 'Modelo no cargado' });
        return;
      }

      const inputTensor = tf.tensor2d(mel_spectrogram);
      const outputTensor = tf.tensor1d([score]);

      this[global ? 'globalModel' : 'plModel']?.fit(inputTensor.expandDims(0), outputTensor, { epochs, batchSize: 1 }).then(() => {
        inputTensor.dispose();
        outputTensor.dispose();
        resolve();
      }).catch((error) => {
        inputTensor.dispose();
        outputTensor.dispose();
        reject({
          message: 'Error en el entrenamiento',
          error
        });
      });
    });
  }
}
