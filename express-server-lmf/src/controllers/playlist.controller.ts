import { Request, Response } from 'express';
import PlaylistModel from '../models/playlist.model';
import SongModel from '../models/song.model';
import { sendResponse, sendError, logger } from '../services/file.service';

/**
 * Obtener todas las playlists
 */
export async function getAllPlaylists(req: Request, res: Response): Promise<void> {
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
    sendError(res, 'Error al obtener playlists', 500, error as Error);
  }
}

/**
 * Obtener playlist por ID
 */
export async function getPlaylistById(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId } = req.params;

    const playlist = await PlaylistModel.getById(parseInt(playlistId));
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    // Obtener canciones de la playlist
    const songs = await SongModel.getByPlaylist(parseInt(playlistId));

    sendResponse(
      res,
      true,
      {
        ...playlist,
        songs: songs
      },
      'Playlist obtenida'
    );
  } catch (error) {
    sendError(res, 'Error al obtener playlist', 500, error as Error);
  }
}

/**
 * Crear nueva playlist
 */
export async function createPlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { name, isGlobal = false } = req.body;

    if (!name || name.trim() === '') {
      return sendError(res, 'El nombre es requerido', 400);
    }

    const playlist = await PlaylistModel.create(name.trim(), isGlobal);

    logger('info', `Playlist creada: ${name} (ID: ${playlist.id})`);
    sendResponse(res, true, playlist, 'Playlist creada exitosamente');
  } catch (error) {
    sendError(res, 'Error al crear playlist', 500, error as Error);
  }
}

/**
 * Actualizar nombre de playlist
 */
export async function updatePlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId } = req.params;
    const { name } = req.body;

    if (!name || name.trim() === '') {
      return sendError(res, 'El nombre es requerido', 400);
    }

    const playlist = await PlaylistModel.getById(parseInt(playlistId));
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    await PlaylistModel.updateName(parseInt(playlistId), name.trim());

    logger('info', `Playlist actualizada ID: ${playlistId}`);
    sendResponse(res, true, null, 'Playlist actualizada');
  } catch (error) {
    sendError(res, 'Error al actualizar playlist', 500, error as Error);
  }
}

/**
 * Eliminar playlist
 */
export async function deletePlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId } = req.params;

    const playlist = await PlaylistModel.getById(parseInt(playlistId));
    if (!playlist) {
      return sendError(res, 'Playlist no encontrada', 404);
    }

    if (playlist.is_global) {
      return sendError(res, 'No se puede eliminar la playlist global', 400);
    }

    await PlaylistModel.delete(parseInt(playlistId));

    logger('info', `Playlist eliminada ID: ${playlistId}`);
    sendResponse(res, true, null, 'Playlist eliminada');
  } catch (error) {
    sendError(res, 'Error al eliminar playlist', 500, error as Error);
  }
}

/**
 * Agregar canción a playlist
 */
export async function addSongToPlaylist(req: Request, res: Response): Promise<void> {
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
    sendError(res, 'Error al agregar canción a playlist', 500, error as Error);
  }
}

/**
 * Remover canción de playlist
 */
export async function removeSongFromPlaylist(req: Request, res: Response): Promise<void> {
  try {
    const { playlistId, songId } = req.body;

    if (!playlistId || !songId) {
      return sendError(res, 'playlistId y songId son requeridos', 400);
    }

    await PlaylistModel.removeSong(playlistId, songId);

    logger('info', `Canción ${songId} removida de playlist ${playlistId}`);
    sendResponse(res, true, null, 'Canción removida de playlist');
  } catch (error) {
    sendError(res, 'Error al remover canción de playlist', 500, error as Error);
  }
}

/**
 * Obtener playlist global
 */
export async function getGlobalPlaylist(_req: Request, res: Response): Promise<void> {
  try {
    let playlist = await PlaylistModel.getGlobal();

    // Si no existe, crearla
    if (!playlist) {
      playlist = await PlaylistModel.create('Global', true);
      logger('info', 'Playlist global creada automáticamente');
    }

    // Obtener canciones
    const songs = await SongModel.getByPlaylist(playlist.id);

    sendResponse(
      res,
      true,
      {
        ...playlist,
        songs: songs
      },
      'Playlist global obtenida'
    );
  } catch (error) {
    sendError(res, 'Error al obtener playlist global', 500, error as Error);
  }
}
