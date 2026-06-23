import { Request, Response } from "express";
import { BadRequest, InternalServerError, Locked, NotFound, NotImplemented, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";
import { isExtractionActive } from "../services/feature-extraction.service";
import { startTraining, startPrediction, tuneSingleSongById, createAndRegisterModel } from "../services/tensorflow.service";
import { psql } from "../main";
import { addTask, isTaskActive, removeTask } from "../subprocess/task.pool";
import { emitTaskExec, emitTaskFinish } from "../services/socket.service";
import TsModelModel from "../models/tensorflow-db.model";
import { logger } from "../utils/env-validator";

type SongDeleteFailure = {
  id: number;
  fileName: string;
  error: string;
};

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

  const taskId = addTask('fine-tuning', idSong);
  try {
    await psql`UPDATE public.canciones SET ca_ts_status = 'fine-tuning' WHERE ca_id = ${idSong}`;
    emitTaskExec({ type: 'fine-tuning', songId: idSong, message: `Iniciando fine-tuning para la canción ${idSong}` });

    const updatedSong = await tuneSingleSongById(idSong);
    res.status(200).json({ success: true, data: updatedSong, message: 'Fine-tuning completado' });
  } catch (error) {
    sendError(res, 'Error al hacer fine-tuning', InternalServerError, error instanceof Error ? error : null);
  } finally {
    await psql`UPDATE public.canciones SET ca_ts_status = null WHERE ca_id = ${idSong}`;
    removeTask(taskId);
    emitTaskFinish({ type: 'fine-tuning', songId: idSong, message: `Fine-tuning completado para la canción ${idSong}` });
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

  const taskId = addTask('library-deletion');
  try {
    const songs = await SongModel.getSongsByIds(ids);
    if (songs.length === 0) {
      sendError(res, 'No se encontraron canciones activas para borrar', NotFound, null);
      return;
    }

    const deletedIds: number[] = [];
    const missingFileIds: number[] = [];
    const failures: SongDeleteFailure[] = [];

    for (const song of songs) {
      const songId = song.id!;
      try {
        const filePath = resolveAudioFilePath(song.fileName);
        await fs.promises.unlink(filePath);
        deletedIds.push(songId);
      } catch (error) {
        const code = error && typeof error === 'object' && 'code' in error
          ? String((error as NodeJS.ErrnoException).code)
          : '';

        if (code === 'ENOENT') {
          missingFileIds.push(songId);
          deletedIds.push(songId);
          logger('warn', `Archivo de audio no encontrado al borrar. Se desactivara en BD: ${song.fileName}`);
        } else {
          failures.push({
            id: songId,
            fileName: song.fileName,
            error: error instanceof Error ? error.message : String(error)
          });
        }
      }
    }

    if (deletedIds.length > 0)
      await SongModel.logicalDeleteByIds(deletedIds);

    if (deletedIds.length === 0) {
      sendError(res, 'No se pudo borrar ninguna cancion de la biblioteca', InternalServerError, failures[0] ? new Error(failures[0].error) : null);
      return;
    }

    const message = failures.length === 0
      ? `${deletedIds.length} canciones eliminadas de la biblioteca.`
      : `${deletedIds.length} canciones eliminadas de la biblioteca. ${failures.length} no se pudieron borrar.`;

    res.status(failures.length > 0 ? 207 : 200).json({
      success: failures.length === 0,
      message,
      deletedIds,
      missingFileIds,
      failures
    });
  } catch (error) {
    sendError(res, 'Error al eliminar canciones de la biblioteca', InternalServerError, error instanceof Error ? error : null);
  } finally {
    removeTask(taskId);
    emitTaskFinish({ type: 'library-deletion', message: 'Borrado de biblioteca completado' });
  }
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

  // Fire-and-forget: responder 202 inmediatamente
  res.status(202).json({
    success: true,
    message: `Copia iniciada para ${ids.length} canciones. Carpeta destino: ${folderName}`
  });

  // Proceso asíncrono de copia
  const taskId = addTask('onboard-copy');
  emitTaskExec({ type: 'onboard-copy', message: `Iniciando copia de ${ids.length} canciones a onboard` });
  (async () => {
    try {
      const songs = await SongModel.getSongsByIds(ids);
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
    } finally {
      removeTask(taskId);
      emitTaskFinish({ type: 'onboard-copy', message: 'Copia de onboarding completada' });
    }
  })();
}
