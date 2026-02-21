import multer from 'multer';
import path from 'path';
import { Request, Response } from 'express';
import { paths } from '../main';
import SongModel from '../models/song.model';
import PlaylistModel from '../models/playlist.model';
import {
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
} from '../services/file.service';

// Configuración de multer para subida de archivos
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: { fileSize: 100 * 1024 * 1024 }, // 100MB
  fileFilter: (_req, file, cb) => {
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
export async function uploadSongs(req: Request, res: Response): Promise<void> {
  upload(req, res, async (err) => {
    if (err) {
      return sendError(res, 'Error al subir archivos', 400, err);
    }

    try {
      const { playlistId, initStatus = 'train' } = req.body;
      const files = req.files as Express.Multer.File[];

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

      const uploadedSongs: any[] = [];
      const errors: any[] = [];

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
        } catch (error: any) {
          logger('error', `Error al procesar ${file.originalname}:`, error);
          errors.push({
            fileName: file.originalname,
            error: error.message
          });
        }
      }

      sendResponse(
        res,
        true,
        {
          uploaded: uploadedSongs,
          errors: errors,
          total: files.length,
          successful: uploadedSongs.length,
          failed: errors.length
        },
        'Archivos procesados'
      );
    } catch (error) {
      sendError(res, 'Error al procesar archivos', 500, error as Error);
    }
  });
}

/**
 * Extraer características de una canción
 */
export async function extractSongFeatures(req: Request, res: Response): Promise<void> {
  try {
    const { songId } = req.params;

    // Obtener información de la canción
    const song = await SongModel.getById(parseInt(songId));
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
    await SongModel.updateFeaturesStatus(parseInt(songId), featuresFileName, 'trained');

    logger('info', `Características extraídas para canción ID: ${songId}`);
    sendResponse(
      res,
      true,
      { features, fileName: featuresFileName },
      'Características extraídas exitosamente'
    );
  } catch (error) {
    sendError(res, 'Error al extraer características', 500, error as Error);
  }
}

/**
 * Obtener características de una canción
 */
export async function getSongFeatures(req: Request, res: Response): Promise<void> {
  try {
    const { songId } = req.params;

    const song = await SongModel.getById(parseInt(songId));
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
    sendError(res, 'Error al obtener características', 500, error as Error);
  }
}

/**
 * Actualizar calificación de una canción
 */
export async function updateRating(req: Request, res: Response): Promise<void> {
  try {
    const { songId } = req.params;
    const { rating } = req.body;

    if (rating < 0 || rating > 3) {
      return sendError(res, 'La calificación debe estar entre 0 y 3', 400);
    }

    await SongModel.updateRating(parseInt(songId), rating);

    logger(
      'info',
      `Calificación actualizada para canción ID: ${songId} - Rating: ${rating}`
    );
    sendResponse(res, true, null, 'Calificación actualizada');
  } catch (error) {
    sendError(res, 'Error al actualizar calificación', 500, error as Error);
  }
}

/**
 * Obtener todas las canciones
 */
export async function getAllSongs(_req: Request, res: Response): Promise<void> {
  try {
    const songs = await SongModel.getAll();
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error as Error);
  }
}

/**
 * Obtener canciones por playlist
 */
export async function getSongsByPlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId } = req.params;
    const songs = await SongModel.getByPlaylist(parseInt(playlistId));
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error as Error);
  }
}

/**
 * Obtener canciones por estado
 */
export async function getSongsByStatus(req: Request, res: Response): Promise<void> {
  try {
    const { status } = req.params;
    const songs = await SongModel.getByStatus(status);
    sendResponse(res, true, songs, 'Canciones obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener canciones', 500, error as Error);
  }
}

/**
 * Eliminar canción
 */
export async function deleteSong(req: Request, res: Response): Promise<void> {
  try {
    const { songId } = req.params;

    // Obtener información de la canción
    const song = await SongModel.getById(parseInt(songId));
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
    await SongModel.delete(parseInt(songId));

    logger('info', `Canción eliminada ID: ${songId}`);
    sendResponse(res, true, null, 'Canción eliminada');
  } catch (error) {
    sendError(res, 'Error al eliminar canción', 500, error as Error);
  }
}

/**
 * Descargar archivo de audio
 */
export async function downloadAudio(req: Request, res: Response): Promise<void> {
  try {
    const { songId } = req.params;

    const song = await SongModel.getById(parseInt(songId));
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    const audioPath = path.join(paths.audio, song.file_name);
    res.download(audioPath, song.name);
  } catch (error) {
    sendError(res, 'Error al descargar audio', 500, error as Error);
  }
}
