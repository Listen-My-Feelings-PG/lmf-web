import { Request, Response } from "express";
import { BadRequest, InternalServerError, Locked, NotFound, NotImplemented, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";
import { isExtractionActive } from "../services/feature-extraction.service";
import { runTraining, runPrediction, tuneSingleSongById, createAndRegisterModel } from "../services/tensorflow.service";
import { psql } from "../main";
import { addTask, isTaskActive } from "../subprocess/task.pool";
import TsModelModel from "../models/tensorflow-db.model";
import { logger } from "../utils/env-validator";



function parseSongIds(rawSongIds: unknown): number[] | null {
  try {
    const parsed = typeof rawSongIds === 'string' ? JSON.parse(rawSongIds) : rawSongIds;
    if (!Array.isArray(parsed) || parsed.length === 0)
      return null;

    const ids = parsed.map(Number).filter(id => Number.isInteger(id) && id > 0);
    return ids.length > 0 ? [...new Set(ids)] : null;
  } catch {
    return null;
  }
}

function resolveAudioFilePath(fileName: string): string {
  const audioRoot = path.resolve(paths.audio);
  const filePath = path.resolve(audioRoot, fileName);
  const relativePath = path.relative(audioRoot, filePath);

  if (relativePath.startsWith('..') || path.isAbsolute(relativePath))
    throw new Error(`Archivo fuera del directorio de audio: ${fileName}`);

  return filePath;
}

export async function tuneSingleSong(req: Request, res: Response): Promise<void> {
  const idSong = parseInt(req.params.idSong, 10);
  if (isNaN(idSong)) {
    sendError(res, 'ID de canción inválido', BadRequest, null);
    return;
  }

  if (isTaskActive('fine-tuning', idSong)) {
    sendError(res, 'Esta canción ya está en proceso de fine-tuning.', Locked, null);
    return;
  }

  try {
    await psql`UPDATE public.canciones SET ca_ts_status = 'fine-tuning' WHERE ca_id = ${idSong}`;
    
    addTask({
      type: 'fine-tuning',
      scope: 'single',
      songIds: [idSong],
      execute: async (ids) => {
        try {
          await tuneSingleSongById(ids[0]);
        } finally {
          await psql`UPDATE public.canciones SET ca_ts_status = null WHERE ca_id = ${ids[0]}`;
        }
      }
    });

    res.status(200).json({ success: true, message: 'Fine-tuning encolado correctamente' });
  } catch (error) {
    sendError(res, 'Error al encolar fine-tuning', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function serveSongById(req: Request, res: Response): Promise<void> {
  try {
    const idSong = parseInt(req.params.idSong, 10);
    if (isNaN(idSong)) {
      sendError(res, 'ID de canción inválido', BadRequest, null);
      return;
    }

    const song = await SongModel.getSongById(idSong);

    if (!song) {
      sendError(res, 'Canción no encontrada', NotFound, null);
      return;
    }

    const filePath = path.resolve(paths.audio, song.fileName);

    if (!fs.existsSync(filePath)) {
      sendError(res, 'Archivo de audio no encontrado', NotFound, null);
      return;
    }

    res.sendFile(filePath, (err) => {
      if (err) {
        console.error('Error al enviar archivo:', err);
        if (!res.headersSent)
          sendError(res, 'Error al enviar el archivo de audio', InternalServerError, err);
      }
    });

  } catch (error) {
    sendError(res, 'Error al obtener las playlists', InternalServerError, error instanceof Error ? error : null);
    return;
  }
}

export async function rateSongById(req: Request, res: Response): Promise<void> {
  try {
    const idSong = parseInt(req.params.idSong, 10);
    const score = parseInt(req.body.score, 10);

    if (isNaN(idSong) || isNaN(score) || score < 0 || score > 3) {
      sendError(res, 'ID de canción o puntuación inválidos', BadRequest, null);
      return;
    }

    const updatedSong = await SongModel.setSongUserScoreByIdSong(idSong, score);
    res.status(200).json({ success: true, data: updatedSong, message: 'Puntuación actualizada correctamente' });
  } catch (error) {
    sendError(res, 'Error al actualizar la puntuación de la canción', InternalServerError, error instanceof Error ? error : null);
    return;
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

export async function trainSongsByIdsRefactor(req: Request, res: Response): Promise<void> {
  //NOTA: esta función no será fire-and-forget
  //1. Obtención y validación de ids

  let songIds: number[];
  try {
    songIds = JSON.parse(req.body.songIds);
    //Verificar que sea un array de números
    if (!Array.isArray(songIds) || !songIds.every(id => typeof id === 'number')) {
      sendError(res, 'songIds debe ser un array de números', BadRequest, null);
      return;
    }
  } catch {
    sendError(res, 'Error al parsear songIds. Envíe un JSON válido.', BadRequest, null);
    return;
  }

  let globalTsModel = await TsModelModel.getGlobalModel();
  if (!globalTsModel) {
    logger('warn', 'No hay modelo global Se procede a crear el modelo global ahora');
    globalTsModel = await createAndRegisterModel(true, 'model_global');
    //await PlaylistModel.updateModelId(defaultPlaylist.id!, globalModel.id!);
  }
  //2. Obtención de las canciones como Array<Song>
}

export async function trainSongsByIds(req: Request, res: Response): Promise<void> {
  // Verificar si hay un proceso de extracción de features activo
  if (isExtractionActive()) {
    sendError(res, 'La extracción de features aún está en progreso. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de entrenamiento activo
  if (isTaskActive('training')) {
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

    const mode = req.body.mode;
    const includeLocalTraining = req.body.includeLocalTraining === 'true' || req.body.includeLocalTraining === true;

    if (!songIds || !Array.isArray(songIds) || songIds.length === 0) {
      sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
      return;
    }

    if (!['clean', 'infer', 'none'].includes(mode)) {
      sendError(res, 'Modo de entrenamiento inválido. Use "clean" o "infer".', BadRequest, null);
      return;
    }

    addTask({
      type: 'training',
      scope: 'global',
      songIds,
      execute: async (ids) => {
        await runTraining(ids, mode, includeLocalTraining);
      }
    });

    res.status(200).json({
      success: true,
      message: `Entrenamiento de ${songIds.length} canciones encolado.`
    });
  } catch (error) {
    sendError(res, 'Error al encolar el entrenamiento', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function predictSongsByIds(req: Request, res: Response): Promise<void> {
  // Verificar si hay un proceso de extracción de features activo
  if (isExtractionActive()) {
    sendError(res, 'La extracción de features aún está en progreso. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de entrenamiento activo
  if (isTaskActive('training')) {
    sendError(res, 'Hay un proceso de entrenamiento activo. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  // Verificar si hay un proceso de predicción activo
  if (isTaskActive('prediction')) {
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

    addTask({
      type: 'prediction',
      scope: 'global',
      songIds,
      execute: async (ids) => {
        await runPrediction(ids);
      }
    });

    res.status(200).json({
      success: true,
      message: `Predicción de ${songIds.length} canciones encolada.`
    });
  } catch (error) {
    sendError(res, 'Error al encolar la predicción', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function deleteSelectedSongsFromLibrary(req: Request, res: Response): Promise<void> {
  const ids = parseSongIds(req.body.songIds);
  if (!ids) {
    sendError(res, 'Lista de IDs de canciones vacia o invalida', BadRequest, null);
    return;
  }

  if (isExtractionActive()) {
    sendError(res, 'La extraccion de features esta en progreso. Intente de nuevo cuando termine.', Locked, null);
    return;
  }

  if (isTaskActive('training')) {
    sendError(res, 'Hay un proceso de entrenamiento activo. Intente mas tarde.', Locked, null);
    return;
  }

  if (isTaskActive('prediction')) {
    sendError(res, 'Hay un proceso de prediccion activo. Intente mas tarde.', Locked, null);
    return;
  }

  if (isTaskActive('onboard-copy')) {
    sendError(res, 'Hay una copia de onboarding en proceso. Intente mas tarde.', Locked, null);
    return;
  }

  if (isTaskActive('library-deletion')) {
    sendError(res, 'Hay un borrado de biblioteca en proceso. Intente mas tarde.', Locked, null);
    return;
  }

  addTask({
    type: 'library-deletion',
    scope: 'global',
    songIds: ids,
    execute: async (targetIds) => {
      const songs = await SongModel.getSongsByIds(targetIds);
      if (songs.length === 0) return;

      const deletedIds: number[] = [];
      for (const song of songs) {
        const songId = song.id!;
        try {
          const filePath = resolveAudioFilePath(song.fileName);
          await fs.promises.unlink(filePath);
          deletedIds.push(songId);
        } catch (error) {
          const code = error && typeof error === 'object' && 'code' in error
            ? String((error as NodeJS.ErrnoException).code) : '';
          if (code === 'ENOENT') {
            deletedIds.push(songId);
            logger('warn', `Archivo no encontrado al borrar. Se desactivará en BD: ${song.fileName}`);
          }
        }
      }

      if (deletedIds.length > 0)
        await SongModel.logicalDeleteByIds(deletedIds);
    }
  });

  res.status(202).json({
    success: true,
    message: `Borrado de ${ids.length} canciones encolado.`
  });
}

export async function copySelectedSongsToOnboard(req: Request, res: Response): Promise<void> {
  let ids: number[];
  try {
    ids = JSON.parse(req.body.songIds);
    if (!Array.isArray(ids) || ids.length === 0) {
      sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
      return;
    }
    ids = ids.map(Number).filter(n => !isNaN(n));
    if (ids.length === 0) {
      sendError(res, 'Los IDs de canciones deben ser números válidos', BadRequest, null);
      return;
    }
  } catch {
    sendError(res, 'Error al parsear songIds. Envíe un JSON válido.', BadRequest, null);
    return;
  }

  if (isTaskActive('onboard-copy')) {
    sendError(res, 'Hay una copia de onboarding en proceso. Intente más tarde.', Locked, null);
    return;
  }

  if (isTaskActive('library-deletion')) {
    sendError(res, 'Hay un borrado de biblioteca en proceso. Intente mas tarde.', Locked, null);
    return;
  }

  // Generar nombre de carpeta: yyyyMMdd_HHmmsscc
  const now = new Date();
  const pad = (n: number, len = 2) => String(n).padStart(len, '0');
  const folderName = `${now.getFullYear()}${pad(now.getMonth() + 1)}${pad(now.getDate())}_${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}${pad(Math.floor(now.getMilliseconds() / 10))}`;
  const destFolder = path.resolve(paths.onboard, folderName);

  addTask({
    type: 'onboard-copy',
    scope: 'global',
    songIds: ids,
    execute: async (targetIds) => {
      try {
        const songs = await SongModel.getSongsByIds(targetIds);
        if (!fs.existsSync(destFolder))
          fs.mkdirSync(destFolder, { recursive: true });

        for (const song of songs) {
          const src = path.resolve(paths.audio, song.fileName);
          if (fs.existsSync(src)) {
            const dest = path.join(destFolder, song.fileName);
            fs.copyFileSync(src, dest);
          } else {
            logger('warn', `⚠️  Archivo no encontrado, se omite: ${song.fileName}`);
          }
        }
        logger('info', `✅ Onboarding completado. ${songs.length} canciones copiadas a: ${destFolder}`);
      } catch (error) {
        logger('error', '❌ Error durante la copia de onboarding', error);
      }
    }
  });

  res.status(202).json({
    success: true,
    message: `Copia iniciada para ${ids.length} canciones. Carpeta destino: ${folderName}`
  });
}
