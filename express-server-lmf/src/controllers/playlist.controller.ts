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
      sendResponse(res, true, songs.map((obj) => ({
        id: obj.ca_id,
        userScore: obj.ca_calif_usuario ?? null,
        fileName: obj.ca_filename,
        fileSize: obj.ca_filesize,
        dataType: obj.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: obj.ca_metadata ? JSON.parse(obj.ca_metadata) : undefined,
        tsGlobalScore: obj.ca_ts_calif_global ?? null,
        tsTrainLevelLocal: obj.ca_train_level_local ?? 0,
        tsTrainLevelGlobal: obj.ca_train_level_global ?? 0,
        tsProbScore0: obj.ca_ts_prob_calif_0 ?? null,
        tsProbScore1: obj.ca_ts_prob_calif_1 ?? null,
        tsProbScore2: obj.ca_ts_prob_calif_2 ?? null,
        tsProbScore3: obj.ca_ts_prob_calif_3 ?? null
      })), 'Contenido de la playlist obtenido correctamente');
    }
  } catch (error) {
    sendError(res, 'Error al obtener el contenido de la playlist', InternalServerError, error instanceof Error ? error : null);
  }
}
