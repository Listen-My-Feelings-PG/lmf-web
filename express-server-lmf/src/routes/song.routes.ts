import { Router } from 'express';
import * as songController from '../controllers/song.controller';

const router = Router();

// Subir canciones
router.post('/upload', songController.uploadSongs);

// Obtener todas las canciones
router.get('/', songController.getAllSongs);

// Obtener canciones por playlist
router.get('/playlist/:playlistId', songController.getSongsByPlaylist);

// Obtener canciones por estado
router.get('/status/:status', songController.getSongsByStatus);

// Extraer características de una canción
router.post('/:songId/extract-features', songController.extractSongFeatures);

// Obtener características de una canción
router.get('/:songId/features', songController.getSongFeatures);

// Actualizar calificación
router.put('/:songId/rating', songController.updateRating);

// Descargar audio
router.get('/:songId/download', songController.downloadAudio);

// Eliminar canción
router.delete('/:songId', songController.deleteSong);

export default router;
