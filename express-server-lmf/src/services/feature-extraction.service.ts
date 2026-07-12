import { spawn } from 'child_process';
import path from 'path';
import fs from 'fs';
import os from 'os';
import { paths } from '../main';
import SongModel from '../models/song.model';
import { Song } from '../types/generals.models';

const TAG = '[FeatureExtraction]';

// ─── Lock global de extracción ───────────────────────────────────────────────
let extractionInProgress = false;


/**
 * Indica si hay un proceso de extracción de features activo.
 */
export function isExtractionActive(): boolean {
  return extractionInProgress;
}

/**
 * Evento emitido durante la extracción de features
 */
export interface FeatureExtractionEvent {
  type: 'info' | 'progress' | 'result' | 'error' | 'skip' | 'complete' | 'fatal';
  songId?: number;
  message?: string;
  status?: string;
  featuresFile?: string;
  fileName?: string;
  error?: string;
  traceback?: string;
  shape?: number[];
  current?: number;
  total?: number;
  success?: number;
  failed?: number;
  skipped?: number;
}

/**
 * Canción preparada para extracción de features
 */
interface SongForExtraction {
  id: number;
  fileName: string;
  featuresFile: string | null;
}

function logInfo(msg: string): void {
  console.info(`${TAG} ${msg}`);
}

function logSuccess(msg: string): void {
  console.info(`${TAG} ✓ ${msg}`);
}

function logError(msg: string): void {
  console.error(`${TAG} ✗ ${msg}`);
}

function logSkip(msg: string): void {
  console.info(`${TAG} ⊘ ${msg}`);
}

/**
 * Inicializa la extracción automática de características (features) al arrancar el servidor.
 * Consulta todas las canciones activas en BD y verifica cuáles NO tienen
 * features extraídas (campo `tsFeaturesFileName` nulo O archivo físico `.npy` inexistente).
 * Solo manda a procesar el delta (las canciones faltantes), ahorrando horas de cómputo en cada reinicio.
 * 
 * @returns Promesa que se resuelve cuando se lanza el subproceso (no espera a que termine).
 */
export async function initializeFeatureExtraction(): Promise<void> {
  logInfo('═'.repeat(60));
  logInfo('Verificando features extraídas...');

  try {
    const allSongs = await SongModel.getAll();
    const featuresDir = path.resolve(paths.features);

    const audioDir = path.resolve(paths.audio);

    // Variable clave `songsWithAudio`: Arreglo de canciones filtrado.
    // Solo incluye canciones cuyo archivo mp3/wav/flac físico existe realmente en el disco duro.
    const songsWithAudio = allSongs.filter(song => {
      const audioPath = path.join(audioDir, song.fileName);
      return fs.existsSync(audioPath);
    });

    const songsWithoutAudio = allSongs.length - songsWithAudio.length;
    if (songsWithoutAudio > 0) {
      logInfo(`⚠ ${songsWithoutAudio} canción(es) sin archivo de audio en disco (se omiten)`);
    }

    // Variable clave `songsMissing`: Arreglo de canciones que pasaron el primer filtro pero NO tienen archivo .npy
    const songsMissing = songsWithAudio.filter(song => {
      // 1. Si no hay registro en la base de datos de un nombre de archivo, definitivamente falta.
      if (!song.tsFeaturesFileName) return true;
      const featurePath = path.join(featuresDir, song.tsFeaturesFileName);
      // 2. Si hay registro, pero el archivo físico no se encuentra, también lo marcamos como faltante.
      return !fs.existsSync(featurePath);
    });

    logInfo(`Canciones activas: ${allSongs.length}`);
    logInfo(`Canciones con audio en disco: ${songsWithAudio.length}`);
    logInfo(`Canciones con features: ${songsWithAudio.length - songsMissing.length}`);
    logInfo(`Canciones sin features: ${songsMissing.length}`);

    if (songsMissing.length === 0) {
      logInfo('Todas las canciones ya tienen features extraídas. No se requiere extracción.');
      logInfo('═'.repeat(60));
      return;
    }

    logInfo(`Iniciando extracción para ${songsMissing.length} canción(es) faltante(s)...`);
    startFeatureExtraction(songsMissing);
  } catch (error) {
    logError(`Error al verificar features: ${error}`);
    logInfo('═'.repeat(60));
  }
}

/**
 * Lanza el subproceso de Python (script `feature_extractor.py`) encargado de procesar el audio masivo (fire-and-forget).
 * Establece un cerrojo (lock global `extractionInProgress`) para evitar paralelismo destructivo.
 * Lee la salida (stdout) de Python línea por línea a través de eventos JSON y actualiza la BD en tiempo real.
 * Libera el lock al finalizar exitosamente o fallar.
 *
 * @param songs Lista de objetos Song obtenidos de la BD que requieren extracción.
 */
function startFeatureExtraction(songs: Song[]): void {
  if (extractionInProgress) {
    logError('Se intentó iniciar extracción pero ya hay un proceso activo.');
    return;
  }

  extractionInProgress = true;

  const featuresDir = path.resolve(paths.features);
  const audioDir = path.resolve(paths.audio);
  const scriptPath = path.resolve(__dirname, '../../../feature_extractor.py');

  logInfo('═'.repeat(60));
  logInfo(`Iniciando extracción de features para ${songs.length} canciones`);
  logInfo(`Audio: ${audioDir}`);
  logInfo(`Features: ${featuresDir}`);
  logInfo(`Script: ${scriptPath}`);
  logInfo('═'.repeat(60));

  // Preparar lista para el script Python
  const songsForExtraction: SongForExtraction[] = songs.map(s => ({
    id: s.id!,
    fileName: s.fileName,
    featuresFile: s.tsFeaturesFileName || null
  }));

  // Escribir JSON temporal
  const tempFile = path.join(os.tmpdir(), `lmf_songs_${Date.now()}.json`);
  fs.writeFileSync(tempFile, JSON.stringify(songsForExtraction), 'utf-8');

  // Variable clave `pythonProcess`: Representa el proceso hijo (Subprocess) del sistema operativo.
  // Permite ejecutar el script pesado de Python (VGGish/Librosa) sin bloquear el Event Loop de NodeJS (Express).
  const pythonProcess = spawn('python', [
    scriptPath,
    '--audio-dir', audioDir,
    '--output-dir', featuresDir,
    '--songs-file', tempFile
  ], {
    env: { ...process.env, PYTHONIOENCODING: 'utf-8' },
    stdio: ['pipe', 'pipe', 'pipe'] // Captura stdIn, stdOut y stdErr a través de flujos (Streams)
  });

  // `buffer` actúa como un acumulador. Puesto que los flujos (streams) pueden cortar un string JSON a la mitad,
  // el buffer espera hasta encontrar un salto de línea (\n) para intentar parsear la respuesta completa.
  let buffer = '';

  // Escuchar el evento 'data' del StdOut del proceso hijo.
  pythonProcess.stdout.on('data', (data: Buffer) => {
    buffer += data.toString('utf-8');
    const lines = buffer.split('\n');
    // pop() saca el último elemento (que podría estar incompleto si no termina en \n) y lo guarda en el buffer para el próximo chunk.
    buffer = lines.pop() || '';

    // Bucle for-of: Itera sobre todas las líneas completas recibidas desde Python.
    for (const line of lines) {
      if (line.trim()) {
        try {
          // El script de Python escupe objetos JSON por línea (Logs estructurados).
          const event: FeatureExtractionEvent = JSON.parse(line);
          handleEvent(event);
        } catch {
          // Si no es un JSON, simplemente lo tratamos como texto informativo (print normal).
          logInfo(`[Python] ${line.trim()}`);
        }
      }
    }
  });

  pythonProcess.stderr.on('data', (data: Buffer) => {
    const message = data.toString('utf-8').trim();
    if (message) {
      logInfo(`[Python stderr] ${message}`);
    }
  });

  pythonProcess.on('close', (code) => {
    // Procesar buffer restante
    if (buffer.trim()) {
      try {
        const event: FeatureExtractionEvent = JSON.parse(buffer);
        handleEvent(event);
      } catch {
        // Ignorar
      }
    }

    // Limpiar archivo temporal
    try {
      if (fs.existsSync(tempFile)) fs.unlinkSync(tempFile);
    } catch { /* No crítico */ }

    logInfo('═'.repeat(60));
    logInfo(`Proceso Python finalizado con código: ${code}`);
    logInfo('═'.repeat(60));

    // Liberar lock
    extractionInProgress = false;
  });

  pythonProcess.on('error', (err) => {
    logError(`Error al iniciar proceso Python: ${err.message}`);
    logError('¿Está Python instalado y en el PATH?');

    // Limpiar archivo temporal
    try {
      if (fs.existsSync(tempFile)) fs.unlinkSync(tempFile);
    } catch { /* No crítico */ }

    // Liberar lock
    extractionInProgress = false;
  });
}

/**
 * Maneja un evento del proceso Python: loguea en consola y actualiza la BD.
 */
async function handleEvent(event: FeatureExtractionEvent): Promise<void> {
  switch (event.type) {
    case 'info':
      logInfo(event.message || 'Info');
      break;

    case 'progress':
      logInfo(`[${event.current}/${event.total}] Extrayendo: ${event.fileName}`);
      break;

    case 'result':
      logSuccess(`[${event.current}/${event.total}] ID ${event.songId} → ${event.featuresFile} (${event.shape?.join('x')})`);
      // Actualizar BD con el nombre del archivo de features
      if (event.songId && event.featuresFile) {
        try {
          await SongModel.updateFeaturesFilename(event.songId, event.featuresFile);
        } catch (dbError) {
          logError(`Error al actualizar BD para canción ${event.songId}: ${dbError}`);
        }
      }
      break;

    case 'skip':
      logSkip(`[${event.current}/${event.total}] ID ${event.songId} — ${event.message}`);
      break;

    case 'error':
      logError(`[${event.current}/${event.total}] ID ${event.songId}: ${event.error}`);
      break;

    case 'fatal':
      logError(`FATAL: ${event.error}`);
      if (event.traceback) logError(event.traceback);
      break;

    case 'complete':
      logInfo('─'.repeat(40));
      logInfo(`Resumen: ${event.success} exitosas, ${event.skipped} omitidas, ${event.failed} fallidas (total: ${event.total})`);
      logInfo('─'.repeat(40));
      break;
  }
}
