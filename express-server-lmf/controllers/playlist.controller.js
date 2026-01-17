const PlaylistModel = require('../models/playlist.model');
const SongModel = require('../models/song.model');
const { sendResponse, sendError, logger } = require('../services/file.service');

/**
 * Obtener todas las playlists
 */
async function getAllPlaylists(req, res) {
  try {
    const { all } = req.body;
    const playlists = await PlaylistModel.getAll(all === true);

    // Enriquecer con información de canciones
    const playlistsWithSongs = await Promise.all(
      playlists.map(async (playlist) => {
        const songs = await SongModel.getByPlaylist(playlist.id);
        return {
          ...playlist,
          songCount: songs.length
        };
      })
    );

    sendResponse(res, true, { list: playlistsWithSongs }, 'Playlists obtenidas');
  } catch (error) {
    sendError(res, 'Error al obtener playlists', 500, error);
  }
}

/**
 * Obtener playlist por ID
 */
async function getPlaylistById(req, res) {
  try {
    const { playlistId } = req.params;

    const playlist = await PlaylistModel.getById(playlistId);
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    // Obtener canciones de la playlist
    const songs = await SongModel.getByPlaylist(playlistId);

    sendResponse(res, true, {
      ...playlist,
      songs: songs
    }, 'Playlist obtenida');

  } catch (error) {
    sendError(res, 'Error al obtener playlist', 500, error);
  }
}

/**
 * Crear nueva playlist
 */
async function createPlaylist(req, res) {
  try {
    const { name, isGlobal = false } = req.body;

    if (!name || name.trim() === '') {
      return sendError(res, 'El nombre es requerido', 400);
    }

    const playlist = await PlaylistModel.create(name.trim(), isGlobal);

    logger('info', `Playlist creada: ${name} (ID: ${playlist.id})`);
    sendResponse(res, true, playlist, 'Playlist creada exitosamente');

  } catch (error) {
    sendError(res, 'Error al crear playlist', 500, error);
  }
}

/**
 * Actualizar nombre de playlist
 */
async function updatePlaylist(req, res) {
  try {
    const { playlistId } = req.params;
    const { name } = req.body;

    if (!name || name.trim() === '') {
      return sendError(res, 'El nombre es requerido', 400);
    }

    const playlist = await PlaylistModel.getById(playlistId);
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    await PlaylistModel.updateName(playlistId, name.trim());

    logger('info', `Playlist actualizada ID: ${playlistId}`);
    sendResponse(res, true, null, 'Playlist actualizada');

  } catch (error) {
    sendError(res, 'Error al actualizar playlist', 500, error);
  }
}

/**
 * Eliminar playlist
 */
async function deletePlaylist(req, res) {
  try {
    const { playlistId } = req.params;

    const playlist = await PlaylistModel.getById(playlistId);
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    if (playlist.is_global) {
      return sendError(res, 'No se puede eliminar la playlist global', 400);
    }

    await PlaylistModel.delete(playlistId);

    logger('info', `Playlist eliminada ID: ${playlistId}`);
    sendResponse(res, true, null, 'Playlist eliminada');

  } catch (error) {
    sendError(res, 'Error al eliminar playlist', 500, error);
  }
}

/**
 * Agregar canción a playlist
 */
async function addSongToPlaylist(req, res) {
  try {
    const { playlistId, songId } = req.body;

    if (!playlistId || !songId) {
      return sendError(res, 'playlistId y songId son requeridos', 400);
    }

    // Verificar que existan
    const playlist = await PlaylistModel.getById(playlistId);
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    const song = await SongModel.getById(songId);
    if (!song) {
      return sendError(res, 'Canción no encontrada', 404);
    }

    await PlaylistModel.addSong(playlistId, songId);

    logger('info', `Canción ${songId} agregada a playlist ${playlistId}`);
    sendResponse(res, true, null, 'Canción agregada a playlist');

  } catch (error) {
    sendError(res, 'Error al agregar canción a playlist', 500, error);
  }
}

/**
 * Remover canción de playlist
 */
async function removeSongFromPlaylist(req, res) {
  try {
    const { playlistId, songId } = req.body;

    if (!playlistId || !songId) {
      return sendError(res, 'playlistId y songId son requeridos', 400);
    }

    await PlaylistModel.removeSong(playlistId, songId);

    logger('info', `Canción ${songId} removida de playlist ${playlistId}`);
    sendResponse(res, true, null, 'Canción removida de playlist');

  } catch (error) {
    sendError(res, 'Error al remover canción de playlist', 500, error);
  }
}

/**
 * Obtener playlist global
 */
async function getGlobalPlaylist(req, res) {
  try {
    let playlist = await PlaylistModel.getGlobal();

    // Si no existe, crearla
    if (!playlist) {
      playlist = await PlaylistModel.create('Global', true);
      logger('info', 'Playlist global creada automáticamente');
    }

    // Obtener canciones
    const songs = await SongModel.getByPlaylist(playlist.id);

    sendResponse(res, true, {
      ...playlist,
      songs: songs
    }, 'Playlist global obtenida');

  } catch (error) {
    sendError(res, 'Error al obtener playlist global', 500, error);
  }
}

module.exports = {
  getAllPlaylists,
  getPlaylistById,
  createPlaylist,
  updatePlaylist,
  deletePlaylist,
  addSongToPlaylist,
  removeSongFromPlaylist,
  getGlobalPlaylist
};
