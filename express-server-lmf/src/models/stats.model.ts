import { psql } from "../main";
import { Calibration } from "../types/generals.models";

class StatsModel {
  static async getAllSongsCalibrationByIdPlaylist(idPlaylist: number): Promise<Array<Calibration>> {
    try {
      const calibrations = await psql<Calibration[]>`
        SELECT
          c.cl_id AS id,
          c.cl_id_cancion AS "songId",
          c.cl_id_modelo AS "modelId",
          c.cl_tipo_interaccion AS "interactionType",
          c.cl_fecha_interaccion AS "interactionDate",
          c.cl_ts_calif_global AS "tsPrediction",
          c.cl_user_score AS "userScore",
          c.cl_ts_config_epocas AS "configEpochs",
          c.cl_loss AS loss,
          c.cl_accuracy AS accuracy,
          c.cl_learning_rate AS "learningRate",
          c.cl_batch_size AS "batchSize"
        FROM public.calibracion c
        INNER JOIN public.rel_playlists_canciones rpc
          ON c.cl_id_cancion = rpc.pr_ca_id
        WHERE rpc.pr_pl_id = ${idPlaylist}
      `;
      return calibrations || [];
    } catch (error) {
      console.error('Error al obtener lista de calibración', error);
      throw error;
    }
  }
}

export default StatsModel;