import * as tf from '@tensorflow/tfjs';
import path from 'path';
import fs from 'fs';
import { paths } from '../main';
import SongModel from '../models/song.model';
import TsModelModel from '../models/tensorflow-db.model';
import { TrainingRecordModel, PredictionRecordModel } from '../models/calibration.model';
import type { TrainingEntry, PredictionEntry } from '../models/calibration.model';
import PlaylistModel from '../models/playlist.model';
import { Song, TensorFlowModel } from '../types/generals.models';
import { getCachedFeature, invalidateFeatureCache } from '../subprocess/feature-cache.process';
import { nodeSaveHandler, nodeLoadHandler } from './filesystem.service';

// ─── Configuración por defecto ───────────────────────────────────────────────
const DEFAULT_CONFIG = {
  epochs: parseInt(process.env.TS_CONFIG_DEAFULT_EPOCHS || '200'),
  batchSize: parseInt(process.env.TS_CONFIG_DEAFULT_BATCH_SIZE || '32'),
  learningRate: parseFloat(process.env.TS_CONFIG_DEAFULT_LEARNING_RATE || '0.001'),
  numClasses: parseInt(process.env.TS_CONFIG_DEAFULT_NUM_CLASSES || '4'),
  inputDim: parseInt(process.env.TS_CONFIG_DEAFULT_INPUT_DIM || '304'), // VGGish (128) + Librosa (24) -> 152 * 2 = 304
  validationSplit: parseFloat(process.env.TS_CONFIG_DEAFULT_VALIDATION_SPLIT || '0.2'),
  fineTuningEpochs: parseInt(process.env.TS_CONFIG_DEAFULT_FINE_TUNING_EPOCHS || '5'),
};

const ARCHITECTURE_JSON = JSON.stringify({
  type: 'sequential',
  layers: [
    { type: 'dense', units: 256, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.2 },
    { type: 'dense', units: 128, activation: 'relu', init: 'heNormal' },
    { type: 'dropout', rate: 0.2 },
    { type: 'dense', units: 4, activation: 'softmax', note: 'clasificación 4 clases' }
  ]
});

// ─── Helpers de consola ──────────────────────────────────────────────────────
const TAG = '[TensorFlow]';
function logInfo(msg: string): void { console.info(`${TAG} ${msg}`); }
function logSuccess(msg: string): void { console.info(`${TAG} ✓ ${msg}`); }
function logError(msg: string): void { console.error(`${TAG} ✗ ${msg}`); }

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
    units: 256,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));

  // Regularización
  model.add(tf.layers.dropout({ rate: 0.2 }));

  model.add(tf.layers.dense({
    units: 128,
    activation: 'relu',
    kernelInitializer: 'heNormal'
  }));

  // Regularización: segunda barrera contra overfitting
  model.add(tf.layers.dropout({ rate: 0.2 }));

  // Capa de salida: 4 neuronas (probabilidades para 0, 1, 2, 3)
  model.add(tf.layers.dense({
    units: 4,
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
    loss: 'categoricalCrossentropy',
    metrics: ['accuracy']
  });
}

/**
 * Crea un dataset balanceado a partir de listas de features y labels.
 * Aplica sobremuestreo a las clases minoritarias y énfasis a las calificaciones >= 2.
 */
function buildBalancedDataset(features: Float32Array[], labels: number[]): { balancedFeatures: Float32Array[], balancedLabels: number[] } {
  const classCountArray = [0, 0, 0, 0];
  labels.forEach(l => classCountArray[l]++);
  const maxCount = Math.max(...classCountArray);

  const balancedFeatures: Float32Array[] = [];
  const balancedLabels: number[] = [];

  labels.forEach((label, index) => {
    const count = classCountArray[label];
    let weight = count > 0 ? Math.round(maxCount / count) : 1;

    // Énfasis extra para calificaciones altas
    if (label >= 2) {
      weight = Math.round(weight * 2);
    }

    for (let i = 0; i < weight; i++) {
      balancedFeatures.push(features[index]);
      balancedLabels.push(label);
    }
  });

  return { balancedFeatures, balancedLabels };
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

    // En modo 'clean', solo canciones nunca entrenadas
    if (mode === 'clean') {
      const trainLevel = modelType === 'global' ? song.tsTrainLevelGlobal : song.tsTrainLevelLocal;
      if (trainLevel && trainLevel > 0) continue;
    }

    const normalized = getCachedFeature(song.id!, song.tsFeaturesFileName, featuresDir);
    if (!normalized) continue;

    features.push(normalized);
    labels.push(song.userScore);
    songIds.push(song.id!);
  }

  return { features, labels, songIds };
}

// ─── Flujo principal de entrenamiento ────────────────────────────────────────
export async function runTraining(
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

  // Invalida caché para recalcular con la nueva dimensión
  invalidateFeatureCache();
  logInfo('Caché de características de audio invalidada.');

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

    for (const [idPlaylist, plSongIds] of playlistSongMap.entries()) {
      // La playlist default ya se entrenó como modelo global
      if (idPlaylist === defaultPlaylist.id) continue;

      const playlist = await PlaylistModel.getById(idPlaylist);
      if (!playlist) continue;

      let localModel: TensorFlowModel | null = null;

      if (playlist.modelId) {
        localModel = await TsModelModel.getById(playlist.modelId);
      }

      if (!localModel) {
        logInfo(`Creando modelo local para playlist "${playlist.name}" (ID: ${idPlaylist})...`);
        localModel = await createAndRegisterModel(false, `model_local_pl_${idPlaylist}`);
        await PlaylistModel.updateModelId(idPlaylist, localModel.id!);
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
export async function createAndRegisterModel(isGlobal: boolean, dirName: string): Promise<TensorFlowModel> {
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

  // Sobremuestreo (Oversampling) manual para balancear clases minoritarias
  const { balancedFeatures, balancedLabels } = buildBalancedDataset(features, labels);

  logInfo(`  Sobremuestreo aplicado: Dataset creció de ${features.length} a ${balancedFeatures.length} muestras.`);

  // Convertir a tensores
  const xData = new Float32Array(balancedFeatures.length * DEFAULT_CONFIG.inputDim);
  balancedFeatures.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  const xs = tf.tensor2d(xData, [balancedFeatures.length, DEFAULT_CONFIG.inputDim]);
  const ys = tf.oneHot(tf.tensor1d(balancedLabels, 'int32'), 4);

  // Entrenar
  const epochs = DEFAULT_CONFIG.epochs;
  const batchSize = Math.min(DEFAULT_CONFIG.batchSize, balancedFeatures.length);
  const useValidation = balancedFeatures.length >= 10;

  logInfo(`Fit: ${balancedFeatures.length} muestras balanceadas, ${epochs} épocas, batch=${batchSize}, validación=${useValidation}`);

  // Early stopping: detener si val_loss no mejora en 'patience' épocas
  let bestValLoss = Infinity;
  let patienceCounter = 0;
  const patience = 40; // Mayor paciencia para dejar que la red memorice outliers
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
          const acc = (logs?.acc)?.toFixed(4) ?? '?';
          const valLoss = logs?.val_loss?.toFixed(4) ?? '-';
          logInfo(`  Época ${epoch + 1}/${epochs} — loss: ${loss} | acc: ${acc} | val_loss: ${valLoss}`);
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
  const accArr = history.history['acc'] as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  const finalAcc = accArr[accArr.length - 1];
  const actualEpochs = lossArr.length;

  logSuccess(`Entrenamiento completado — loss(CE): ${finalLoss.toFixed(4)} | acc: ${finalAcc.toFixed(4)} | épocas: ${actualEpochs}/${epochs}${stoppedEarly ? ' (early stop)' : ''}`);

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
    accuracy: finalAcc,
    version: newVersion
  });

  // Preparar registros de entrenamiento (batch)

  // Determinar cuáles canciones ya tienen predicciones previas (isFineTuning)
  const songsWithPredictions = await TrainingRecordModel.songsWithPredictions(trainSongIds);

  const trainingEntries: TrainingEntry[] = [];

  for (let i = 0; i < trainSongIds.length; i++) {
    trainingEntries.push({
      songId: trainSongIds[i],
      isFineTuning: songsWithPredictions.has(trainSongIds[i]),
      modelId: tsModel.id!,
      userScore: labels[i],
      epochs: actualEpochs,
      loss: finalLoss,
      batchSize,
      validationSplit: useValidation ? DEFAULT_CONFIG.validationSplit : 0,
      mae: finalAcc
    });

    // Actualizar resultados en la canción
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

  // Insertar registros de entrenamiento en batch
  await TrainingRecordModel.createBatch(trainingEntries);
  logSuccess(`${trainingEntries.length} registros de entrenamiento guardados`);

  // Limpiar tensores
  xs.dispose();
  ys.dispose();
  model.dispose();
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
/**
 * Obtiene un mapa de idPlaylist → songIds para las canciones dadas
 */
async function getPlaylistSongMap(songIds: number[]): Promise<Map<number, number[]>> {
  const relations = await SongModel.getPlaylistRelations(songIds);
  const map = new Map<number, number[]>();

  for (const rel of relations) {
    if (!map.has(rel.idPlaylist)) {
      map.set(rel.idPlaylist, []);
    }
    map.get(rel.idPlaylist)!.push(rel.songId);
  }

  return map;
}

/**
 * Flujo principal de predicción.
 * Carga el modelo global, ejecuta predict sobre cada canción y
 * publica los resultados en las tablas `canciones` y `predicciones`.
 */
export async function runPrediction(songIds: number[]): Promise < void> {
  logInfo('═'.repeat(60));
  logInfo('Iniciando predicción de canciones');
  logInfo(`Canciones solicitadas: ${songIds.length
}`);
  logInfo('═'.repeat(60));

  // 1. Obtener canciones de la BD
  const songs = await SongModel.getSongsByIds(songIds);
  logInfo(`Canciones encontradas en BD: ${ songs.length } `);

  if (songs.length === 0) {
    logInfo('No se encontraron canciones. Abortando predicción.');
    return;
  }

  // 2. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) {
    throw new Error('No existe modelo global entrenado. Entrene un modelo primero.');
  }
  logInfo(`Modelo global: ID = ${ globalModel.id }, v${ globalModel.version }, ${ globalModel.trainedSongs } canciones entrenadas`);

  // 3. Cargar modelo desde disco
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');

  if (!fs.existsSync(modelJsonPath)) {
    throw new Error(`Archivo de modelo no encontrado en disco: ${ modelJsonPath } `);
  }

  const model = await tf.loadLayersModel(nodeLoadHandler(modelPath));
  compileModel(model, globalModel.learningRate);
  logSuccess('Modelo global cargado desde disco');

  // 4. Obtener último entrenamiento para cada canción (necesario para pd_id_last_fit)
  const allSongIds = songs.map(s => s.id!);
  const lastFitMap = await TrainingRecordModel.getLastFitIdForSongs(allSongIds);

  // 5. Predecir cada canción
  const featuresDir = path.resolve(paths.features);
  const predictionEntries: PredictionEntry[] = [];
  let predicted = 0;
  let skipped = 0;

  for (const song of songs) {
    if (!song.tsFeaturesFileName) {
      logInfo(`  Canción ${ song.id }: sin archivo de features.Omitiendo.`);
      skipped++;
      continue;
    }

    const normalized = getCachedFeature(song.id!, song.tsFeaturesFileName, featuresDir);
    if (!normalized) {
      logInfo(`  Canción ${ song.id }: archivo de features no encontrado o inválido.Omitiendo.`);
      skipped++;
      continue;
    }

    const lastFitId = lastFitMap.get(song.id!);
    if (!lastFitId) {
      logInfo(`  Canción ${ song.id }: sin registro de entrenamiento previo.Omitiendo registro de predicción.`);
    }

    try {
      // Crear tensor de entrada (1, 128)
      const input = tf.tensor2d([Array.from(normalized)], [1, DEFAULT_CONFIG.inputDim]);
      const prediction = model.predict(input) as tf.Tensor;
      const rawOutput = await prediction.data();

      // Clasificación: Valor Esperado
      const globalScore = rawOutput[0]*0 + rawOutput[1]*1 + rawOutput[2]*2 + rawOutput[3]*3;

      // Calcular precisión: 100 - (|predicción - userScore| / 3) * 100
      const hasUserScore = song.userScore !== undefined && song.userScore !== null;
      const userScore = song.userScore ?? 0;
      const predictionAccuracy = hasUserScore
        ? Math.min(99.9999, Math.max(0, 100 - (Math.abs(globalScore - userScore) / 3) * 100))
        : null;

      logInfo(`  Canción ${ song.id }: predicción = ${ globalScore.toFixed(4) } | usuario=${ hasUserScore ? userScore : 'N/A' } | precisión=${ predictionAccuracy !== null ? predictionAccuracy.toFixed(1) + '%' : 'N/A' } `);

      // Actualizar tabla canciones
      await SongModel.updateTrainingResults(song.id!, {
        globalScore
      });

      // Preparar entrada de predicción (solo si hay registro de entrenamiento previo)
      if (lastFitId) {
        predictionEntries.push({
          songId: song.id!,
          modelId: globalModel.id!,
          prediction: globalScore,
          userScore: hasUserScore ? userScore : null,
          accuracy: predictionAccuracy,
          lastFitId
        });
      }

      predicted++;

      // Limpiar tensores de esta iteración
      input.dispose();
      prediction.dispose();
    } catch (err) {
      logError(`  Error prediciendo canción ${ song.id }: ${ err } `);
      skipped++;
    }
  }

  // 6. Insertar registros de predicción en batch
  if (predictionEntries.length > 0) {
    await PredictionRecordModel.createBatch(predictionEntries);
    logSuccess(`${ predictionEntries.length } registros de predicción guardados`);
  }

  // 7. Limpiar modelo
  model.dispose();

  logInfo('─'.repeat(40));
  logSuccess(`Predicción completada: ${ predicted } predichas, ${ skipped } omitidas`);
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
  logInfo(`Fine - tuning canción ${ songId } `);

  // 1. Obtener canción
  const song = await SongModel.getSongById(songId);
  if (!song) throw new Error(`Canción ${ songId } no encontrada`);
  if (song.userScore === undefined || song.userScore === null)
    throw new Error(`Canción ${ songId } no tiene calificación del usuario`);
  if (!song.tsFeaturesFileName)
    throw new Error(`Canción ${ songId } no tiene archivo de features`);

  // 2. Cargar features (con caché)
  const featuresDir = path.resolve(paths.features);
  const normalized = getCachedFeature(songId, song.tsFeaturesFileName, featuresDir);
  if (!normalized)
    throw new Error(`Archivo de features no encontrado o inválido: ${ song.tsFeaturesFileName } `);

  // 3. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) throw new Error('No existe modelo global entrenado');

  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');
  if (!fs.existsSync(modelJsonPath))
    throw new Error(`Archivo de modelo no encontrado: ${ modelJsonPath } `);

  const model = await tf.loadLayersModel(nodeLoadHandler(modelPath));

  // Fine-tune: LR reducido (1/10) para no destruir el conocimiento previo
  const tuneLr = globalModel.learningRate / 5;
  const tuneEpochs = DEFAULT_CONFIG.fineTuningEpochs;
  compileModel(model, tuneLr);

  // ─── Mini-retrain homogéneo: cargar TODAS las canciones calificadas ───
  // Usa el mismo dataset que clean training, pero con la canción objetivo
  // duplicada TARGET_WEIGHT veces para sesgar el gradiente hacia ella.
  // TARGET_WEIGHT escala con el dataset para mantener ~10% de presencia.
  const allScoredSongs = await SongModel.getAllSongsScoredByUserInDefaultPlaylist();
  
  const baseFeatures: Float32Array[] = [];
  const baseLabels: number[] = [];

  // Recolectar TODAS las demás canciones
  for (const s of allScoredSongs) {
    if (s.id === songId) continue;
    if (!s.tsFeaturesFileName || s.userScore === undefined || s.userScore === null) continue;
    const sNormalized = getCachedFeature(s.id!, s.tsFeaturesFileName, featuresDir);
    if (!sNormalized) continue;
    baseFeatures.push(sNormalized);
    baseLabels.push(s.userScore);
  }

  // Balancear la base al igual que en Clean Training
  const { balancedFeatures: allFeatures, balancedLabels: allLabels } = buildBalancedDataset(baseFeatures, baseLabels);

  // Calcular TARGET_WEIGHT basado en el tamaño del dataset balanceado
  const TARGET_WEIGHT = Math.max(20, Math.round(allFeatures.length * 0.1));

  // Inyectar la canción objetivo
  const targetFeatureArray = Array.from(normalized);
  for (let i = 0; i < TARGET_WEIGHT; i++) {
    allFeatures.push(normalized);
    allLabels.push(song.userScore);
  }

  logInfo(`  Mini - retrain: ${ allFeatures.length } muestras(target x${ TARGET_WEIGHT } + ${ allFeatures.length - TARGET_WEIGHT } canciones)`);

  // Construir tensores
  const xData = new Float32Array(allFeatures.length * DEFAULT_CONFIG.inputDim);
  allFeatures.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  const xs = tf.tensor2d(xData, [allFeatures.length, DEFAULT_CONFIG.inputDim]);
  const ys = tf.oneHot(tf.tensor1d(allLabels, 'int32'), 4);

  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs: tuneEpochs,
    batchSize: DEFAULT_CONFIG.batchSize,
    shuffle: true,
  });

  const lossArr = history.history['loss'] as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  logInfo(`  Fine - tune completado — loss: ${ finalLoss.toFixed(6) } (${ tuneEpochs } épocas, lr = ${ tuneLr })`);

  // 5. Guardar modelo
  await model.save(nodeSaveHandler(modelPath));

  const accArr = history.history['acc'] as number[];
  const finalAcc = accArr ? accArr[accArr.length - 1] : 0;

  // 6. Registro de entrenamiento (fine-tuning siempre es true)
  const trainingId = await TrainingRecordModel.create({
    songId,
    isFineTuning: true,
    modelId: globalModel.id!,
    userScore: song.userScore,
    epochs: tuneEpochs,
    loss: finalLoss,
    batchSize: DEFAULT_CONFIG.batchSize,
    validationSplit: 0,
    mae: finalAcc
  });

  // 7. Predecir inmediatamente
  const input = tf.tensor2d([targetFeatureArray], [1, DEFAULT_CONFIG.inputDim]);
  const prediction = model.predict(input) as tf.Tensor;
  const rawOutput = await prediction.data();
  const globalScore = rawOutput[0]*0 + rawOutput[1]*1 + rawOutput[2]*2 + rawOutput[3]*3;
  const predictionAccuracy = Math.min(99.9999, Math.max(0, 100 - (Math.abs(globalScore - song.userScore) / 3) * 100));

  logSuccess(`  Canción ${ songId }: predicción = ${ globalScore.toFixed(4) } | usuario=${ song.userScore } | precisión=${ predictionAccuracy.toFixed(1) }% `);

  // 8. Actualizar canción: globalScore + incrementar trainLevelGlobal
  await SongModel.updateTrainingResults(songId, {
    globalScore,
    trainLevelGlobal: (song.tsTrainLevelGlobal || 0) + 1
  });

  // 9. Registro de predicción con referencia al entrenamiento recién creado
  await PredictionRecordModel.create({
    songId,
    modelId: globalModel.id!,
    prediction: globalScore,
    userScore: song.userScore,
    accuracy: predictionAccuracy,
    lastFitId: trainingId
  });

  // 10. Actualizar versión del modelo
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

  logSuccess(`Fine - tuning y predicción completados para canción ${ songId } `);

  // Retornar canción actualizada
  const updatedSong = await SongModel.getSongById(songId);
  if (!updatedSong) throw new Error(`No se pudo obtener canción actualizada ${ songId } `);
  updatedSong.accuracy = predictionAccuracy;
  return updatedSong;
}