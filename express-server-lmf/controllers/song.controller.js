const multer = require('multer');
const path = require('path');
const { paths } = require('../main');
const SongModel = require('../models/song.model');
const PlaylistModel = require('../models/playlist.model');
const {
  extractFeatures,
  saveFeaturesCompressed,
  readFeaturesCompressed,
  saveFile,
  deleteFile,
  generateUniqueFileName,
  isValidAudioFile,
  getFileSize,
  sendResponse,
  sendError,
  logger
} = require('../services/file.service');

// Configuración de multer para subida de archivos
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (req, file, cb) => {
    if (isValidAudioFile(file.originalname)) {
      cb(null, true);
    } else {
      cb(new Error('Formato de archivo no válido. Solo se permiten archivos de audio.'));
    }
  }
}).array('files', 50); // Máximo 50 archivos

/**
 * Subir múltiples canciones
 */
async function uploadSongs(req, res) {
  upload(req, res, async (err) => {
    if (err) {
      return sendError(res, 'Error al subir archivos', 400, err);
    }

    try {
      const { playlistId, initStatus = 'train' } = req.body;
      const files = req.files;

      if (!files || files.length === 0) {
        return sendError(res, 'No se recibieron archivos', 400);
      }

      if (!playlistId) {
        return sendError(res, 'playlistId es requerido', 400);
      }

      // Verificar que la playlist existe
      const playlist = await PlaylistModel.getById(playlistId);
      if (!playlist) {
        return sendError(res, 'Playlist no encontrada', 404);
      }

      const uploadedSongs = [];
      const errors = [];

      for (const file of files) {
        try {
          // Generar nombre único
          const uniqueFileName = generateUniqueFileName(file.originalname);
          const audioPath = path.join(paths.audio, uniqueFileName);

          // Guardar archivo de audio
          await saveFile(file.buffer, audioPath);

          // Obtener tamaño del archivo
          const fileSize = await getFileSize(audioPath);

          // Crear registro en la base de datos
          const song = await SongModel.create({
            name: file.originalname,
            fileSize: fileSize,
            fileName: uniqueFileName,
            trainLevel: 0,
            dataTypeId: 1,
            initStatus: initStatus
          });

          // Agregar canción a la playlist
          await PlaylistModel.addSong(playlistId, song.id);

          uploadedSongs.push({
            id: song.id,
            name: file.originalname,
            fileName: uniqueFileName,
            size: fileSize
          });

          logger('info', `Canción subida: ${file.originalname} (ID: ${song.id})`);
        } catch (error) {
          logger('error', `Error al procesar ${file.originalname}:`, error);
          errors.push({
            fileName: file.originalname,
            error: error.message
          });
        }
      }

      sendResponse(res, true, {
        uploaded: uploadedSongs,
        errors: errors,
        total: files.length,
        successful: uploadedSongs.length,
        failed: errors.length
      }, 'Archivos procesados');

    } catch (error) {
      sendError(res, 'Error al procesar archivos', 500, error);
    }
  });
}

/**
 * Extraer características de una canción
 */
async function extractSongFeatures(req, res) {
  try {
    const { songId } = req.params;

    // Obtener información de la canción
    const song = await SongModel.getById(songId);
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    const audioPath = path.join(paths.audio, song.file_name);

    // Extraer características usando Python
    logger('info', `Extrayendo características de canción ID: ${songId}`);
    const features = await extractFeatures(audioPath);

    // Guardar características comprimidas
    const featuresFileName = `${song.file_name}.json.gz`;
    await saveFeaturesCompressed(features, song.file_name, paths.features);

    // Actualizar estado en la base de datos
    await SongModel.updateFeaturesStatus(songId, featuresFileName, 'trained');

    logger('info', `Características extraídas para canción ID: ${songId}`);
    sendResponse(res, true, { features, fileName: featuresFileName }, 'Características extraídas exitosamente');

  } catch (error) {
    sendError(res, 'Error al extraer características', 500, error);
  }
}

/**
 * Obtener características de una canción
 */
async function getSongFeatures(req, res) {
  try {
    const { songId } = req.params;

    const song = await SongModel.getById(songId);
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    if (!song.features_file) {
      return sendError(res, 'La canción no tiene características extraídas', 404);
    }

    const featuresPath = path.join(paths.features, song.features_file);
    const features = await readFeaturesCompressed(featuresPath);

    sendResponse(res, true, features, 'Características obtenidas');

  } catch (error) {
    sendError(res, 'Error al obtener características', 500, error);
  }
}

/**
 * Actualizar calificación de una canción
 */
async function updateRating(req, res) {
  try {
    const { songId } = req.params;
    const { rating } = req.body;

    if (rating < 0 || rating > 3) {
      return sendError(res, 'La calificación debe estar entre 0 y 3', 400);
    }

    await SongModel.updateRating(songId, rating);

    logger('info', `Calificación actualizada para canción ID: ${songId} - Rating: ${rating}`);
    sendResponse(res, true, null, 'Calificación actualizada');

  } catch (error) {
    sendError(res, 'Error al actualizar calificación', 500, error);
  }
}

/**
 * Obtener todas las canciones
 */
async function getAllSongs(req, res) {
  try {
    const songs = await SongModel.getAll();
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error);
  }
}

/**
 * Obtener canciones por playlist
 */
async function getSongsByPlaylist(req, res) {
  try {
    const { playlistId } = req.params;
    const songs = await SongModel.getByPlaylist(playlistId);
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error);
  }
}

/**
 * Obtener canciones por estado
 */
async function getSongsByStatus(req, res) {
  try {
    const { status } = req.params;
    const songs = await SongModel.getByStatus(status);
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error);
  }
}

/**
 * Eliminar canción
 */
async function deleteSong(req, res) {
  try {
    const { songId } = req.params;

    // Obtener información de la canción
    const song = await SongModel.getById(songId);
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    // Eliminar archivos físicos
    const audioPath = path.join(paths.audio, song.file_name);
    await deleteFile(audioPath);

    if (song.features_file) {
      const featuresPath = path.join(paths.features, song.features_file);
      await deleteFile(featuresPath);
    }

    // Eliminar de la base de datos (soft delete)
    await SongModel.delete(songId);

    logger('info', `Canción eliminada ID: ${songId}`);
    sendResponse(res, true, null, 'Canción eliminada');

  } catch (error) {
    sendError(res, 'Error al eliminar canción', 500, error);
  }
}

/**
 * Descargar archivo de audio
 */
async function downloadAudio(req, res) {
  try {
    const { songId } = req.params;

    const song = await SongModel.getById(songId);
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    const audioPath = path.join(paths.audio, song.file_name);
    res.download(audioPath, song.name);

  } catch (error) {
    sendError(res, 'Error al descargar audio', 500, error);
  }
}

module.exports = {
  uploadSongs,
  extractSongFeatures,
  getSongFeatures,
  updateRating,
  getAllSongs,
  getSongsByPlaylist,
  getSongsByStatus,
  deleteSong,
  downloadAudio
};
