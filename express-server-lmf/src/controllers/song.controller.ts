import { Request, Response } from "express";
import { BadRequest, InternalServerError, Locked, NotFound, NotImplemented, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";
import { isExtractionActive } from "../services/feature-extraction.service";
import { isTrainingActive, startTraining, isPredictionActive, startPrediction, tuneSingleSongById } from "../services/tensorflow.service";

export async function tuneSingleSong(req: Request, res: Response): Promise<void> {
  const idSong = parseInt(req.params.idSong, 10);
  if (isNaN(idSong)) {
    sendError(res, 'ID de canción inválido', BadRequest, null);
    return;
  }

  if (isTrainingActive()) {
    sendError(res, 'Hay un proceso de entrenamiento activo. Intente más tarde.', Locked, null);
    return;
  }

  try {
    const updatedSong = await tuneSingleSongById(idSong);
    res.status(200).json({ success: true, data: updatedSong, message: 'Fine-tuning completado' });
  } catch (error) {
    sendError(res, 'Error al hacer fine-tuning', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function serveSongById(req: Request, res: Response): Promise<void> {
  try {
    const idSong = parseInt(req.params.idSong, 10);
    if (isNaN(idSong))
      sendError(res, 'ID de canción inválido', BadRequest, null);
    else {
      const song = await SongModel.getSongById(idSong);
      if (song) {
        const filePath = path.resolve(paths.audio, song.fileName);

        // Verificar que el archivo existe
        if (!fs.existsSync(filePath)) {
          sendError(res, 'Archivo de audio no encontrado', NotFound, null);
          return;
        }

        // Enviar el archivo
        res.sendFile(filePath, (err) => {
          if (err) {
            console.error('Error al enviar archivo:', err);
            if (!res.headersSent)
              sendError(res, 'Error al enviar el archivo de audio', InternalServerError, err);
          }
        });
      } else {
        sendError(res, 'Canción no encontrada', NotFound, null);
      }
    }
  } catch (error) {
    sendError(res, 'Error al obtener las playlists', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function rateSongById(req: Request, res: Response): Promise<void> {
  try {
    const idSong = parseInt(req.params.idSong, 10);
    const score = parseInt(req.body.score, 10);

    if (isNaN(idSong) || isNaN(score) || score < 0 || score > 3)
      sendError(res, 'ID de canción o puntuación inválidos', BadRequest, null);
    else {
      await SongModel.setSongUserScoreByIdSong(idSong, score);
      res.status(200).json({ success: true, message: 'Puntuación actualizada correctamente' });
    }
  } catch (error) {
    sendError(res, 'Error al actualizar la puntuación de la canción', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function getAllSongsScoredByUserInPlaylists(req: Request, res: Response): Promise<void> {
  try {
    const playlistsIds = req.params.playlistsIds ? JSON.parse(req.params.playlistsIds) : null;
    if (playlistsIds) {
      sendError(res, 'Funcionalidad no implementada', NotImplemented, null);
      return;
    } else {
      const songs = await SongModel.getAllSongsScoredByUserInDefaultPlaylist();
      res.status(200).json({ success: true, data: songs, message: 'Canciones puntuadas por el usuario obtenidas correctamente' });
    }

  } catch (error) {
    sendError(res, 'Error al obtener las canciones puntuadas por el usuario', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function getSongsForPrediction(req: Request, res: Response): Promise<void> {
  try {
    const playlistsIds = req.params.playlistsIds ? JSON.parse(req.params.playlistsIds) : null;
    if (playlistsIds) {
      sendError(res, 'Funcionalidad no implementada', NotImplemented, null);
      return;
    } else {
      const songs = await SongModel.getAllSongsInDefaultPlaylist();
      res.status(200).json({ success: true, data: songs, message: 'Canciones para predicción obtenidas correctamente' });
    }
  } catch (error) {
    sendError(res, 'Error al obtener las canciones para predicción', InternalServerError, error instanceof Error ? error : null);
    return;
  }
}

export async function trainSongsByIds(req: Request, res: Response): Promise<void> {
  // Verificar si hay un proceso de extracción de features activo
  if (isExtractionActive()) {
    sendError(res, 'La extracción de features aún está en progreso. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de entrenamiento activo
  if (isTrainingActive()) {
    sendError(res, 'Ya hay un proceso de entrenamiento activo. Intente más tarde.', Locked, null);
    return;
  }

  try {
    let songIds: number[];
    try {
      songIds = JSON.parse(req.body.songIds);
    } catch {
      sendError(res, 'Error al parsear songIds. Envíe un JSON válido.', BadRequest, null);
      return;
    }

    const mode = req.body.mode || 'clean';
    const includeLocalTraining = req.body.includeLocalTraining === 'true' || req.body.includeLocalTraining === true;

    if (!songIds || !Array.isArray(songIds) || songIds.length === 0) {
      sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
      return;
    }

    if (!['clean', 'infer', 'none'].includes(mode)) {
      sendError(res, 'Modo de entrenamiento inválido. Use "clean" o "infer".', BadRequest, null);
      return;
    }

    // Fire-and-forget: iniciar entrenamiento en background
    startTraining(songIds, mode, includeLocalTraining);

    res.status(200).json({
      success: true,
      message: `Entrenamiento iniciado para ${songIds.length} canciones (modo: ${mode}, local: ${includeLocalTraining}). Revise la consola del servidor.`
    });
  } catch (error) {
    sendError(res, 'Error al iniciar el entrenamiento', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function predictSongsByIds(req: Request, res: Response): Promise<void> {
  // Verificar si hay un proceso de extracción de features activo
  if (isExtractionActive()) {
    sendError(res, 'La extracción de features aún está en progreso. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de entrenamiento activo
  if (isTrainingActive()) {
    sendError(res, 'Hay un proceso de entrenamiento activo. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de predicción activo
  if (isPredictionActive()) {
    sendError(res, 'Ya hay un proceso de predicción activo. Intente más tarde.', Locked, null);
    return;
  }

  try {
    let songIds: number[];
    try {
      songIds = JSON.parse(req.body.songIds);
    } catch {
      sendError(res, 'Error al parsear songIds. Envíe un JSON válido.', BadRequest, null);
      return;
    }

    if (!songIds || !Array.isArray(songIds) || songIds.length === 0) {
      sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
      return;
    }

    // Fire-and-forget: iniciar predicción en background
    startPrediction(songIds);

    res.status(200).json({
      success: true,
      message: `Predicción iniciada para ${songIds.length} canciones. Revise la consola del servidor.`
    });
  } catch (error) {
    sendError(res, 'Error al iniciar la predicción', InternalServerError, error instanceof Error ? error : null);
  }
}