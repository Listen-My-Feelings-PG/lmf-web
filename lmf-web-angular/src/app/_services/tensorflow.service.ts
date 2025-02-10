import { Injectable } from '@angular/core';
import * as tf from '@tensorflow/tfjs';

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

  private model!: tf.Sequential | null;

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
    if (this.model) {
      this.model.dispose();
      this.model = null;
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

  getModelWeights() {
    const weights = this.model?.getWeights().map(w => w.arraySync());
    return weights;
  }

  setModelWeights(weights: Array<Array<number>>): Promise<string> {
    return new Promise((resolve, reject) => {
      if (this.model) {
        try {
          this.model.setWeights(weights.map(w => tf.tensor(w)));
          resolve('Pesos cargados');
        } catch (error) {
          console.error('Error al cargar los pesos en el modelo', error);
          reject(error);
        }
      } else
        reject('Modelo no cargado');
    })
  }

  newModel(): Promise<string> {
    return new Promise((resolve) => {
      this.model = tf.sequential();
      this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [129, 20000] }));
      this.model.add(tf.layers.flatten());
      this.model.add(tf.layers.dense({ units: 32, activation: 'relu' }));
      this.model.add(tf.layers.dense({ units: 1, activation: 'linear' }));

      this.model.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError',
        metrics: ['mae']
      });
      resolve('Modelo cargado');
    });
  }

  /*loadModel(): Promise<string> {
    return new Promise((resolve) => {
      this.model = tf.sequential();
      this.model.add(tf.layers.dense({ units: 64, activation: 'relu', inputShape: [129, 20000] }));
      this.model.add(tf.layers.flatten());
      this.model.add(tf.layers.dense({ units: 32, activation: 'relu' }));
      this.model.add(tf.layers.dense({ units: 1, activation: 'linear' }));
 
      this.model.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError',
        metrics: ['mae']
      });
      resolve('Modelo cargado');
    });
  }*/

  predict() {

  }

  trainSong(
    mel_spectrogram: Array<Array<number>>,
    score: number,
    epochs: number
  ) {
    return new Promise<void>((resolve, reject) => {
      if (!this.model) {
        reject({ message: 'Modelo no cargado' });
        return;
      }

      const inputTensor = tf.tensor2d(mel_spectrogram);
      const outputTensor = tf.tensor1d([score]);

      this.model.fit(inputTensor.expandDims(0), outputTensor, { epochs, batchSize: 1 }).then(() => {
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
