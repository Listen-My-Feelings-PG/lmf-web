import { Request, Response } from "express";
import { BadRequest, InternalServerError, Locked, NotFound, NotImplemented, sendError } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";
import path from "path";
import fs from "fs";
import { paths } from "../main";
import { isExtractionActive } from "../services/feature-extraction.service";
import {
  runTraining,
  runPrediction, tuneSingleSongById
} from "../services/tensorflow.service";
import { psql } from "../main";
import { addTask, isTaskActive } from "../subprocess/task.pool";
import { logger } from "../utils/env-validator";
import { TrainingMode } from "../types/generals.types";



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

/**
 * Controlador: Encola una tarea en segundo plano para realizar un "Fine-Tuning" rápido de una sola canción.
 * Útil cuando el usuario cambia la calificación de una canción y se quiere ajustar el modelo de IA
 * inmediatamente para reflejar ese cambio sin un entrenamiento masivo completo.
 */
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

/**
 * Controlador: Sirve el archivo de audio físico (MP3, WAV, FLAC) almacenado en el servidor para que 
 * pueda ser reproducido por el cliente (Angular) vía streaming HTTP.
 */
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

/**
 * Controlador: Actualiza la puntuación manual (userScore) de una canción (0 a 3).
 * Este endpoint es crítico porque la IA utiliza este valor como la etiqueta 'Y' 
 * para aprender las preferencias del usuario (Aprendizaje Supervisado).
 */
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
/**
 * Controlador: Encola una tarea masiva en segundo plano para entrenar los modelos de TensorFlow (Global y Locales) 
 * utilizando las canciones seleccionadas. 
 * Revisa el estado de la aplicación para prevenir ejecuciones superpuestas.
 * 
 * @param req req.body incluye { songIds: Array<number>, mode: "clean"|"infer", includeLocalTraining: boolean }
 */
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

    const mode: TrainingMode = req.body.mode;
    const includeLocalTraining: boolean = req.body.includeLocalTraining === 'true' || req.body.includeLocalTraining === true;

    if (!songIds || !Array.isArray(songIds) || songIds.length === 0) {
      sendError(res, 'Lista de IDs de canciones vacía o inválida', BadRequest, null);
      return;
    }

    if (!['clean', 'infer', 'none'].includes(mode)) { //Validación del mode
      sendError(res, 'Modo de entrenamiento inválido. Use "clean" o "infer".', BadRequest, null);
      return;
    }

    addTask({
      type: 'training',
      scope: 'multiple',
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

/**
 * Controlador: Encola una tarea en segundo plano para predecir las valoraciones de un grupo de canciones
 * utilizando el modelo Global ya entrenado. 
 * Muy útil para calcular la precisión (Accuracy) histórica y ver qué le gustaría escuchar al usuario hoy.
 */
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
      scope: 'multiple',
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

/**
 * Controlador: Encola una tarea crítica en segundo plano que elimina los archivos físicos (audio) 
 * y realiza un borrado lógico (soft delete) en la base de datos de manera masiva.
 * Validaciones estrictas previenen que se borre música mientras la IA u otro subproceso está usándolos.
 */
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
    scope: 'multiple',
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

/**
 * Controlador: Encola una tarea masiva en segundo plano para exportar una selección de canciones
 * a una carpeta especial ("Onboard"), útil para transferir a otros dispositivos o pendrives (Exportación USB).
 */
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
    scope: 'multiple',
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
