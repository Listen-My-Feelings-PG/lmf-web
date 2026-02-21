import { spawn } from 'child_process';
import fs from 'fs/promises';
import fsSync from 'fs';
import path from 'path';
import archiver from 'archiver';
import unzipper from 'unzipper';
import { v4 as uuidv4 } from 'uuid';
import zlib from 'zlib';
import { promisify } from 'util';
import { Response } from 'express';
import { AudioFeatures, LogLevel } from '../types';

const gzip = promisify(zlib.gzip);
const gunzip = promisify(zlib.gunzip);

/**
 * Logger personalizado
 */
export function logger(level: LogLevel, msg: string, data?: any): void {
  setImmediate(() => {
    process.nextTick(() => {
      const timestamp = new Date().toISOString();
      const message = `[${timestamp}] [${level.toUpperCase()}] ${msg}`;
      switch (level) {
        case 'info':
          console.info(message, data || '');
          break;
        case 'error':
          console.error(message, data || '');
          break;
        case 'warn':
          console.warn(message, data || '');
          break;
        default:
          console.log(message, data || '');
      }
    });
  });
}

/**
 * Ejecutar script de Python para extraer características
 */
export async function extractFeatures(audioFilePath: string): Promise<AudioFeatures> {
  return new Promise((resolve, reject) => {
    const pythonPath = process.env.PYTHON_PATH || 'python';
    const scriptPath = path.join(__dirname, '../../feature_extractor.py');

    logger('info', 'Ejecutando extracción de características:', audioFilePath);

    const pythonProcess = spawn(pythonPath, [scriptPath, audioFilePath]);

    let stdout = '';
    let stderr = '';

    pythonProcess.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    pythonProcess.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    pythonProcess.on('close', (code) => {
      if (code !== 0) {
        logger('error', 'Error en extracción de características:', stderr);
        return reject(new Error(`Python script failed: ${stderr}`));
      }

      try {
        const features: AudioFeatures = JSON.parse(stdout);
        resolve(features);
      } catch (error) {
        logger('error', 'Error al parsear características:', error);
        reject(new Error('Failed to parse features JSON'));
      }
    });
  });
}

/**
 * Guardar características comprimidas
 */
export async function saveFeaturesCompressed(
  features: AudioFeatures,
  fileName: string,
  outputPath: string
): Promise<string> {
  try {
    const jsonString = JSON.stringify(features);
    const compressed = await gzip(Buffer.from(jsonString));
    const outputFile = path.join(outputPath, `${fileName}.json.gz`);
    await fs.writeFile(outputFile, compressed);
    logger('info', 'Características guardadas:', outputFile);
    return outputFile;
  } catch (error) {
    logger('error', 'Error al guardar características:', error);
    throw error;
  }
}

/**
 * Leer características comprimidas
 */
export async function readFeaturesCompressed(filePath: string): Promise<AudioFeatures> {
  try {
    const compressed = await fs.readFile(filePath);
    const decompressed = await gunzip(compressed);
    const features: AudioFeatures = JSON.parse(decompressed.toString());
    return features;
  } catch (error) {
    logger('error', 'Error al leer características:', error);
    throw error;
  }
}

/**
 * Crear archivo ZIP
 */
export async function createZip(
  sourceDir: string,
  outputPath: string,
  fileName: string
): Promise<string> {
  return new Promise((resolve, reject) => {
    const output = fsSync.createWriteStream(path.join(outputPath, fileName));
    const archive = archiver('zip', { zlib: { level: 9 } });

    output.on('close', () => {
      logger('info', `ZIP creado: ${archive.pointer()} bytes`);
      resolve(path.join(outputPath, fileName));
    });

    archive.on('error', (err) => {
      logger('error', 'Error al crear ZIP:', err);
      reject(err);
    });

    archive.pipe(output);
    archive.directory(sourceDir, false);
    archive.finalize();
  });
}

/**
 * Extraer archivo ZIP
 */
export async function extractZip(zipPath: string, outputPath: string): Promise<string> {
  return new Promise((resolve, reject) => {
    fsSync
      .createReadStream(zipPath)
      .pipe(unzipper.Extract({ path: outputPath }))
      .on('close', () => {
        logger('info', 'ZIP extraído exitosamente');
        resolve(outputPath);
      })
      .on('error', (err: Error) => {
        logger('error', 'Error al extraer ZIP:', err);
        reject(err);
      });
  });
}

/**
 * Guardar archivo desde buffer
 */
export async function saveFile(buffer: Buffer, filePath: string): Promise<string> {
  try {
    await fs.writeFile(filePath, buffer);
    logger('info', 'Archivo guardado:', filePath);
    return filePath;
  } catch (error) {
    logger('error', 'Error al guardar archivo:', error);
    throw error;
  }
}

/**
 * Eliminar archivo
 */
export async function deleteFile(filePath: string): Promise<boolean> {
  try {
    await fs.unlink(filePath);
    logger('info', 'Archivo eliminado:', filePath);
    return true;
  } catch (error: any) {
    if (error.code !== 'ENOENT') {
      logger('error', 'Error al eliminar archivo:', error);
    }
    return false;
  }
}

/**
 * Generar nombre único para archivo
 */
export function generateUniqueFileName(originalName: string): string {
  const ext = path.extname(originalName);
  const name = path.basename(originalName, ext);
  const timestamp = Date.now();
  const uuid = uuidv4().split('-')[0];
  return `${timestamp}_${uuid}_${name}${ext}`;
}

/**
 * Validar formato de archivo de audio
 */
export function isValidAudioFile(filename: string): boolean {
  const validExtensions = ['.mp3', '.wav', '.ogg', '.m4a'];
  const ext = path.extname(filename).toLowerCase();
  return validExtensions.includes(ext);
}

/**
 * Obtener tamaño de archivo
 */
export async function getFileSize(filePath: string): Promise<number> {
  try {
    const stats = await fs.stat(filePath);
    return stats.size;
  } catch (error) {
    logger('error', 'Error al obtener tamaño de archivo:', error);
    return 0;
  }
}

/**
 * Crear directorio si no existe
 */
export async function ensureDirectory(dirPath: string): Promise<boolean> {
  try {
    await fs.mkdir(dirPath, { recursive: true });
    return true;
  } catch (error) {
    logger('error', 'Error al crear directorio:', error);
    return false;
  }
}

/**
 * Response helper
 */
export function sendResponse<T = any>(
  res: Response,
  success: boolean,
  data: T | null = null,
  message = '',
  statusCode = 200
): void {
  res.status(statusCode).json({
    success,
    data,
    message,
    timestamp: new Date().toISOString()
  });
}

/**
 * Error response helper
 */
export function sendError(
  res: Response,
  message: string,
  statusCode = 500,
  error: Error | null = null
): void {
  logger('error', message, error);
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? error?.message : undefined,
    timestamp: new Date().toISOString()
  });
}
