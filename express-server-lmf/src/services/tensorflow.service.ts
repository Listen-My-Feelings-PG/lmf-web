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
import { ModelScope, TrainingMode } from '../types/generals.types';

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

// ─── Helper de Event Loop ────────────────────────────────────────────────────
// Libera el hilo principal de Node.js para que pueda procesar otras peticiones HTTP
const yieldEventLoop = () => new Promise(resolve => setImmediate(resolve));

// ─── Creación de modelo ──────────────────────────────────────────────────────
/**
 * Crea la arquitectura del modelo de clasificación.
 *
 * ── Visión general ──────────────────────────────────────────────────────────
 * Red neuronal feedforward (MLP) de clasificación multiclase diseñada para
 * predecir probabilidades (0, 1, 2, 3) a partir de embeddings de audio.
 *
 * ── Flujo de datos ──────────────────────────────────────────────────────────
 *
 *   Input (304)          Vector de embeddings (VGGish + Librosa).
 *       ▼
 *   Dense (304 → 256)    ReLU + He Normal.
 *       ▼
 *   Dropout (20%)
 *       ▼
 *   Dense (256 → 128)    ReLU + He Normal.
 *       ▼
 *   Dropout (20%)
 *       ▼
 *   Dense (128 → 4)      Softmax → Distribución de probabilidad sobre 4 clases.
 *       ▼
 *   Output (4)           Probabilidades de pertenencia a calificaciones [0, 1, 2, 3].
 *
 * ── Resumen de parámetros (asumiendo input=304) ─────────────────────────────
 *   Capa 1 (Dense):  304×256 + 256 bias  =  78.080 parámetros
 *   Capa 2 (Dense):  256×128 + 128 bias  =  32.896 parámetros
 *   Capa 3 (Dense):    128×4 +   4 bias  =     516 parámetros
 *   ─────────────────────────────────────────────────
 *   Total:                                 111.492 parámetros entrenables
 */
function createModelArchitecture(
  inputDim: number = DEFAULT_CONFIG.inputDim
): tf.Sequential {
  const model = tf.sequential();

  // Capa 1: Proyección del espacio de embeddings a representación interna
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
 * Compila un modelo de TensorFlow preparándolo para el entrenamiento.
 * Define la función de pérdida (loss function) y el optimizador (Adam) que actualizará los pesos de la red.
 * 
 * @param model Modelo secuencial de TensorFlowJS (capas ya definidas).
 * @param learningRate Tasa de aprendizaje (qué tan grandes son los pasos que da el optimizador al ajustar pesos).
 */
function compileModel(model: tf.LayersModel, learningRate: number = DEFAULT_CONFIG.learningRate): void {
  model.compile({
    optimizer: tf.train.adam(learningRate),
    loss: 'categoricalCrossentropy', // Usado para clasificación multi-clase con activación Softmax
    metrics: ['accuracy']
  });
}

/**
 * Crea un dataset balanceado a partir de listas de features y labels.
 * Utiliza una técnica de sobremuestreo (oversampling) copiando datos de las clases minoritarias
 * para que el modelo no se sesgue hacia la calificación más común.
 * Además aplica un peso especial a las calificaciones positivas (>= 2).
 * 
 * @param features Array de vectores de audio (datos X).
 * @param labels Array con las calificaciones correspondientes (0, 1, 2, 3) (etiquetas Y).
 * @returns Un objeto con los arrays balanceados listos para tensorización.
 */
function buildBalancedDataset(features: Float32Array[], labels: number[]): { balancedFeatures: Float32Array[], balancedLabels: number[] } {
  // Array de conteo: índice = calificación, valor = cantidad de veces que aparece
  const classCountArray = [0, 0, 0, 0];
  labels.forEach(l => classCountArray[l]++);
  const maxCount = Math.max(...classCountArray);

  const balancedFeatures: Float32Array[] = [];
  const balancedLabels: number[] = [];

  // Bucle principal: Recorre todas las etiquetas originales para calcular su peso
  labels.forEach((label, index) => {
    const count = classCountArray[label];
    // Peso (weight) base: ¿cuántas veces debo clonar esta fila para igualar a la clase mayoritaria?
    let weight = count > 0 ? Math.round(maxCount / count) : 1;

    // Énfasis extra para calificaciones altas (2 y 3). 
    // Ayuda a que el modelo priorice no equivocarse con las canciones que al usuario le gustan.
    if (label >= 2) {
      weight = Math.round(weight * 2);
    }

    // Bucle interno: Clona/duplica los datos en memoria según el 'weight' calculado
    for (let i = 0; i < weight; i++) {
      balancedFeatures.push(features[index]);
      balancedLabels.push(label);
    }
  });

  return { balancedFeatures, balancedLabels };
}

// ─── Preparación de datos ────────────────────────────────────────────────────
/**
 * Extrae y valida los datos crudos (features y userScore) de una lista de canciones 
 * para construir un conjunto de entrenamiento (Dataset).
 * Filtra las canciones que no cumplan con los requisitos básicos para ser entrenadas.
 * 
 * @param songs Array de objetos Song.
 * @param mode Modo de entrenamiento (clean/infer). En 'clean' ignora canciones ya entrenadas.
 * @param modelScope El alcance del modelo (global o local) para verificar el nivel de entrenamiento previo.
 * @returns Tres arrays paralelos alineados: features (datos de audio X), labels (calificaciones Y) y songIds (IDs).
 */
function prepareSongsForTraining(
  songs: Song[],
  mode: TrainingMode,
  modelScope: ModelScope
): { features: Float32Array[]; labels: number[]; songIds: number[] } {
  const featuresDir = path.resolve(paths.features);
  const features: Float32Array[] = [];
  const labels: number[] = [];
  const songIds: number[] = [];

  // Bucle for-of: Itera secuencialmente sobre todas las canciones proporcionadas para filtrarlas y extraer sus arrays de audio.
  for (const song of songs) {
    // Regla 1: Debe tener calificación del usuario (no podemos entrenar aprendizaje supervisado sin una etiqueta 'Y')
    if (song.userScore === undefined || song.userScore === null) continue;
    
    // Regla 2: Debe existir una referencia en BD al archivo `.npy` con las features VGGish extraídas
    if (!song.tsFeaturesFileName) continue;
    
    // Regla 3: Si el modo es 'clean' (Entrenamiento desde cero para datos nuevos), omitimos las que ya tengan 'trainLevel'
    if (mode === 'clean') {
      const trainLevel = modelScope === 'global' ? song.tsTrainLevelGlobal : song.tsTrainLevelLocal;
      if (trainLevel && trainLevel > 0) continue;
    }

    // Regla 4: Obtener de caché en memoria el Array de floats (X). Si falla o no existe el archivo físico, se ignora la canción.
    const normalized = getCachedFeature(song.id!, song.tsFeaturesFileName, featuresDir);
    if (!normalized) continue;

    // Si pasó todas las reglas, agregamos a nuestros arreglos paralelos
    features.push(normalized);
    labels.push(song.userScore);
    songIds.push(song.id!);
  }

  return { features, labels, songIds };
}

// ─── Flujo principal de entrenamiento ────────────────────────────────────────
/**
 * Orquestador principal del proceso de entrenamiento.
 * Se encarga de:
 * 1. Obtener las canciones de la base de datos.
 * 2. Manejar la caché de características (Feature Cache).
 * 3. Crear o recuperar el modelo "Global" (entrenado con todas las canciones de la playlist default).
 * 4. Iterar sobre listas de reproducción (playlists) secundarias para entrenar Modelos "Locales" si se solicita.
 * 
 * @param songIds Array con los IDs de las canciones que se quieren entrenar.
 * @param mode Modo de entrenamiento ('clean' para nuevas, 'infer' para todo).
 * @param includeLocalTraining Si es `true`, también buscará a qué playlists pertenecen las canciones y entrenará sub-modelos especializados.
 */
export async function runTraining(
  songIds: number[],
  mode: TrainingMode,
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

    // Bucle for-of: Itera sobre cada Playlist que contenga alguna de las canciones objetivo.
    // Esto crea un modelo de IA "Local" especializado en el gusto de esa playlist específica,
    // aislando el sesgo (bias) de otras playlists.
    for (const [idPlaylist, plSongIds] of playlistSongMap.entries()) {
      // La playlist por defecto abarca todas las canciones, y ya se usó para entrenar el modelo Global arriba.
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
/**
 * Lógica core de entrenamiento para una instancia específica de un modelo de TensorFlow.
 * Carga el modelo físico, formatea y balancea los tensores (X, Y), ejecuta el ciclo `.fit()` 
 * con validación cruzada y guarda los nuevos pesos generados.
 * 
 * @param tsModel Registro del modelo extraído de la base de datos (contiene la arquitectura y rutas).
 * @param songs Lista de canciones ya validadas y obtenidas de BD.
 * @param mode Modo de entrenamiento (clean/infer).
 * @param modelScope Indica si estamos entrenando el modelo 'global' o un 'local'.
 */
async function trainSingleModel(
  tsModel: TensorFlowModel,
  songs: Song[],
  mode: TrainingMode,
  modelScope: ModelScope
): Promise<void> {
  logInfo('─'.repeat(40));
  logInfo(`Entrenando modelo ${modelScope.toUpperCase()} (ID: ${tsModel.id}, v${tsModel.version})`);

  // Preparar datos
  const { features, labels, songIds: trainSongIds } = prepareSongsForTraining(songs, mode, modelScope);

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
  // Se crea un gran arreglo 1D que albergará todos los arreglos 1D de las canciones concatenados
  const xData = new Float32Array(balancedFeatures.length * DEFAULT_CONFIG.inputDim);
  // Bucle forEach: Copia los valores de cada vector al arreglo gigante `xData` calculando el desplazamiento (offset) en memoria.
  balancedFeatures.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  // Variable clave `xs`: Tensor 2D de forma (Número_de_Canciones, Dimensiones_de_Entrada). Representa la matriz de características X.
  const xs = tf.tensor2d(xData, [balancedFeatures.length, DEFAULT_CONFIG.inputDim]);
  // Variable clave `ys`: Tensor 2D de Etiquetas. Usa "oneHot" encoding para transformar las clases [0,1,2,3] en vectores [1,0,0,0], [0,1,0,0], etc.
  const ys = tf.oneHot(tf.tensor1d(balancedLabels, 'int32'), 4);

  // Parámetros de entrenamiento
  const epochs = DEFAULT_CONFIG.epochs; // Cantidad máxima de veces que la red verá los datos
  const batchSize = Math.min(DEFAULT_CONFIG.batchSize, balancedFeatures.length); // Tamaño de lote para propagación
  const useValidation = balancedFeatures.length >= 10; // Solo validamos si hay suficientes datos

  logInfo(`Fit: ${balancedFeatures.length} muestras balanceadas, ${epochs} épocas, batch=${batchSize}, validación=${useValidation}`);

  // Early stopping: variables para detener el entrenamiento prematuramente si el modelo deja de aprender
  let bestValLoss = Infinity;
  let patienceCounter = 0;
  const patience = 40; // Número máximo de épocas consecutivas sin mejora permitidas
  let stoppedEarly = false;

  // Variable clave `history`: Objeto que guarda el registro matemático (Loss, Accuracy) devuelto por TensorFlow tras cada época.
  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs,
    batchSize,
    validationSplit: useValidation ? DEFAULT_CONFIG.validationSplit : 0,
    shuffle: true, // Baraja los datos para evitar que la red aprenda el orden de las canciones
    callbacks: {
      onBatchEnd: async () => {
        // yieldEventLoop libera la CPU para que NodeJS atienda llamadas HTTP u otros subprocesos mientras TensorFlow entrena en el hilo principal (evita bloquear el servidor).
        await yieldEventLoop();
      },
      onEpochEnd: async (epoch, logs) => {
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

        // Liberar event loop al final de la época también
        await yieldEventLoop();
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

    if (modelScope === 'global') {
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
 * Orquestador del flujo masivo de predicción (Inferencia).
 * 1. Carga el modelo "Global" actual de TensorFlowJS desde el disco.
 * 2. Lee los datos de características acústicas (features) de las canciones desde la caché/disco.
 * 3. Ejecuta la red neuronal (Feedforward) en modo inferencia (`predict`) para cada canción.
 * 4. Calcula la precisión si el usuario ya había calificado la canción.
 * 5. Guarda un histórico estadístico en masa (Batch Insert) en la base de datos.
 * 
 * @param songIds Lista de IDs de las canciones a predecir.
 */
export async function runPrediction(songIds: number[]): Promise<void> {
  logInfo('═'.repeat(60));
  logInfo('Iniciando predicción de canciones');
  logInfo(`Canciones solicitadas: ${songIds.length
    }`);
  logInfo('═'.repeat(60));

  // 1. Obtener canciones de la BD
  const songs = await SongModel.getSongsByIds(songIds);
  logInfo(`Canciones encontradas en BD: ${songs.length} `);

  if (songs.length === 0) {
    logInfo('No se encontraron canciones. Abortando predicción.');
    return;
  }

  // 2. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) {
    throw new Error('No existe modelo global entrenado. Entrene un modelo primero.');
  }
  logInfo(`Modelo global: ID = ${globalModel.id}, v${globalModel.version}, ${globalModel.trainedSongs} canciones entrenadas`);

  // 3. Cargar modelo desde disco
  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');

  if (!fs.existsSync(modelJsonPath)) {
    throw new Error(`Archivo de modelo no encontrado en disco: ${modelJsonPath} `);
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

  // Bucle for-of: Itera secuencialmente sobre cada canción para evaluarla individualmente contra la red neuronal.
  // Podría hacerse en lotes (batch), pero iterar permite manejar errores por canción de forma segura sin abortar todo el proceso masivo.
  for (const song of songs) {
    if (!song.tsFeaturesFileName) {
      logInfo(`  Canción ${song.id}: sin archivo de features.Omitiendo.`);
      skipped++;
      continue;
    }

    const normalized = getCachedFeature(song.id!, song.tsFeaturesFileName, featuresDir);
    if (!normalized) {
      logInfo(`  Canción ${song.id}: archivo de features no encontrado o inválido.Omitiendo.`);
      skipped++;
      continue;
    }

    const lastFitId = lastFitMap.get(song.id!);
    if (!lastFitId) {
      logInfo(`  Canción ${song.id}: sin registro de entrenamiento previo.Omitiendo registro de predicción.`);
    }

    try {
      // Crear tensor de entrada (1, 128)
      const input = tf.tensor2d([Array.from(normalized)], [1, DEFAULT_CONFIG.inputDim]);
      const prediction = model.predict(input) as tf.Tensor;
      const rawOutput = await prediction.data();

      // Clasificación: Valor Esperado
      const globalScore = rawOutput[0] * 0 + rawOutput[1] * 1 + rawOutput[2] * 2 + rawOutput[3] * 3;

      // Calcular precisión: 100 - (|predicción - userScore| / 3) * 100
      const hasUserScore = song.userScore !== undefined && song.userScore !== null;
      const userScore = song.userScore ?? 0;
      const predictionAccuracy = hasUserScore
        ? Math.min(99.9999, Math.max(0, 100 - (Math.abs(globalScore - userScore) / 3) * 100))
        : null;

      logInfo(`  Canción ${song.id}: predicción = ${globalScore.toFixed(4)} | usuario=${hasUserScore ? userScore : 'N/A'} | precisión=${predictionAccuracy !== null ? predictionAccuracy.toFixed(1) + '%' : 'N/A'} `);

      // Actualizar tabla canciones
      await SongModel.updateTrainingResults(song.id!, {
        globalScore
      });

      // Registrar predicción, permitiendo null en lastFitId si la canción es nueva (sin fine-tuning)
      predictionEntries.push({
        songId: song.id!,
        modelId: globalModel.id!,
        prediction: globalScore,
        userScore: hasUserScore ? userScore : null,
        accuracy: predictionAccuracy,
        lastFitId: lastFitId ?? null
      });

      predicted++;

      // Limpiar tensores de esta iteración
      input.dispose();
      prediction.dispose();
    } catch (err) {
      logError(`  Error prediciendo canción ${song.id}: ${err} `);
      skipped++;
    }
  }

  // 6. Insertar registros de predicción en batch
  if (predictionEntries.length > 0) {
    await PredictionRecordModel.createBatch(predictionEntries);
    logSuccess(`${predictionEntries.length} registros de predicción guardados`);
  }

  // 7. Limpiar modelo
  model.dispose();

  logInfo('─'.repeat(40));
  logSuccess(`Predicción completada: ${predicted} predichas, ${skipped} omitidas`);
  logInfo('═'.repeat(60));
}

// ─── Fine-tuning de canción individual ──────────────────────────────────────
/**
 * Fine-tuning (Ajuste Fino) del modelo global basado en la retroalimentación inmediata del usuario sobre una sola canción.
 * Concepto clave: Cuando el usuario modifica una calificación, queremos que la IA aprenda de este error inmediatamente.
 * Para evitar el "Olvido Catastrófico" (que la red olvide todo lo aprendido por concentrarse solo en esta nueva canción),
 * se carga una muestra representativa de todas las canciones previas y se inyecta la nueva canción multiplicada artificialmente.
 * 
 * @param songId El ID de la canción que acaba de ser recalificada.
 * @returns La entidad de la canción actualizada con la nueva precisión tras el reentrenamiento exprés.
 */
export async function tuneSingleSongById(songId: number): Promise<Song> {
  logInfo('─'.repeat(40));
  logInfo(`Fine - tuning canción ${songId} `);

  // 1. Obtener canción
  const song = await SongModel.getSongById(songId);
  if (!song) throw new Error(`Canción ${songId} no encontrada`);
  if (song.userScore === undefined || song.userScore === null)
    throw new Error(`Canción ${songId} no tiene calificación del usuario`);
  if (!song.tsFeaturesFileName)
    throw new Error(`Canción ${songId} no tiene archivo de features`);

  // 2. Cargar features (con caché)
  const featuresDir = path.resolve(paths.features);
  const normalized = getCachedFeature(songId, song.tsFeaturesFileName, featuresDir);
  if (!normalized)
    throw new Error(`Archivo de features no encontrado o inválido: ${song.tsFeaturesFileName} `);

  // 3. Obtener modelo global
  const globalModel = await TsModelModel.getGlobalModel();
  if (!globalModel) throw new Error('No existe modelo global entrenado');

  const modelsDir = path.resolve(paths.models);
  const modelPath = path.join(modelsDir, globalModel.filename);
  const modelJsonPath = path.join(modelPath, 'model.json');
  if (!fs.existsSync(modelJsonPath))
    throw new Error(`Archivo de modelo no encontrado: ${modelJsonPath} `);

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

  // Bucle for-of: Recolecta TODAS las demás canciones calificadas históricamente para mantener el "conocimiento previo" de la red.
  // Este es el mecanismo clave de defensa contra el Olvido Catastrófico (Catastrophic Forgetting) durante el Fine-Tuning.
  for (const s of allScoredSongs) {
    // Excluir la canción objetivo original porque la inyectaremos con peso extra (Oversampling) más abajo.
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
  // Bucle for: Inyecta múltiples copias (clones) de la canción objetivo en el dataset equilibrado.
  // El número de copias (TARGET_WEIGHT) representa aprox. el 10% del dataset total.
  // Esto fuerza a la función de pérdida (Loss) del optimizador a prestarle especial atención a corregir el error en esta canción específica.
  for (let i = 0; i < TARGET_WEIGHT; i++) {
    allFeatures.push(normalized);
    allLabels.push(song.userScore);
  }

  logInfo(`  Mini - retrain: ${allFeatures.length} muestras(target x${TARGET_WEIGHT} + ${allFeatures.length - TARGET_WEIGHT} canciones)`);

  // Construir tensores
  const xData = new Float32Array(allFeatures.length * DEFAULT_CONFIG.inputDim);
  allFeatures.forEach((feat, i) => xData.set(feat, i * DEFAULT_CONFIG.inputDim));

  const xs = tf.tensor2d(xData, [allFeatures.length, DEFAULT_CONFIG.inputDim]);
  const ys = tf.oneHot(tf.tensor1d(allLabels, 'int32'), 4);

  const history = await (model as tf.LayersModel).fit(xs, ys, {
    epochs: tuneEpochs,
    batchSize: DEFAULT_CONFIG.batchSize,
    shuffle: true,
    callbacks: {
      onBatchEnd: async () => {
        // Liberar el event loop para no colgar el servidor (ej. streaming de audio)
        await yieldEventLoop();
      },
      onEpochEnd: async () => {
        await yieldEventLoop();
      }
    }
  });

  const lossArr = history.history['loss'] as number[];
  const finalLoss = lossArr[lossArr.length - 1];
  logInfo(`  Fine - tune completado — loss: ${finalLoss.toFixed(6)} (${tuneEpochs} épocas, lr = ${tuneLr})`);

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
  const globalScore = rawOutput[0] * 0 + rawOutput[1] * 1 + rawOutput[2] * 2 + rawOutput[3] * 3;
  const predictionAccuracy = Math.min(99.9999, Math.max(0, 100 - (Math.abs(globalScore - song.userScore) / 3) * 100));

  logSuccess(`  Canción ${songId}: predicción = ${globalScore.toFixed(4)} | usuario=${song.userScore} | precisión=${predictionAccuracy.toFixed(1)}% `);

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

  logSuccess(`Fine - tuning y predicción completados para canción ${songId} `);

  // Retornar canción actualizada
  const updatedSong = await SongModel.getSongById(songId);
  if (!updatedSong) throw new Error(`No se pudo obtener canción actualizada ${songId} `);
  updatedSong.accuracy = predictionAccuracy;
  return updatedSong;
}