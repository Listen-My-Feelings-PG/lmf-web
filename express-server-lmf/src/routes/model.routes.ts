import { Router } from 'express';
import * as modelController from '../controllers/model.controller';

const router = Router();

// Obtener todos los modelos
router.get('/', modelController.getAllModels);

// Obtener modelo global
router.get('/global', modelController.getGlobalModel);

// Obtener modelo por playlist
router.get('/playlist/:playlistId', modelController.getModelByPlaylist);

// Obtener modelo por ID
router.get('/:modelId', modelController.getModelById);

// Guardar modelo
router.post('/save', modelController.saveModel);

// Descargar modelo
router.get('/:modelId/download', modelController.downloadModel);

// Actualizar predicciones
router.post('/predictions', modelController.updatePredictions);

// Desactivar modelo
router.put('/:modelId/deactivate', modelController.deactivateModel);

export default router;
