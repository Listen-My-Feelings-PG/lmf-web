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
    console.log('Tensorflow inicializado.');
  }

  async loadModel(): Promise<void> {
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
    console.log('saving model...');
    await this.model.save('http://localhost:3000/upload/model?value=true').then((res) => {
      console.log('Modelo guardado:', res);
    }).catch((err) => {
      console.error('Error al guardar modelo:', err);
    });
  }

  predict() {

  }

  trainList(songsList: Array<{
    idSong: number,
    score: number,
    features: Array<Array<number>>
  }>) {

    function trigger() {

    }

    function checkPool() { }



  }
}
