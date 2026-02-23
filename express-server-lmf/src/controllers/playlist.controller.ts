import { Request, Response } from "express";
import PlaylistModel from "../models/playlist.model";
import { sendError, sendResponse } from "../services/file.service";

export async function getAllPlaylists(_req: Request, res: Response): Promise<void> {
  try {
    const playlists = await PlaylistModel.getAll();
    sendResponse(res, true, playlists, 'Playlists obtenidas correctamente');
  } catch (error) {
    sendError(res, 'Error al obtener las playlists', 500, error instanceof Error ? error : null);
  }
}

export async function getPlaylistContentById(req: Request, res: Response): Promise<void> {
  try {

  } catch (error) {
    sendError(res, 'Error al obtener el contenido de la playlist', 500, error instanceof Error ? error : null);
  }
}
