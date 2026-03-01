import { Request, Response } from "express";
import { BadRequest, InternalServerError, NotFound, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";
import { startFeatureExtraction, isExtractionActive } from "../services/feature-extraction.service";

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

export async function getAllSongsScoredByUser(_req: Request, res: Response): Promise<void> {
  try {
    const songs = await SongModel.getAllSongsScoredByUser();
    res.status(200).json({ success: true, data: songs, message: 'Canciones puntuadas por el usuario obtenidas correctamente' });
  } catch (error) {
    sendError(res, 'Error al obtener las canciones puntuadas por el usuario', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function trainSongsByIds(req: Request, res: Response): Promise<void> {
  let { songIds } = req.body;
  try {
    songIds = JSON.parse(songIds);
  } catch {
    sendError(res, 'Error al parsear la lista de IDs de canciones. Asegúrese de enviar un JSON válido.', BadRequest, null);
    return;
  }

  console.log('songIds', songIds);

  if (!songIds || !Array.isArray(songIds) || songIds.length === 0) {
    sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
    return;
  }

  // Verificar si ya hay un proceso de extracción activo
  if (isExtractionActive()) {
    res.status(423).json({
      success: false,
      message: 'Ya hay un proceso de extracción de features activo. Intente de nuevo más tarde.'
    });
    return;
  }

  try {
    // Obtener datos de canciones desde la BD
    const songs = await SongModel.getSongsByIds(songIds);

    if (songs.length === 0) {
      res.status(404).json({
        success: false,
        message: 'No se encontraron canciones con los IDs proporcionados'
      });
      return;
    }

    // Iniciar extracción de features en background (fire-and-forget)
    startFeatureExtraction(songs);

    // Responder inmediatamente al cliente
    res.status(200).json({
      success: true,
      message: `Extracción de features iniciada para ${songs.length} canciones. Revise la consola del servidor para ver el progreso.`
    });

  } catch (error) {
    console.error('Error en trainSongsByIds:', error);
    sendError(res, 'Error al iniciar la extracción de features', InternalServerError, error instanceof Error ? error : null);
  }
}