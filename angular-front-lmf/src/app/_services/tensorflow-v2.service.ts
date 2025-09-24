import { Injectable } from '@angular/core';
import * as tf from '@tensorflow/tfjs';
import { BehaviorSubject, Observable } from 'rxjs';
import { ModelConfig, LayerConfig } from '../_models/types';

export interface TensorflowMemoryInfo {
  numTensors: number;
  numDataBuffers: number;
  numBytes: number;
  reasons: string[];
}

export interface ModelTrainingProgress {
  epoch: number;
  loss: number;
  val_loss?: number;
  acc?: number;
  val_acc?: number;
}

@Injectable({
  providedIn: 'root'
})
export class TensorflowService {
  private globalModel: tf.Sequential | null = null;
  private playlistModel: tf.Sequential | null = null;

  private readonly memoryInfo$ = new BehaviorSubject<TensorflowMemoryInfo>({
    numTensors: 0,
    numDataBuffers: 0,
    numBytes: 0,
    reasons: []
  });

  private readonly isInitialized$ = new BehaviorSubject<boolean>(false);
  private readonly trainingProgress$ = new BehaviorSubject<ModelTrainingProgress | null>(null);

  private epochsConfig = {
    score1: 10,
    score2: 15,
    score3: 20
  };

  readonly memoryInfo = this.memoryInfo$.asObservable();
  readonly isInitialized = this.isInitialized$.asObservable();
  readonly trainingProgress = this.trainingProgress$.asObservable();

  constructor() {
    this.initializeTensorflow();
  }

  /**
   * Inicializa TensorFlow.js y configura el backend
   */
  async initializeTensorflow(): Promise<void> {
    try {
      // Configurar backend según capacidades del dispositivo
      await this.setupOptimalBackend();

      // Limpiar memoria previa
      this.cleanupMemory();

      // Actualizar estado
      this.isInitialized$.next(true);
      this.updateMemoryInfo();

      console.info('TensorFlow.js inicializado exitosamente');
    } catch (error) {
      console.error('Error al inicializar TensorFlow.js:', error);
      throw error;
    }
  }

  /**
   * Configura y compila un modelo nuevo
   */
  async createModel(isGlobal: boolean, config?: Partial<ModelConfig>): Promise<void> {
    const modelConfig = this.getDefaultModelConfig(config);

    try {
      const model = tf.sequential();

      // Construir capas del modelo
      this.buildModelLayers(model, modelConfig.architecture.layers);

      // Compilar modelo
      model.compile({
        optimizer: tf.train.adam(),
        loss: 'meanSquaredError',
        metrics: ['mae']
      });

      // Asignar modelo
      if (isGlobal) {
        this.disposeModel('global');
        this.globalModel = model;
      } else {
        this.disposeModel('playlist');
        this.playlistModel = model;
      }

      this.updateMemoryInfo();
      console.info(`Modelo ${isGlobal ? 'global' : 'playlist'} creado exitosamente`);
    } catch (error) {
      console.error('Error al crear modelo:', error);
      throw error;
    }
  }

  /**
   * Entrena una canción en el modelo especificado
   */
  async trainSong(
    isGlobal: boolean,
    melSpectrogram: number[][],
    score: number,
    epochs: number = 10,
    onProgress?: (progress: ModelTrainingProgress) => void
  ): Promise<tf.History> {
    const model = this.getModel(isGlobal);

    if (!model) {
      throw new Error(`Modelo ${isGlobal ? 'global' : 'playlist'} no está inicializado`);
    }

    // Preparar datos de entrada
    const inputTensor = tf.tensor3d([melSpectrogram]);
    const outputTensor = tf.tensor1d([score]);

    try {
      // Configurar callbacks de entrenamiento
      const callbacks: tf.CustomCallbackArgs = {
        onEpochEnd: (epoch, logs) => {
          const progress: ModelTrainingProgress = {
            epoch: epoch + 1,
            loss: logs?.['loss'] || 0,
            val_loss: logs?.['val_loss'],
            acc: logs?.['acc'],
            val_acc: logs?.['val_acc']
          };

          this.trainingProgress$.next(progress);
          onProgress?.(progress);
        }
      };

      // Entrenar modelo
      const history = await model.fit(inputTensor, outputTensor, {
        epochs,
        batchSize: 1,
        callbacks,
        verbose: 0
      });

      this.updateMemoryInfo();
      return history;
    } finally {
      // Limpiar tensores temporales
      inputTensor.dispose();
      outputTensor.dispose();
    }
  }

  /**
   * Realiza predicción con el modelo especificado
   */
  async predict(isGlobal: boolean, melSpectrogram: number[][]): Promise<number> {
    const model = this.getModel(isGlobal);

    if (!model) {
      throw new Error(`Modelo ${isGlobal ? 'global' : 'playlist'} no está inicializado`);
    }

    const inputTensor = tf.tensor3d([melSpectrogram]);

    try {
      const prediction = model.predict(inputTensor) as tf.Tensor;
      const predictionValue = await prediction.data();

      return predictionValue[0];
    } finally {
      inputTensor.dispose();
    }
  }

  /**
   * Obtiene los pesos del modelo como arrays
   */
  getModelWeights(isGlobal: boolean): number[][] | null {
    const model = this.getModel(isGlobal);

    if (!model) {
      return null;
    }

    return model.getWeights().map(tensor => {
      const weights = tensor.arraySync() as number[];
      return Array.isArray(weights) ? weights : [weights];
    });
  }

  /**
   * Carga pesos en el modelo especificado
   */
  async setModelWeights(isGlobal: boolean, weights: number[][]): Promise<void> {
    const model = this.getModel(isGlobal);

    if (!model) {
      throw new Error(`Modelo ${isGlobal ? 'global' : 'playlist'} no está inicializado`);
    }

    try {
      const tensors = weights.map(weightArray => tf.tensor(weightArray));
      model.setWeights(tensors);

      this.updateMemoryInfo();
      console.info(`Pesos cargados en modelo ${isGlobal ? 'global' : 'playlist'}`);
    } catch (error) {
      console.error('Error al cargar pesos:', error);
      throw error;
    }
  }

  /**
   * Guarda el modelo en el almacenamiento local
   */
  async saveModel(isGlobal: boolean, name: string): Promise<void> {
    const model = this.getModel(isGlobal);

    if (!model) {
      throw new Error(`Modelo ${isGlobal ? 'global' : 'playlist'} no está inicializado`);
    }

    try {
      await model.save(`localstorage://${name}`);
      console.info(`Modelo ${name} guardado en almacenamiento local`);
    } catch (error) {
      console.error('Error al guardar modelo:', error);
      throw error;
    }
  }

  /**
   * Carga un modelo desde el almacenamiento local
   */
  async loadModel(isGlobal: boolean, name: string): Promise<void> {
    try {
      const model = await tf.loadLayersModel(`localstorage://${name}`) as tf.Sequential;

      if (isGlobal) {
        this.disposeModel('global');
        this.globalModel = model;
      } else {
        this.disposeModel('playlist');
        this.playlistModel = model;
      }

      this.updateMemoryInfo();
      console.info(`Modelo ${name} cargado desde almacenamiento local`);
    } catch (error) {
      console.error('Error al cargar modelo:', error);
      throw error;
    }
  }

  /**
   * Configura el número de épocas por puntuación
   */
  setEpochsConfig(config: { score1: number; score2: number; score3: number }): void {
    this.epochsConfig = { ...config };
  }

  /**
   * Obtiene la configuración de épocas
   */
  getEpochsConfig(): { score1: number; score2: number; score3: number } {
    return { ...this.epochsConfig };
  }

  /**
   * Obtiene el número de épocas para una puntuación específica
   */
  getEpochsForScore(score: number): number {
    const key = `score${score}` as keyof typeof this.epochsConfig;
    return this.epochsConfig[key] || 10;
  }

  /**
   * Libera recursos de memoria de TensorFlow
   */
  dispose(): void {
    this.disposeModel('global');
    this.disposeModel('playlist');
    this.cleanupMemory();
    this.isInitialized$.next(false);

    console.info('Recursos de TensorFlow liberados');
  }

  /**
   * Obtiene información detallada de memoria
   */
  getCurrentMemoryInfo(): TensorflowMemoryInfo {
    return this.memoryInfo$.value;
  }

  // Métodos privados

  private async setupOptimalBackend(): Promise<void> {
    // Intentar usar WebGL si está disponible
    if (await tf.setBackend('webgl')) {
      console.info('Backend WebGL configurado');
      return;
    }

    // Fallback a CPU
    await tf.setBackend('cpu');
    console.info('Backend CPU configurado');
  }

  private getModel(isGlobal: boolean): tf.Sequential | null {
    return isGlobal ? this.globalModel : this.playlistModel;
  }

  private disposeModel(type: 'global' | 'playlist'): void {
    const model = type === 'global' ? this.globalModel : this.playlistModel;

    if (model) {
      model.dispose();

      if (type === 'global') {
        this.globalModel = null;
      } else {
        this.playlistModel = null;
      }
    }
  }

  private buildModelLayers(model: tf.Sequential, layers: LayerConfig[]): void {
    layers.forEach((layerConfig, index) => {
      switch (layerConfig.type) {
        case 'dense':
          model.add(tf.layers.dense({
            units: layerConfig.units!,
            activation: layerConfig.activation as any,
            inputShape: index === 0 ? layerConfig.inputShape : undefined
          }));
          break;

        case 'flatten':
          model.add(tf.layers.flatten());
          break;

        case 'conv2d':
          model.add(tf.layers.conv2d({
            filters: layerConfig.filters!,
            kernelSize: layerConfig.kernelSize!,
            activation: layerConfig.activation as any,
            inputShape: index === 0 ? layerConfig.inputShape : undefined
          }));
          break;

        case 'maxPooling2d':
          model.add(tf.layers.maxPooling2d({
            poolSize: layerConfig.poolSize as [number, number] || [2, 2]
          }));
          break;
      }
    });
  }

  private getDefaultModelConfig(override?: Partial<ModelConfig>): ModelConfig {
    const defaultConfig: ModelConfig = {
      epochs: this.epochsConfig,
      architecture: {
        inputShape: [129, 20000],
        layers: [
          { type: 'dense', units: 64, activation: 'relu', inputShape: [129, 20000] },
          { type: 'flatten' },
          { type: 'dense', units: 32, activation: 'relu' },
          { type: 'dense', units: 1, activation: 'linear' }
        ]
      },
      compilation: {
        optimizer: 'adam',
        loss: 'meanSquaredError',
        metrics: ['mae']
      }
    };

    return { ...defaultConfig, ...override };
  }

  private cleanupMemory(): void {
    tf.engine().startScope();
    tf.disposeVariables();
    tf.engine().endScope();
    tf.engine().reset();
  }

  private updateMemoryInfo(): void {
    const memInfo = tf.memory();
    this.memoryInfo$.next({
      numTensors: memInfo.numTensors,
      numDataBuffers: memInfo.numDataBuffers,
      numBytes: memInfo.numBytes,
      reasons: memInfo.reasons || []
    });
  }
}
