import { Request, Response } from "express";
import PlaylistModel from "../models/playlist.model";
import { BadRequest, InternalServerError, sendError, sendResponse } from "../services/http-response-handler.service";
import SongModel from "../models/song.model";

export async function getAllPlaylists(_req: Request, res: Response): Promise<void> {
  try {
    const playlists = await PlaylistModel.getAll();
    sendResponse(res, true, playlists, 'Playlists obtenidas correctamente');
  } catch (error) {
    sendError(res, 'Error al obtener las playlists', InternalServerError, error instanceof Error ? error : null);
  }
}

export async function getPlaylistContentById(req: Request, res: Response): Promise<void> {
  try {
    const playlistId = parseInt(req.params.idPlaylist, 10);
    if (isNaN(playlistId))
      sendError(res, 'ID de playlist inválido', BadRequest, null);
    else {
      const songs = await SongModel.getAllSongsByPlaylistId(playlistId);
      sendResponse(res, true, songs, 'Contenido de la playlist obtenido correctamente');
    }
  } catch (error) {
    sendError(res, 'Error al obtener el contenido de la playlist', InternalServerError, error instanceof Error ? error : null);
  }
}
