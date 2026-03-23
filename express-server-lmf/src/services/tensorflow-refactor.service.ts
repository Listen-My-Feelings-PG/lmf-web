import path from "path";
import * as tf from '@tensorflow/tfjs';
import fs from 'fs';
import { TensorFlowModel } from "../types/generals.models";
import TsModelModel from "../models/tensorflow-db.model";

export async function createAndStorageTsModel(isGlobal: boolean, idPlaylist?: number): Promise<TensorFlowModel> {
  const modelsDir = path.resolve(process.env.MODELS_PATH || '');
  if (!modelsDir)
    throw new Error('Ruta de modelos no configurada en .env');

  const modelPath = path.join(modelsDir, isGlobal ? 'model_global' : `model_playlist_${idPlaylist}`);
  if (!fs.existsSync(modelPath))
    fs.mkdirSync(modelPath, { recursive: true });

  const model = createModelArchitecture(parseInt(process.env.TS_CONFIG_DEAFULT_INPUT_DIM || '0'));
  const learningRate = parseFloat(process.env.TS_CONFIG_DEAFULT_LEARNING_RATE || '0');
  if (isNaN(learningRate) || learningRate <= 0)
    throw new Error('Learning rate inválido en configuración. Debe ser un número positivo.');

  model.compile({
    optimizer: tf.train.adam(learningRate),
    loss: 'meanSquaredError',
    metrics: ['mae']
  });

  await model.save(nodeSaveHandler(modelPath));
  model.dispose();

  // Registrar en BD
  const tsModel = await TsModelModel.create({
    isGlobal,
    filename: '',//dirName,
    trainedSongs: 0,
    completedEpochs: 0,
    loss: 0,
    accuracy: 0,
    version: 1,
    learningRate: 0,//DEFAULT_CONFIG.learningRate,
    batchSize: 0,//DEFAULT_CONFIG.batchSize,
    numClasses: 0,//DEFAULT_CONFIG.numClasses,
    inputDim: 0,//DEFAULT_CONFIG.inputDim,
    architecture: ''//ARCHITECTURE_JSON
  });

  return tsModel;
}

// ─── Creación de modelo ──────────────────────────────────────────────────────
/**
 * Crea la arquitectura del modelo de clasificación.
 *
 * ── Visión general ──────────────────────────────────────────────────────────
 * Red neuronal feedforward (MLP) de regresión diseñada para predecir una
 * calificación continua (0-3) a partir de embeddings de audio VGGish.
 *
 * ── Flujo de datos ──────────────────────────────────────────────────────────
 *
 *   Input (128)          Vector mean-pooled de embeddings VGGish.
 *       ▼
 *   Dense (128 → 64)     ReLU + He Normal.
 *       ▼
 *   Dropout (30%)
 *       ▼
 *   Dense (64 → 32)      ReLU + He Normal.
 *       ▼
 *   Dropout (30%)
 *       ▼
 *   Dense (32 → 1)       Sigmoid → salida en [0,1], escalada × 3 → [0,3].
 *       ▼
 *   Output (1)           Calificación nominal continua en rango [0, 3].
 *
 * ── Resumen de parámetros ───────────────────────────────────────────────────
 *   Capa 1 (Dense):  128×64 + 64 bias  =  8.256 parámetros
 *   Capa 2 (Dense):   64×32 + 32 bias  =  2.080 parámetros
 *   Capa 3 (Dense):    32×1 +  1 bias  =     33 parámetros
 *   ─────────────────────────────────────────────────
 *   Total:                                 10.369 parámetros entrenables
 */
function createModelArchitecture(
  inputDim: number
): tf.Sequential {
  if (inputDim < 1)
    throw new Error('Dimensión de entrada inválida para el modelo. Debe ser un entero positivo.');
  const model = tf.sequential();

  // Capa 1: Proyección del espacio de embeddings (128-dim) a representación interna (64-dim)
  model.add(tf.layers.dense({
    inputShape: [inputDim],
    units: 64,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));

  // Regularización: apaga 30% de neuronas al azar durante entrenamiento
  model.add(tf.layers.dropout({ rate: 0.3 }));

  // Capa 2: Compresión adicional a 32-dim para capturar patrones de alto nivel
  model.add(tf.layers.dense({
    units: 32,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));

  // Regularización: segunda barrera contra overfitting
  model.add(tf.layers.dropout({ rate: 0.3 }));

  // Capa de salida: 1 neurona con sigmoid → [0,1], se escala × 3 → [0,3]
  model.add(tf.layers.dense({
    units: 1,
    activation: 'sigmoid'
  }));

  return model;
}

function nodeSaveHandler(dirPath: string): tf.io.IOHandler {
  return {
    async save(modelArtifacts: tf.io.ModelArtifacts): Promise<tf.io.SaveResult> {
      if (!fs.existsSync(dirPath)) fs.mkdirSync(dirPath, { recursive: true });

      const weightsPath = path.join(dirPath, 'weights.bin');
      const modelJsonPath = path.join(dirPath, 'model.json');

      // Guardar pesos binarios
      if (modelArtifacts.weightData) {
        const weightBuffer = Buffer.from(
          modelArtifacts.weightData instanceof ArrayBuffer
            ? modelArtifacts.weightData
            : (modelArtifacts.weightData as ArrayBuffer[])[0]
        );
        fs.writeFileSync(weightsPath, weightBuffer);
      }

      // Construir model.json
      const modelJSON: any = {
        modelTopology: modelArtifacts.modelTopology,
        format: modelArtifacts.format,
        generatedBy: modelArtifacts.generatedBy,
        convertedBy: modelArtifacts.convertedBy,
        weightsManifest: [{
          paths: ['weights.bin'],
          weights: modelArtifacts.weightSpecs || []
        }]
      };

      if (modelArtifacts.trainingConfig) {
        modelJSON.trainingConfig = modelArtifacts.trainingConfig;
      }

      fs.writeFileSync(modelJsonPath, JSON.stringify(modelJSON), 'utf-8');

      return {
        modelArtifactsInfo: {
          dateSaved: new Date(),
          modelTopologyType: 'JSON'
        }
      };
    }
  };
}