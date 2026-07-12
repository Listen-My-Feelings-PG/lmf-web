import { Request, Response } from "express";
import { BadRequest, InternalServerError, sendError, sendResponse } from "../services/http-response-handler.service";
import StatsModel from "../models/stats.model";

/**
 * Controlador: Obtiene las estadísticas de calibración (calificaciones) de las canciones
 * dentro de una Playlist específica. Se usa para mostrar qué porcentaje de canciones
 * han sido puntuadas por el usuario vs las que aún faltan (útil para el frontend).
 */
export async function getAllSongsCalibrationsByIdPlaylist(req: Request, res: Response): Promise<void> {
  try {
    const idPlaylist = parseInt(req.params.idPlaylist, 10);
    if (isNaN(idPlaylist)) {
      sendError(res, 'ID de playlist no válido', BadRequest);
      return;
    }
    const calibrations = await StatsModel.getAllSongsCalibrationByIdPlaylist(idPlaylist);
    sendResponse(res, true, calibrations, 'Lista de calibración obtenida correctamente');
  } catch (error) {
    console.error('Error al obtener lista de calibración', error);
    sendError(res, 'Error al obtener lista de calibración', InternalServerError,);
  }
}
