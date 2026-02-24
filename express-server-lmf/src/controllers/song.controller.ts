import { Request, Response } from "express";
import { BadRequest, InternalServerError, NotFound, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";

export async function serveSongById(req: Request, res: Response): Promise<void> {
  try {
    const idSong = parseInt(req.params.idSong, 10);
    if (isNaN(idSong))
      sendError(res, 'ID de canción inválido', BadRequest, null);
    else {
      const song = await SongModel.getById(idSong);
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

    console.log('req.body:', req.body);
    console.log('score:', score, 'typeof:', typeof score);

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