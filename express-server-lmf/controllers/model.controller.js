const path = require('path');
const fs = require('fs').promises;
const { paths } = require('../main');
const ModelModel = require('../models/model.model');
const SongModel = require('../models/song.model');
const {
  createZip,
  extractZip,
  sendResponse,
  sendError,
  logger,
  ensureDirectory
} = require('../services/file.service');

/**
 * Obtener todos los modelos
 */
async function getAllModels(req, res) {
  try {
    const models = await ModelModel.getAll();
    sendResponse(res, true, models, 'Modelos obtenidos');
  } catch (error) {
    sendError(res, 'Error al obtener modelos', 500, error);
  }
}

/**
 * Obtener modelo por ID
 */
async function getModelById(req, res) {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(modelId);
    if (!model) {
      return sendError(res, 'Modelo no encontrado', 404);
    }

    sendResponse(res, true, model, 'Modelo obtenido');

  } catch (error) {
    sendError(res, 'Error al obtener modelo', 500, error);
  }
}

/**
 * Obtener modelo por playlist
 */
async function getModelByPlaylist(req, res) {
  try {
    const { playlistId } = req.params;

    const model = await ModelModel.getByPlaylist(playlistId);
    if (!model) {
      return sendResponse(res, true, null, 'No hay modelo para esta playlist');
    }

    sendResponse(res, true, model, 'Modelo obtenido');

  } catch (error) {
    sendError(res, 'Error al obtener modelo', 500, error);
  }
}

/**
 * Guardar modelo de TensorFlow
 */
async function saveModel(req, res) {
  try {
    const { playlistId, modelName } = req.body;
    const modelFiles = req.files; // Asumiendo que se usa multer

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
    const zipPath = await createZip(tempDir, paths.models, zipName);

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
    sendError(res, 'Error al guardar modelo', 500, error);
  }
}

/**
 * Descargar modelo
 */
async function downloadModel(req, res) {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(modelId);
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
    sendError(res, 'Error al descargar modelo', 500, error);
  }
}

/**
 * Obtener modelo global
 */
async function getGlobalModel(req, res) {
  try {
    const model = await ModelModel.getGlobal();

    if (!model) {
      return sendResponse(res, true, null, 'No hay modelo global disponible');
    }

    sendResponse(res, true, model, 'Modelo global obtenido');

  } catch (error) {
    sendError(res, 'Error al obtener modelo global', 500, error);
  }
}

/**
 * Actualizar predicción de canciones
 */
async function updatePredictions(req, res) {
  try {
    const { predictions } = req.body;

    if (!Array.isArray(predictions) || predictions.length === 0) {
      return sendError(res, 'predictions debe ser un array no vacío', 400);
    }

    const updated = [];
    const errors = [];

    for (const pred of predictions) {
      try {
        await SongModel.updatePrediction(pred.songId, pred.prediction);
        updated.push(pred.songId);
      } catch (error) {
        errors.push({
          songId: pred.songId,
          error: error.message
        });
      }
    }

    logger('info', `Predicciones actualizadas: ${updated.length} exitosas, ${errors.length} fallidas`);
    sendResponse(res, true, { updated, errors }, 'Predicciones actualizadas');

  } catch (error) {
    sendError(res, 'Error al actualizar predicciones', 500, error);
  }
}

/**
 * Desactivar modelo
 */
async function deactivateModel(req, res) {
  try {
    const { modelId } = req.params;

    const model = await ModelModel.getById(modelId);
    if (!model) {
      return sendError(res, 'Modelo no encontrado', 404);
    }

    await ModelModel.deactivate(modelId);

    logger('info', `Modelo desactivado ID: ${modelId}`);
    sendResponse(res, true, null, 'Modelo desactivado');

  } catch (error) {
    sendError(res, 'Error al desactivar modelo', 500, error);
  }
}

module.exports = {
  getAllModels,
  getModelById,
  getModelByPlaylist,
  saveModel,
  downloadModel,
  getGlobalModel,
  updatePredictions,
  deactivateModel
};
