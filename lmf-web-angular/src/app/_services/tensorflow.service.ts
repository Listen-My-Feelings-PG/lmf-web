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

  private model!: tf.Sequential | null;

  constructor() {
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
    console.info('Inicializando tensorflow...');
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset();
    console.info(`Tensorflow inicializado. Variables activas: ${tf.memory().numTensors}`);
  }

  loadModel(): Promise<string> {
    return new Promise((resolve) => {
      if (this.model) {
        this.model.dispose();
        this.model = null;
      }
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

  predict() {

  }

  trainSong(
    mel_spectrogram: Array<Array<number>>,
    score: number,
  ) {
    return new Promise(async (resolve, reject) => {
      if (!this.model)
        return reject('Modelo no cargado');
      try {
        const inputTensor = tf.tensor2d(mel_spectrogram);
        const outputTensor = tf.tensor1d([score]);
        await this.model.fit(inputTensor.expandDims(0), outputTensor, { epochs: [1, 16, 81][score - 1], batchSize: 1 });
        inputTensor.dispose();
        outputTensor.dispose();
        resolve('Entrenamiento completado');
      } catch (e) {
        console.error('Error al entrenar canción:', e);
        reject('Error al entrenar');
      }
    });
  }
}
