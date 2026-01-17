const express = require('express');
const router = express.Router();
const playlistController = require('../controllers/playlist.controller');

// Obtener todas las playlists
router.post('/get-all', playlistController.getAllPlaylists);

// Obtener playlist global
router.get('/global', playlistController.getGlobalPlaylist);

// Obtener playlist por ID
router.get('/:playlistId', playlistController.getPlaylistById);

// Crear nueva playlist
router.post('/', playlistController.createPlaylist);

// Actualizar playlist
router.put('/:playlistId', playlistController.updatePlaylist);

// Eliminar playlist
router.delete('/:playlistId', playlistController.deletePlaylist);

// Agregar canción a playlist
router.post('/add-song', playlistController.addSongToPlaylist);

// Remover canción de playlist
router.post('/remove-song', playlistController.removeSongFromPlaylist);

module.exports = router;
