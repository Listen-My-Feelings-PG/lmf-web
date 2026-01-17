const { spawn } = require('child_process');
const fs = require('fs').promises;
const fsSync = require('fs');
const path = require('path');
const archiver = require('archiver');
const unzipper = require('unzipper');
const { v4: uuidv4 } = require('uuid');
const zlib = require('zlib');
const { promisify } = require('util');

const gzip = promisify(zlib.gzip);
const gunzip = promisify(zlib.gunzip);

/**
 * Logger personalizado
 */
function logger(level, msg, data) {
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
async function extractFeatures(audioFilePath) {
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
        const features = JSON.parse(stdout);
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
async function saveFeaturesCompressed(features, fileName, outputPath) {
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
async function readFeaturesCompressed(filePath) {
  try {
    const compressed = await fs.readFile(filePath);
    const decompressed = await gunzip(compressed);
    const features = JSON.parse(decompressed.toString());
    return features;
  } catch (error) {
    logger('error', 'Error al leer características:', error);
    throw error;
  }
}

/**
 * Crear archivo ZIP
 */
async function createZip(sourceDir, outputPath, fileName) {
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
async function extractZip(zipPath, outputPath) {
  return new Promise((resolve, reject) => {
    fsSync.createReadStream(zipPath)
      .pipe(unzipper.Extract({ path: outputPath }))
      .on('close', () => {
        logger('info', 'ZIP extraído exitosamente');
        resolve(outputPath);
      })
      .on('error', (err) => {
        logger('error', 'Error al extraer ZIP:', err);
        reject(err);
      });
  });
}

/**
 * Guardar archivo desde buffer
 */
async function saveFile(buffer, filePath) {
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
async function deleteFile(filePath) {
  try {
    await fs.unlink(filePath);
    logger('info', 'Archivo eliminado:', filePath);
    return true;
  } catch (error) {
    if (error.code !== 'ENOENT') {
      logger('error', 'Error al eliminar archivo:', error);
    }
    return false;
  }
}

/**
 * Generar nombre único para archivo
 */
function generateUniqueFileName(originalName) {
  const ext = path.extname(originalName);
  const name = path.basename(originalName, ext);
  const timestamp = Date.now();
  const uuid = uuidv4().split('-')[0];
  return `${timestamp}_${uuid}_${name}${ext}`;
}

/**
 * Validar formato de archivo de audio
 */
function isValidAudioFile(filename) {
  const validExtensions = ['.mp3', '.wav', '.ogg', '.m4a'];
  const ext = path.extname(filename).toLowerCase();
  return validExtensions.includes(ext);
}

/**
 * Obtener tamaño de archivo
 */
async function getFileSize(filePath) {
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
async function ensureDirectory(dirPath) {
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
function sendResponse(res, success, data = null, message = '', statusCode = 200) {
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
function sendError(res, message, statusCode = 500, error = null) {
  logger('error', message, error);
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? error?.message : undefined,
    timestamp: new Date().toISOString()
  });
}

module.exports = {
  logger,
  extractFeatures,
  saveFeaturesCompressed,
  readFeaturesCompressed,
  createZip,
  extractZip,
  saveFile,
  deleteFile,
  generateUniqueFileName,
  isValidAudioFile,
  getFileSize,
  ensureDirectory,
  sendResponse,
  sendError
};
