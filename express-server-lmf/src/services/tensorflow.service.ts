import * as tf from '@tensorflow/tfjs';
import path from 'path';
import fs from 'fs';
import { paths } from '../main';
import SongModel from '../models/song.model';
import TsModelModel from '../models/tensorflow-db.model';
import CalibrationModel from '../models/calibration.model';
import PlaylistModel from '../models/playlist.model';
import { Song, TsModel, Calibration } from '../types/generals.models';

// ─── Configuración por defecto ───────────────────────────────────────────────
const DEFAULT_CONFIG = {
  epochs: 50,
  batchSize: 32,
  learningRate: 0.001,
  numClasses: 4,
  inputDim: 128, // VGGish embedding dimension
  validationSplit: 0.2,
};

const ARCHITECTURE_JSON = JSON.stringify({
  type: 'sequential',
  layers: [
    { type: 'dense', units: 64, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.3 },
    { type: 'dense', units: 32, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.3 },
    { type: 'dense', units: 4, activation: 'softmax' }
  ]
});

// ─── Lock global de entrenamiento ────────────────────────────────────────────
let trainingInProgress = false;

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

  // Verificar que no es Fortran order
  if (headerStr.includes("'fortran_order': True")) {
    throw new Error('Archivos .npy en Fortran order no están soportados');
  }

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

// ─── Creación de modelo ──────────────────────────────────────────────────────
/**
 * Crea la arquitectura del modelo de clasificación.
 * Input: (128) mean-pooled VGGish embeddings
 * Output: (4) probabilidades por clase (scores 0-3)
 */
function createModelArchitecture(
  inputDim: number = DEFAULT_CONFIG.inputDim,
  numClasses: number = DEFAULT_CONFIG.numClasses
): tf.Sequential {
  const model = tf.sequential();

  model.add(tf.layers.dense({
    inputShape: [inputDim],
    units: 64,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));
  model.add(tf.layers.dropout({ rate: 0.3 }));

  model.add(tf.layers.dense({
    units: 32,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));
  model.add(tf.layers.dropout({ rate: 0.3 }));

  model.add(tf.layers.dense({
    units: numClasses,
    activation: 'softmax'
  }));

  return model;
}

/**
 * Compila un modelo con el optimizador y métricas estándar
 */
function compileModel(model: tf.LayersModel, learningRate: number = DEFAULT_CONFIG.learningRate): void {
  model.compile({
    optimizer: tf.train.adam(learningRate),
    loss: 'sparseCategoricalCrossentropy',
    metrics: ['accuracy']
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
      features.push(pooled);
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

      let localModel: TsModel | null = null;

      if (playlist.modelId) {
        localModel = await TsModelModel.getById(playlist.modelId);
      }

      if (!localModel) {
        logInfo(`Creando modelo local para playlist "${playlist.name}" (ID: ${playlistId})...`);
        localModel = await createAndRegisterModel(false, `model_local_pl${playlistId}`);
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
async function createAndRegisterModel(isGlobal: boolean, dirName: string): Promise<TsModel> {
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
  tsModel: TsModel,
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

  // Log de distribución de clases
  const classCount = [0, 0, 0, 0];
  labels.forEach(l => classCount[l]++);
  logInfo(`Canciones a entrenar: ${features.length}`);
  logInfo(`Distribución de clases: 0=${classCount[0]}, 1=${classCount[1]}, 2=${classCount[2]}, 3=${classCount[3]}`);

  // Cargar modelo desde disco
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, tsModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');

  let model: tf.LayersModel;

  if (fs.existsSync(modelJsonPath)) {
    model = await tf.loadLayersModel(nodeLoadHandler(modelPath));
  } else {
    logInfo('Archivo de modelo no encontrado en disco. Recreando arquitectura...');
    model = createModelArchitecture(tsModel.inputDim, tsModel.numClasses);
  }

  compileModel(model, tsModel.learningRate);

  // Convertir a tensores
  const xData = new Float32Array(features.length * DEFAULT_CONFIG.inputDim);
  features.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  const xs = tf.tensor2d(xData, [features.length, DEFAULT_CONFIG.inputDim]);
  const ys = tf.tensor1d(labels, 'int32');

  // Entrenar
  const epochs = DEFAULT_CONFIG.epochs;
  const batchSize = Math.min(DEFAULT_CONFIG.batchSize, features.length);
  const useValidation = features.length >= 10;

  logInfo(`Fit: ${features.length} muestras, ${epochs} épocas, batch=${batchSize}, validación=${useValidation}`);

  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs,
    batchSize,
    validationSplit: useValidation ? DEFAULT_CONFIG.validationSplit : 0,
    shuffle: true,
    callbacks: {
      onEpochEnd: (epoch, logs) => {
        if ((epoch + 1) % 10 === 0 || epoch === 0) {
          const loss = logs?.loss?.toFixed(4) ?? '?';
          const acc = (logs?.acc ?? logs?.accuracy)?.toFixed(4) ?? '?';
          logInfo(`  Época ${epoch + 1}/${epochs} — loss: ${loss} | acc: ${acc}`);
        }
      }
    }
  });

  // Obtener métricas finales
  const lossArr = history.history['loss'] as number[];
  const accArr = (history.history['acc'] || history.history['accuracy']) as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  const finalAcc = accArr[accArr.length - 1];

  logSuccess(`Entrenamiento completado — loss: ${finalLoss.toFixed(4)} | acc: ${finalAcc.toFixed(4)}`);

  // Guardar modelo actualizado a disco
  if (!fs.existsSync(modelPath)) {
    fs.mkdirSync(modelPath, { recursive: true });
  }
  await model.save(nodeSaveHandler(modelPath));
  logSuccess(`Modelo guardado en: ${modelPath}`);

  // Actualizar registro del modelo en BD
  const newVersion = (tsModel.version || 1) + 1;
  const newTrainedSongs = (tsModel.trainedSongs || 0) + features.length;
  const newEpochs = (tsModel.completedEpochs || 0) + epochs;

  await TsModelModel.updateAfterTraining(tsModel.id!, {
    trainedSongs: newTrainedSongs,
    completedEpochs: newEpochs,
    loss: finalLoss,
    accuracy: finalAcc,
    version: newVersion
  });

  // Obtener predicciones para calibración y actualización de canciones
  const predictions = model.predict(xs) as tf.Tensor;
  const predArray = await predictions.array() as number[][];

  // Preparar registros de calibración (batch)
  const now = new Date();
  const calibrationEntries: Omit<Calibration, 'id'>[] = [];

  for (let i = 0; i < trainSongIds.length; i++) {
    const probs = predArray[i];
    const globalScore = probs[0] * 0 + probs[1] * 1 + probs[2] * 2 + probs[3] * 3;

    calibrationEntries.push({
      songId: trainSongIds[i],
      modelId: tsModel.id!,
      interactionType: 'fit',
      interactionDate: now,
      globalScore,
      userScore: labels[i],
      configEpochs: epochs,
      probScore0: probs[0],
      probScore1: probs[1],
      probScore2: probs[2],
      probScore3: probs[3],
      loss: finalLoss,
      accuracy: finalAcc,
      learningRate: tsModel.learningRate,
      batchSize
    });

    // Actualizar resultados en la canción
    const songUpdate: Parameters<typeof SongModel.updateTrainingResults>[1] = {};

    if (modelType === 'global') {
      const currentSong = songs.find(s => s.id === trainSongIds[i]);
      songUpdate.trainLevelGlobal = (currentSong?.tsTrainLevelGlobal || 0) + 1;
      songUpdate.globalScore = globalScore;
      songUpdate.probScore0 = probs[0];
      songUpdate.probScore1 = probs[1];
      songUpdate.probScore2 = probs[2];
      songUpdate.probScore3 = probs[3];
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
  predictions.dispose();
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