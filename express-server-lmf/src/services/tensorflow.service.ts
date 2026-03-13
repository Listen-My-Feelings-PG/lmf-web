import * as tf from '@tensorflow/tfjs';
import path from 'path';
import fs from 'fs';
import { paths } from '../main';
import SongModel from '../models/song.model';
import TsModelModel from '../models/tensorflow-db.model';
import CalibrationModel from '../models/calibration.model';
import PlaylistModel from '../models/playlist.model';
import { Song, TensorFlowModel, Calibration } from '../types/generals.models';

// ─── Configuración por defecto ───────────────────────────────────────────────
const DEFAULT_CONFIG = {
  epochs: parseInt(process.env.TS_CONFIG_DEAFULT_EPOCHS || '200'),
  batchSize: parseInt(process.env.TS_CONFIG_DEAFULT_BATCH_SIZE || '32'),
  learningRate: parseFloat(process.env.TS_CONFIG_DEAFULT_LEARNING_RATE || '0.001'),
  numClasses: parseInt(process.env.TS_CONFIG_DEAFULT_NUM_CLASSES || '4'),
  inputDim: parseInt(process.env.TS_CONFIG_DEAFULT_INPUT_DIM || '128'), // VGGish embedding dimension
  validationSplit: parseFloat(process.env.TS_CONFIG_DEAFULT_VALIDATION_SPLIT || '0.2'),
};

const ARCHITECTURE_JSON = JSON.stringify({
  type: 'sequential',
  layers: [
    { type: 'dense', units: 64, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.3 },
    { type: 'dense', units: 32, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.3 },
    { type: 'dense', units: 1, activation: 'sigmoid', note: 'output * 3 → rango [0,3]' }
  ]
});

// ─── Locks globales ──────────────────────────────────────────────────────────
let trainingInProgress = false;
let predictionInProgress = false;

// ─── Helpers de consola ──────────────────────────────────────────────────────
const TAG = '[TensorFlow]';
function logInfo(msg: string): void { console.info(`${TAG} ${msg}`); }
function logSuccess(msg: string): void { console.info(`${TAG} ✓ ${msg}`); }
function logError(msg: string): void { console.error(`${TAG} ✗ ${msg}`); }

/**
 * Indica si hay un proceso de entrenamiento activo
 */
export function isTrainingActive(): boolean {
  return trainingInProgress;
}

/**
 * Indica si hay un proceso de predicción activo
 */
export function isPredictionActive(): boolean {
  return predictionInProgress;
}

// ─── Lector de archivos .npy ─────────────────────────────────────────────────
/**
 * Lee un archivo .npy (NumPy binary) y retorna Float32Array + shape.
 * Soporta float32 (<f4) y float64 (<f8, convertido a f32).
 */
function readNpy(filePath: string): { data: Float32Array; shape: number[] } {
  const buf = fs.readFileSync(filePath);

  // Magic: \x93NUMPY
  if (buf[0] !== 0x93 || buf.toString('ascii', 1, 6) !== 'NUMPY') {
    throw new Error(`Archivo .npy inválido: ${filePath}`);
  }

  const majorVersion = buf[6];
  let headerLen: number;
  let dataStart: number;

  if (majorVersion === 1) {
    headerLen = buf.readUInt16LE(8);
    dataStart = 10 + headerLen;
  } else {
    headerLen = buf.readUInt32LE(8);
    dataStart = 12 + headerLen;
  }

  const headerStr = buf.toString('ascii', majorVersion === 1 ? 10 : 12, dataStart);

  // Detectar Fortran order (column-major)
  const isFortran = headerStr.includes("'fortran_order': True");

  // Parsear shape: 'shape': (N, 128,)
  const shapeMatch = headerStr.match(/'shape':\s*\(([^)]+)\)/);
  if (!shapeMatch) throw new Error(`No se puede parsear shape del header .npy: ${filePath}`);
  const shape = shapeMatch[1].split(',').map(s => parseInt(s.trim())).filter(n => !isNaN(n));

  // Parsear dtype
  const dtypeMatch = headerStr.match(/'descr':\s*'([^']+)'/);
  const dtype = dtypeMatch ? dtypeMatch[1] : '<f4';

  // Extraer datos binarios (copia alineada)
  const dataBuffer = buf.subarray(dataStart);
  const aligned = new ArrayBuffer(dataBuffer.length);
  new Uint8Array(aligned).set(dataBuffer);

  let data: Float32Array;
  if (dtype.includes('f4')) {
    data = new Float32Array(aligned);
  } else if (dtype.includes('f8')) {
    data = Float32Array.from(new Float64Array(aligned));
  } else {
    throw new Error(`Dtype no soportado: ${dtype}`);
  }

  // Transponer de Fortran order (column-major) a C order (row-major) si es necesario.
  // Fortran almacena los datos columna por columna: el elemento [i,j] está en índice j*rows + i.
  // C order los almacena fila por fila: el elemento [i,j] está en índice i*cols + j.
  // Para shape (rows, cols) hacemos la transposición en memoria.
  if (isFortran && shape.length === 2) {
    const [rows, cols] = shape;
    const transposed = new Float32Array(rows * cols);
    for (let i = 0; i < rows; i++) {
      for (let j = 0; j < cols; j++) {
        transposed[i * cols + j] = data[j * rows + i];
      }
    }
    data = transposed;
  }

  return { data, shape };
}

// ─── Helpers de features ─────────────────────────────────────────────────────
/**
 * Mean-pool de embeddings VGGish: (N, 128) → (128,)
 * Promedia los embeddings a través del tiempo para obtener un vector fijo.
 */
function meanPoolEmbeddings(data: Float32Array, shape: number[]): Float32Array {
  const [numFrames, embDim] = shape;
  const result = new Float32Array(embDim);

  for (let j = 0; j < embDim; j++) {
    let sum = 0;
    for (let i = 0; i < numFrames; i++) {
      sum += data[i * embDim + j];
    }
    result[j] = sum / numFrames;
  }

  return result;
}

/**
 * Normaliza un embedding VGGish dividiendo entre 255.
 * VGGish produce embeddings cuantizados en rango [0, 255].
 * Sin normalizar, la magnitud causa saturación de softmax y gradientes zero → mode collapse.
 */
function normalizeEmbedding(data: Float32Array): Float32Array {
  const normalized = new Float32Array(data.length);
  for (let i = 0; i < data.length; i++) {
    normalized[i] = data[i] / 255.0;
  }
  return normalized;
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
  inputDim: number = DEFAULT_CONFIG.inputDim
): tf.Sequential {
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

/**
 * Compila un modelo con el optimizador y métricas estándar
 */
function compileModel(model: tf.LayersModel, learningRate: number = DEFAULT_CONFIG.learningRate): void {
  model.compile({
    optimizer: tf.train.adam(learningRate),
    loss: 'meanSquaredError',
    metrics: ['mae']
  });
}

/**
 * IOHandler para guardar modelos TF.js al filesystem (sin tfjs-node).
 * Escribe model.json + weights.bin en el directorio indicado.
 */
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

/**
 * IOHandler para cargar modelos TF.js desde filesystem (sin tfjs-node).
 * Lee model.json + weights.bin del directorio indicado.
 */
function nodeLoadHandler(dirPath: string): tf.io.IOHandler {
  return {
    async load(): Promise<tf.io.ModelArtifacts> {
      const modelJsonPath = path.join(dirPath, 'model.json');
      const modelJSON = JSON.parse(fs.readFileSync(modelJsonPath, 'utf-8'));

      const artifacts: tf.io.ModelArtifacts = {
        modelTopology: modelJSON.modelTopology,
        format: modelJSON.format,
        generatedBy: modelJSON.generatedBy,
        convertedBy: modelJSON.convertedBy,
        weightSpecs: modelJSON.weightsManifest?.[0]?.weights || [],
        trainingConfig: modelJSON.trainingConfig
      };

      // Cargar pesos binarios
      const weightPaths: string[] = modelJSON.weightsManifest?.[0]?.paths || [];
      if (weightPaths.length > 0) {
        const buffers: Buffer[] = weightPaths.map((p: string) =>
          fs.readFileSync(path.join(dirPath, p))
        );
        const totalLen = buffers.reduce((sum, b) => sum + b.length, 0);
        const combined = new Uint8Array(totalLen);
        let offset = 0;
        for (const buf of buffers) {
          combined.set(buf, offset);
          offset += buf.length;
        }
        artifacts.weightData = combined.buffer;
      }

      return artifacts;
    }
  };
}

// ─── Preparación de datos ────────────────────────────────────────────────────
/**
 * Carga y prepara features para el entrenamiento.
 * Filtra canciones: deben tener userScore + features + (en clean: no entrenadas previamente).
 */
function prepareSongsForTraining(
  songs: Song[],
  mode: string,
  modelType: 'global' | 'local'
): { features: Float32Array[]; labels: number[]; songIds: number[] } {
  const featuresDir = path.resolve(paths.features);
  const features: Float32Array[] = [];
  const labels: number[] = [];
  const songIds: number[] = [];

  for (const song of songs) {
    // Debe tener calificación del usuario
    if (song.userScore === undefined || song.userScore === null) continue;
    // Debe tener archivo de features
    if (!song.tsFeaturesFileName) continue;

    const featurePath = path.join(featuresDir, song.tsFeaturesFileName);
    if (!fs.existsSync(featurePath)) continue;

    // En modo 'clean', solo canciones nunca entrenadas
    if (mode === 'clean') {
      const trainLevel = modelType === 'global' ? song.tsTrainLevelGlobal : song.tsTrainLevelLocal;
      if (trainLevel && trainLevel > 0) continue;
    }

    try {
      const npy = readNpy(featurePath);
      const pooled = meanPoolEmbeddings(npy.data, npy.shape);
      const normalized = normalizeEmbedding(pooled);
      features.push(normalized);
      labels.push(song.userScore);
      songIds.push(song.id!);
    } catch (err) {
      logError(`Error leyendo features de canción ${song.id}: ${err}`);
    }
  }

  return { features, labels, songIds };
}

// ─── Punto de entrada público ────────────────────────────────────────────────
/**
 * Inicia el entrenamiento en background (fire-and-forget).
 * Adquiere el lock global. Todo el progreso se loguea en consola.
 */
export function startTraining(
  songIds: number[],
  mode: string,
  includeLocalTraining: boolean
): void {
  if (trainingInProgress) {
    logError('Se intentó iniciar entrenamiento pero ya hay un proceso activo.');
    return;
  }

  trainingInProgress = true;

  runTraining(songIds, mode, includeLocalTraining)
    .catch(err => logError(`Error fatal en entrenamiento: ${err}`))
    .finally(() => {
      trainingInProgress = false;
      logInfo('Lock de entrenamiento liberado.');
    });
}

// ─── Flujo principal de entrenamiento ────────────────────────────────────────
async function runTraining(
  songIds: number[],
  mode: string,
  includeLocalTraining: boolean
): Promise<void> {
  logInfo('═'.repeat(60));
  logInfo('Iniciando entrenamiento de modelo TensorFlow');
  logInfo(`Modo: ${mode} | Entrenamiento local: ${includeLocalTraining}`);
  logInfo(`Canciones solicitadas: ${songIds.length}`);
  logInfo('═'.repeat(60));

  // 1. Obtener canciones de la BD
  const songs = await SongModel.getSongsByIds(songIds);
  logInfo(`Canciones encontradas en BD: ${songs.length}`);

  // 2. Verificar/crear modelo global
  const defaultPlaylist = await PlaylistModel.getDefaultPlaylist();
  if (!defaultPlaylist) {
    throw new Error('No existe playlist default. No se puede continuar.');
  }

  let globalModel = await TsModelModel.getGlobalModel();

  if (!globalModel) {
    logInfo('No existe modelo global. Creando...');
    globalModel = await createAndRegisterModel(true, 'model_global');
    await PlaylistModel.updateModelId(defaultPlaylist.id!, globalModel.id!);
    logSuccess(`Modelo global creado (ID: ${globalModel.id}) → playlist default (ID: ${defaultPlaylist.id})`);
  } else {
    logInfo(`Modelo global existente: ID=${globalModel.id}, v${globalModel.version}, ${globalModel.trainedSongs} canciones entrenadas`);
  }

  // 3. Entrenar modelo global
  await trainSingleModel(globalModel, songs, mode, 'global');

  // 4. Si includeLocalTraining, manejar modelos locales por playlist
  if (includeLocalTraining) {
    logInfo('─'.repeat(40));
    logInfo('Procesando modelos locales por playlist...');

    const playlistSongMap = await getPlaylistSongMap(songIds);

    for (const [playlistId, plSongIds] of playlistSongMap.entries()) {
      // La playlist default ya se entrenó como modelo global
      if (playlistId === defaultPlaylist.id) continue;

      const playlist = await PlaylistModel.getById(playlistId);
      if (!playlist) continue;

      let localModel: TensorFlowModel | null = null;

      if (playlist.modelId) {
        localModel = await TsModelModel.getById(playlist.modelId);
      }

      if (!localModel) {
        logInfo(`Creando modelo local para playlist "${playlist.name}" (ID: ${playlistId})...`);
        localModel = await createAndRegisterModel(false, `model_local_pl_${playlistId}`);
        await PlaylistModel.updateModelId(playlistId, localModel.id!);
        logSuccess(`Modelo local creado (ID: ${localModel.id}) → playlist "${playlist.name}"`);
      } else {
        logInfo(`Modelo local existente: ID=${localModel.id}, playlist "${playlist.name}"`);
      }

      const plSongs = songs.filter(s => plSongIds.includes(s.id!));
      await trainSingleModel(localModel, plSongs, mode, 'local');
    }
  }

  logInfo('═'.repeat(60));
  logInfo('Proceso de entrenamiento completado');
  logInfo('═'.repeat(60));
}

// ─── Crear y registrar modelo nuevo ──────────────────────────────────────────
async function createAndRegisterModel(isGlobal: boolean, dirName: string): Promise<TensorFlowModel> {
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, dirName);

  // Crear directorio del modelo
  if (!fs.existsSync(modelPath)) {
    fs.mkdirSync(modelPath, { recursive: true });
  }

  // Crear y guardar modelo inicializado (pesos aleatorios)
  const model = createModelArchitecture();
  compileModel(model);
  await model.save(nodeSaveHandler(modelPath));
  model.dispose();

  // Registrar en BD
  const tsModel = await TsModelModel.create({
    isGlobal,
    filename: dirName,
    trainedSongs: 0,
    completedEpochs: 0,
    loss: 0,
    accuracy: 0,
    version: 1,
    learningRate: DEFAULT_CONFIG.learningRate,
    batchSize: DEFAULT_CONFIG.batchSize,
    numClasses: DEFAULT_CONFIG.numClasses,
    inputDim: DEFAULT_CONFIG.inputDim,
    architecture: ARCHITECTURE_JSON
  });

  return tsModel;
}

// ─── Entrenar un solo modelo ─────────────────────────────────────────────────
async function trainSingleModel(
  tsModel: TensorFlowModel,
  songs: Song[],
  mode: string,
  modelType: 'global' | 'local'
): Promise<void> {
  logInfo('─'.repeat(40));
  logInfo(`Entrenando modelo ${modelType.toUpperCase()} (ID: ${tsModel.id}, v${tsModel.version})`);

  // Preparar datos
  const { features, labels, songIds: trainSongIds } = prepareSongsForTraining(songs, mode, modelType);

  if (features.length === 0) {
    logInfo('No hay canciones nuevas para entrenar en este modelo. Omitiendo.');
    return;
  }

  // Log de distribución de labels
  const classCount = [0, 0, 0, 0];
  labels.forEach(l => classCount[l]++);
  logInfo(`Canciones a entrenar: ${features.length}`);
  logInfo(`Distribución de labels: 0=${classCount[0]}, 1=${classCount[1]}, 2=${classCount[2]}, 3=${classCount[3]}`);

  // Diagnóstico: mostrar rango de features (ya normalizados)
  const allVals = features.flatMap(f => Array.from(f));
  const fMin = Math.min(...allVals.slice(0, 1000));
  const fMax = Math.max(...allVals.slice(0, 1000));
  const fMean = allVals.slice(0, 1000).reduce((a, b) => a + b, 0) / Math.min(allVals.length, 1000);
  logInfo(`Features normalizados — min: ${fMin.toFixed(4)}, max: ${fMax.toFixed(4)}, mean: ${fMean.toFixed(4)}`);

  // Cargar modelo desde disco
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, tsModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');

  let model: tf.LayersModel;

  if (fs.existsSync(modelJsonPath)) {
    model = await tf.loadLayersModel(nodeLoadHandler(modelPath));
  } else {
    logInfo('Archivo de modelo no encontrado en disco. Recreando arquitectura...');
    model = createModelArchitecture(tsModel.inputDim);
  }

  compileModel(model, tsModel.learningRate);

  // Convertir a tensores
  const xData = new Float32Array(features.length * DEFAULT_CONFIG.inputDim);
  features.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  const xs = tf.tensor2d(xData, [features.length, DEFAULT_CONFIG.inputDim]);
  // Labels normalizados a [0,1] para sigmoid: label / 3
  const ys = tf.tensor1d(labels.map(l => l / 3), 'float32');

  // Entrenar
  const epochs = DEFAULT_CONFIG.epochs;
  const batchSize = Math.min(DEFAULT_CONFIG.batchSize, features.length);
  const useValidation = features.length >= 10;

  logInfo(`Fit: ${features.length} muestras, ${epochs} épocas, batch=${batchSize}, validación=${useValidation}`);

  // Early stopping: detener si val_loss no mejora en 'patience' épocas
  let bestValLoss = Infinity;
  let patienceCounter = 0;
  const patience = 20;
  let stoppedEarly = false;

  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs,
    batchSize,
    validationSplit: useValidation ? DEFAULT_CONFIG.validationSplit : 0,
    shuffle: true,
    callbacks: {
      onEpochEnd: (epoch, logs) => {
        if ((epoch + 1) % 10 === 0 || epoch === 0) {
          const loss = logs?.loss?.toFixed(4) ?? '?';
          const mae = (logs?.mae)?.toFixed(4) ?? '?';
          const valLoss = logs?.val_loss?.toFixed(4) ?? '-';
          logInfo(`  Época ${epoch + 1}/${epochs} — loss: ${loss} | mae: ${mae} | val_loss: ${valLoss}`);
        }

        // Early stopping basado en val_loss
        if (useValidation && logs?.val_loss !== undefined) {
          if (logs.val_loss < bestValLoss) {
            bestValLoss = logs.val_loss;
            patienceCounter = 0;
          } else {
            patienceCounter++;
            if (patienceCounter >= patience) {
              logInfo(`  Early stopping en época ${epoch + 1} (val_loss no mejoró en ${patience} épocas)`);
              stoppedEarly = true;
              model.stopTraining = true;
            }
          }
        }
      }
    }
  });

  // Obtener métricas finales
  const lossArr = history.history['loss'] as number[];
  const maeArr = history.history['mae'] as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  const finalMae = maeArr[maeArr.length - 1];
  const actualEpochs = lossArr.length;

  logSuccess(`Entrenamiento completado — loss(MSE): ${finalLoss.toFixed(4)} | mae: ${finalMae.toFixed(4)} | épocas: ${actualEpochs}/${epochs}${stoppedEarly ? ' (early stop)' : ''}`);

  // Guardar modelo actualizado a disco
  if (!fs.existsSync(modelPath)) {
    fs.mkdirSync(modelPath, { recursive: true });
  }
  await model.save(nodeSaveHandler(modelPath));
  logSuccess(`Modelo guardado en: ${modelPath}`);

  // Actualizar registro del modelo en BD
  const newVersion = (tsModel.version || 1) + 1;
  const newTrainedSongs = (tsModel.trainedSongs || 0) + features.length;
  const newEpochs = (tsModel.completedEpochs || 0) + actualEpochs;

  await TsModelModel.updateAfterTraining(tsModel.id!, {
    trainedSongs: newTrainedSongs,
    completedEpochs: newEpochs,
    loss: finalLoss,
    accuracy: finalMae,
    version: newVersion
  });

  // Preparar registros de calibración (batch)
  // En modo 'fit' no se ejecutan predicciones — los campos de predicción se reservan
  // para cuando el modelo entre en modo predicción.
  const now = new Date();
  const calibrationEntries: Omit<Calibration, 'id'>[] = [];

  for (let i = 0; i < trainSongIds.length; i++) {

    // En modo 'fit' las columnas de predicción (globalScore, probScore0-3) se dejan nulas.
    // Solo se llenan cuando el modelo entra en modo predicción.
    calibrationEntries.push({
      songId: trainSongIds[i],
      modelId: tsModel.id!,
      interactionType: 'fit',
      interactionDate: now,
      userScore: labels[i],
      configEpochs: epochs,
      loss: finalLoss,
      accuracy: null,
      learningRate: tsModel.learningRate,
      batchSize
    });

    // Actualizar resultados en la canción
    // En modo 'fit' solo se incrementa el trainLevel. Los campos de predicción
    // (globalScore, probScore0-3) se reservan para cuando el modelo entre en modo predicción.
    const songUpdate: Parameters<typeof SongModel.updateTrainingResults>[1] = {};

    if (modelType === 'global') {
      const currentSong = songs.find(s => s.id === trainSongIds[i]);
      songUpdate.trainLevelGlobal = (currentSong?.tsTrainLevelGlobal || 0) + 1;
    } else {
      const currentSong = songs.find(s => s.id === trainSongIds[i]);
      songUpdate.trainLevelLocal = (currentSong?.tsTrainLevelLocal || 0) + 1;
    }

    await SongModel.updateTrainingResults(trainSongIds[i], songUpdate);
  }

  // Insertar calibración en batch
  await CalibrationModel.createBatch(calibrationEntries);
  logSuccess(`${calibrationEntries.length} registros de calibración guardados`);

  // Limpiar tensores
  xs.dispose();
  ys.dispose();
  model.dispose();
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
/**
 * Obtiene un mapa de playlistId → songIds para las canciones dadas
 */
async function getPlaylistSongMap(songIds: number[]): Promise<Map<number, number[]>> {
  const relations = await SongModel.getPlaylistRelations(songIds);
  const map = new Map<number, number[]>();

  for (const rel of relations) {
    if (!map.has(rel.playlistId)) {
      map.set(rel.playlistId, []);
    }
    map.get(rel.playlistId)!.push(rel.songId);
  }

  return map;
}

// ─── Predicción ──────────────────────────────────────────────────────────────
/**
 * Inicia la predicción en background (fire-and-forget).
 * Adquiere el lock de predicción. Todo el progreso se loguea en consola.
 */
export function startPrediction(songIds: number[]): void {
  if (predictionInProgress) {
    logError('Se intentó iniciar predicción pero ya hay un proceso activo.');
    return;
  }

  predictionInProgress = true;

  runPrediction(songIds)
    .catch(err => logError(`Error fatal en predicción: ${err}`))
    .finally(() => {
      predictionInProgress = false;
      logInfo('Lock de predicción liberado.');
    });
}

/**
 * Flujo principal de predicción.
 * Carga el modelo global, ejecuta predict sobre cada canción y
 * publica los resultados en las tablas `canciones` y `calibracion`.
 */
async function runPrediction(songIds: number[]): Promise<void> {
  logInfo('═'.repeat(60));
  logInfo('Iniciando predicción de canciones');
  logInfo(`Canciones solicitadas: ${songIds.length}`);
  logInfo('═'.repeat(60));

  // 1. Obtener canciones de la BD
  const songs = await SongModel.getSongsByIds(songIds);
  logInfo(`Canciones encontradas en BD: ${songs.length}`);

  if (songs.length === 0) {
    logInfo('No se encontraron canciones. Abortando predicción.');
    return;
  }

  // 2. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) {
    throw new Error('No existe modelo global entrenado. Entrene un modelo primero.');
  }
  logInfo(`Modelo global: ID=${globalModel.id}, v${globalModel.version}, ${globalModel.trainedSongs} canciones entrenadas`);

  // 3. Cargar modelo desde disco
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');

  if (!fs.existsSync(modelJsonPath)) {
    throw new Error(`Archivo de modelo no encontrado en disco: ${modelJsonPath}`);
  }

  const model = await tf.loadLayersModel(nodeLoadHandler(modelPath));
  compileModel(model, globalModel.learningRate);
  logSuccess('Modelo global cargado desde disco');

  // 4. Predecir cada canción
  const featuresDir = path.resolve(paths.features);
  const now = new Date();
  const calibrationEntries: Omit<Calibration, 'id'>[] = [];
  let predicted = 0;
  let skipped = 0;

  for (const song of songs) {
    if (!song.tsFeaturesFileName) {
      logInfo(`  Canción ${song.id}: sin archivo de features. Omitiendo.`);
      skipped++;
      continue;
    }

    const featurePath = path.join(featuresDir, song.tsFeaturesFileName);
    if (!fs.existsSync(featurePath)) {
      logInfo(`  Canción ${song.id}: archivo de features no encontrado (${song.tsFeaturesFileName}). Omitiendo.`);
      skipped++;
      continue;
    }

    try {
      // Leer y procesar features
      const npy = readNpy(featurePath);
      const pooled = meanPoolEmbeddings(npy.data, npy.shape);
      const normalized = normalizeEmbedding(pooled);

      // Crear tensor de entrada (1, 128)
      const input = tf.tensor2d([Array.from(normalized)], [1, DEFAULT_CONFIG.inputDim]);
      const prediction = model.predict(input) as tf.Tensor;
      const rawOutput = await prediction.data();

      // Sigmoid produce [0,1], escalar × 3 → [0,3]
      const globalScore = rawOutput[0] * 3;

      // Calcular precisión: 100 - (|predicción - userScore| / 3) * 100
      const hasUserScore = song.userScore !== undefined && song.userScore !== null;
      const userScore = song.userScore ?? 0;
      const predictionAccuracy = hasUserScore
        ? Math.max(0, 100 - (Math.abs(globalScore - userScore) / 3) * 100)
        : null;

      logInfo(`  Canción ${song.id}: predicción=${globalScore.toFixed(4)} | usuario=${hasUserScore ? userScore : 'N/A'} | precisión=${predictionAccuracy !== null ? predictionAccuracy.toFixed(1) + '%' : 'N/A'}`);

      // Actualizar tabla canciones
      await SongModel.updateTrainingResults(song.id!, {
        globalScore
      });

      // Preparar entrada de calibración
      calibrationEntries.push({
        songId: song.id!,
        modelId: globalModel.id!,
        interactionType: 'predict',
        interactionDate: now,
        globalScore,
        userScore,
        configEpochs: globalModel.completedEpochs,
        loss: globalModel.loss,
        accuracy: predictionAccuracy,
        learningRate: globalModel.learningRate,
        batchSize: globalModel.batchSize
      });

      predicted++;

      // Limpiar tensores de esta iteración
      input.dispose();
      prediction.dispose();
    } catch (err) {
      logError(`  Error prediciendo canción ${song.id}: ${err}`);
      skipped++;
    }
  }

  // 5. Insertar registros de calibración en batch
  if (calibrationEntries.length > 0) {
    await CalibrationModel.createBatch(calibrationEntries);
    logSuccess(`${calibrationEntries.length} registros de calibración guardados`);
  }

  // 6. Limpiar modelo
  model.dispose();

  logInfo('─'.repeat(40));
  logSuccess(`Predicción completada: ${predicted} predichas, ${skipped} omitidas`);
  logInfo('═'.repeat(60));
}

// ─── Fine-tuning de canción individual ──────────────────────────────────────
/**
 * Fine-tune del modelo global sobre una sola canción y predicción inmediata.
 * Usa learning rate reducido y pocas épocas para ajustar sin olvido catastrófico.
 * Retorna la canción actualizada con nueva predicción y precisión.
 */
export async function tuneSingleSongById(songId: number): Promise<Song> {
  logInfo('─'.repeat(40));
  logInfo(`Fine-tuning canción ${songId}`);

  // 1. Obtener canción
  const song = await SongModel.getSongById(songId);
  if (!song) throw new Error(`Canción ${songId} no encontrada`);
  if (song.userScore === undefined || song.userScore === null)
    throw new Error(`Canción ${songId} no tiene calificación del usuario`);
  if (!song.tsFeaturesFileName)
    throw new Error(`Canción ${songId} no tiene archivo de features`);

  // 2. Cargar features
  const featuresDir = path.resolve(paths.features);
  const featurePath = path.join(featuresDir, song.tsFeaturesFileName);
  if (!fs.existsSync(featurePath))
    throw new Error(`Archivo de features no encontrado: ${featurePath}`);

  const npy = readNpy(featurePath);
  const pooled = meanPoolEmbeddings(npy.data, npy.shape);
  const normalized = normalizeEmbedding(pooled);

  // 3. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) throw new Error('No existe modelo global entrenado');

  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');
  if (!fs.existsSync(modelJsonPath))
    throw new Error(`Archivo de modelo no encontrado: ${modelJsonPath}`);

  const model = await tf.loadLayersModel(nodeLoadHandler(modelPath));

  // Fine-tune: LR reducido (1/10) para no destruir el conocimiento previo
  const tuneLr = globalModel.learningRate / 10;
  const tuneEpochs = 10;
  compileModel(model, tuneLr);

  // 4. Fine-tune con la canción
  const featureArray = Array.from(normalized);
  const xs = tf.tensor2d([featureArray], [1, DEFAULT_CONFIG.inputDim]);
  const ys = tf.tensor1d([song.userScore / 3], 'float32');

  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs: tuneEpochs,
    batchSize: 1,
    shuffle: false,
  });

  const lossArr = history.history['loss'] as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  logInfo(`  Fine-tune completado — loss: ${finalLoss.toFixed(6)} (${tuneEpochs} épocas, lr=${tuneLr})`);

  // 5. Guardar modelo
  await model.save(nodeSaveHandler(modelPath));

  // 6. Predecir inmediatamente
  const input = tf.tensor2d([featureArray], [1, DEFAULT_CONFIG.inputDim]);
  const prediction = model.predict(input) as tf.Tensor;
  const rawOutput = await prediction.data();
  const globalScore = rawOutput[0] * 3;
  const predictionAccuracy = Math.max(0, 100 - (Math.abs(globalScore - song.userScore) / 3) * 100);

  logSuccess(`  Canción ${songId}: predicción=${globalScore.toFixed(4)} | usuario=${song.userScore} | precisión=${predictionAccuracy.toFixed(1)}%`);

  // 7. Actualizar BD
  await SongModel.updateTrainingResults(songId, { globalScore });

  const now = new Date();
  await CalibrationModel.create({
    songId,
    modelId: globalModel.id!,
    interactionType: 'infer',
    interactionDate: now,
    globalScore,
    userScore: song.userScore,
    configEpochs: tuneEpochs,
    loss: finalLoss,
    accuracy: predictionAccuracy,
    learningRate: tuneLr,
    batchSize: 1
  });

  // Actualizar versión del modelo
  await TsModelModel.updateAfterTraining(globalModel.id!, {
    trainedSongs: globalModel.trainedSongs,
    completedEpochs: (globalModel.completedEpochs || 0) + tuneEpochs,
    loss: finalLoss,
    accuracy: globalModel.accuracy,
    version: (globalModel.version || 1) + 1
  });

  // Limpiar tensores
  xs.dispose();
  ys.dispose();
  input.dispose();
  prediction.dispose();
  model.dispose();

  logSuccess(`Fine-tuning y predicción completados para canción ${songId}`);

  // Retornar canción actualizada
  const updatedSong = await SongModel.getSongById(songId);
  if (!updatedSong) throw new Error(`No se pudo obtener canción actualizada ${songId}`);
  updatedSong.accuracy = predictionAccuracy;
  return updatedSong;
}