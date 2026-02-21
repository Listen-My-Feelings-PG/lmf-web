import path from 'path';
import fs from 'fs/promises';
import { Request, Response } from 'express';
import { paths } from '../main';
import ModelModel from '../models/model.model';
import SongModel from '../models/song.model';
import {
  createZip,
  sendResponse,
  sendError,
  logger,
  ensureDirectory
} from '../services/file.service';

/**
 * Obtener todos los modelos
 */
export async function getAllModels(_req: Request, res: Response): Promise<void> {
  try {
    const models = await ModelModel.getAll();
    sendResponse(res, true, models, 'Modelos obtenidos');
  } catch (error) {
    sendError(res, 'Error al obtener modelos', 500, error as Error);
  }
}

/**
 * Obtener modelo por ID
 */
export async function getModelById(req: Request, res: Response): Promise<void> {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(parseInt(modelId));
    if (!model) {
      return sendError(res, 'Modelo no encontrado', 404);
    }

    sendResponse(res, true, model, 'Modelo obtenido');
  } catch (error) {
    sendError(res, 'Error al obtener modelo', 500, error as Error);
  }
}

/**
 * Obtener modelo por playlist
 */
export async function getModelByPlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId } = req.params;

    const model = await ModelModel.getByPlaylist(parseInt(playlistId));
    if (!model) {
      return sendResponse(res, true, null, 'No hay modelo para esta playlist');
    }

    sendResponse(res, true, model, 'Modelo obtenido');
  } catch (error) {
    sendError(res, 'Error al obtener modelo', 500, error as Error);
  }
}

/**
 * Guardar modelo de TensorFlow
 */
export async function saveModel(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId, modelName } = req.body;
    const modelFiles = req.files as Express.Multer.File[]; // Asumiendo que se usa multer

    if (!playlistId || !modelName) {
      return sendError(res, 'playlistId y modelName son requeridos', 400);
    }

    if (!modelFiles || modelFiles.length === 0) {
      return sendError(res, 'No se recibieron archivos del modelo', 400);
    }

    // Crear directorio temporal para el modelo
    const timestamp = Date.now();
    const tempDir = path.join(paths.models, `temp_${timestamp}`);
    await ensureDirectory(tempDir);

    // Guardar archivos del modelo en directorio temporal
    for (const file of modelFiles) {
      const filePath = path.join(tempDir, file.originalname);
      await fs.writeFile(filePath, file.buffer);
    }

    // Crear ZIP del modelo
    const zipName = `model_${playlistId}_${timestamp}.zip`;
    await createZip(tempDir, paths.models, zipName);

    // Eliminar directorio temporal
    await fs.rm(tempDir, { recursive: true, force: true });

    // Guardar registro en la base de datos
    const model = await ModelModel.create({
      name: modelName,
      playlistId: playlistId,
      path: zipName
    });

    logger('info', `Modelo guardado: ${modelName} (ID: ${model.id})`);
    sendResponse(res, true, model, 'Modelo guardado exitosamente');
  } catch (error) {
    sendError(res, 'Error al guardar modelo', 500, error as Error);
  }
}

/**
 * Descargar modelo
 */
export async function downloadModel(req: Request, res: Response): Promise<void> {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(parseInt(modelId));
    if (!model) {
      return sendError(res, 'Modelo no encontrado', 404);
    }

    const modelPath = path.join(paths.models, model.path);

    // Verificar que el archivo existe
    try {
      await fs.access(modelPath);
    } catch (error) {
      return sendError(res, 'Archivo de modelo no encontrado', 404);
    }

    res.download(modelPath, model.path);
  } catch (error) {
    sendError(res, 'Error al descargar modelo', 500, error as Error);
  }
}

/**
 * Obtener modelo global
 */
export async function getGlobalModel(_req: Request, res: Response): Promise<void> {
  try {
    const model = await ModelModel.getGlobal();

    if (!model) {
      return sendResponse(res, true, null, 'No hay modelo global disponible');
    }

    sendResponse(res, true, model, 'Modelo global obtenido');
  } catch (error) {
    sendError(res, 'Error al obtener modelo global', 500, error as Error);
  }
}

/**
 * Actualizar predicción de canciones
 */
export async function updatePredictions(req: Request, res: Response): Promise<void> {
  try {
    const { predictions } = req.body;

    if (!Array.isArray(predictions) || predictions.length === 0) {
      return sendError(res, 'predictions debe ser un array no vacío', 400);
    }

    const updated: number[] = [];
    const errors: any[] = [];

    for (const pred of predictions) {
      try {
        await SongModel.updatePrediction(pred.songId, pred.prediction);
        updated.push(pred.songId);
      } catch (error: any) {
        errors.push({
          songId: pred.songId,
          error: error.message
        });
      }
    }

    logger(
      'info',
      `Predicciones actualizadas: ${updated.length} exitosas, ${errors.length} fallidas`
    );
    sendResponse(res, true, { updated, errors }, 'Predicciones actualizadas');
  } catch (error) {
    sendError(res, 'Error al actualizar predicciones', 500, error as Error);
  }
}

/**
 * Desactivar modelo
 */
export async function deactivateModel(req: Request, res: Response): Promise<void> {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(parseInt(modelId));
    if (!model) {
      return sendError(res, 'Modelo no encontrado', 404);
    }

    await ModelModel.deactivate(parseInt(modelId));

    logger('info', `Modelo desactivado ID: ${modelId}`);
    sendResponse(res, true, null, 'Modelo desactivado');
  } catch (error) {
    sendError(res, 'Error al desactivar modelo', 500, error as Error);
  }
}
