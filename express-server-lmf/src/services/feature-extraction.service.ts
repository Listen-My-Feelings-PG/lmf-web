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
 * Inicializa la extracción de features al arrancar el servidor.
 * Consulta todas las canciones activas en BD y verifica cuáles NO tienen
 * features extraídas (campo tsFeaturesFileName nulo O archivo .npy inexistente).
 * Solo procesa las canciones faltantes.
 */
export async function initializeFeatureExtraction(): Promise<void> {
  logInfo('═'.repeat(60));
  logInfo('Verificando features extraídas...');

  try {
    const allSongs = await SongModel.getAll();
    const featuresDir = path.resolve(paths.features);

    const audioDir = path.resolve(paths.audio);

    // Filtrar canciones que realmente tienen archivo de audio en disco
    const songsWithAudio = allSongs.filter(song => {
      const audioPath = path.join(audioDir, song.fileName);
      return fs.existsSync(audioPath);
    });

    const songsWithoutAudio = allSongs.length - songsWithAudio.length;
    if (songsWithoutAudio > 0) {
      logInfo(`⚠ ${songsWithoutAudio} canción(es) sin archivo de audio en disco (se omiten)`);
    }

    const songsMissing = songsWithAudio.filter(song => {
      if (!song.tsFeaturesFileName) return true;
      const featurePath = path.join(featuresDir, song.tsFeaturesFileName);
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
 * Inicia la extracción de features en background (fire-and-forget).
 * Adquiere el lock global, spawns Python, loguea todo en consola,
 * actualiza la BD al completar cada canción, y libera el lock al finalizar.
 *
 * @param songs Lista de canciones obtenidas de la BD
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

  const pythonProcess = spawn('python', [
    scriptPath,
    '--audio-dir', audioDir,
    '--output-dir', featuresDir,
    '--songs-file', tempFile
  ], {
    env: { ...process.env, PYTHONIOENCODING: 'utf-8' },
    stdio: ['pipe', 'pipe', 'pipe']
  });

  let buffer = '';

  pythonProcess.stdout.on('data', (data: Buffer) => {
    buffer += data.toString('utf-8');
    const lines = buffer.split('\n');
    buffer = lines.pop() || '';

    for (const line of lines) {
      if (line.trim()) {
        try {
          const event: FeatureExtractionEvent = JSON.parse(line);
          handleEvent(event);
        } catch {
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
