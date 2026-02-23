import { Request, Response } from "express";
import PlaylistModel from "../models/playlist.model";
import { InternalServerError, sendError, sendResponse } from "../services/http-response-handler.service";

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

  } catch (error) {
    sendError(res, 'Error al obtener el contenido de la playlist', InternalServerError, error instanceof Error ? error : null);
  }
}
