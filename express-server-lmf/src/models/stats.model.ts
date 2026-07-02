import { psql } from "../main";
import { Calibration } from "../types/generals.models";

class StatsModel {
  static async getAllSongsCalibrationByIdPlaylist(idPlaylist: number): Promise<Array<Calibration>> {
    try {
      // Consultar entrenamientos
      const trainRows = await psql<any[]>`
        SELECT
          e.en_id AS id,
          e.en_id_cancion AS "songId",
          e.en_id_modelo AS "modelId",
          e.en_fecha AS "interactionDate",
          e.en_calif_usuario AS "userScore",
          e.en_is_fine_tuning = B'1' AS "isFineTuning",
          e.en_ts_epocas AS epochs,
          e.en_ts_loss AS loss,
          e.en_ts_batch_size AS "batchSize",
          e.en_ts_validation_split AS "validationSplit",
          e.en_ts_mae AS mae
        FROM public.ts_interacciones e
        INNER JOIN public.rel_playlists_canciones rpc
          ON e.en_id_cancion = rpc.pr_ca_id
        WHERE rpc.pr_pl_id = ${idPlaylist}
      `;

      // Consultar predicciones
      const predRows = await psql<any[]>`
        SELECT
          p.pd_id AS id,
          p.pd_id_cancion AS "songId",
          p.pd_id_modelo AS "modelId",
          p.pd_fecha AS "interactionDate",
          p.pd_user_score AS "userScore",
          p.pd_ts_prediccion AS prediction,
          p.pd_accuracy AS accuracy,
          p.pd_id_last_fit AS "lastFitId"
        FROM public.predicciones p
        INNER JOIN public.rel_playlists_canciones rpc
          ON p.pd_id_cancion = rpc.pr_ca_id
        WHERE rpc.pr_pl_id = ${idPlaylist}
      `;

      // Mapear a Calibration con sub-objetos
      const calibrations: Calibration[] = [];

      for (const row of trainRows) {
        calibrations.push({
          id: row.id,
          songId: row.songId,
          modelId: row.modelId,
          interactionDate: row.interactionDate,
          userScore: row.userScore,
          training: {
            isFineTuning: row.isFineTuning,
            epochs: row.epochs,
            loss: parseFloat(row.loss) || 0,
            batchSize: parseInt(row.batchSize) || 0,
            validationSplit: parseFloat(row.validationSplit) || 0,
            mae: parseFloat(row.mae) || 0
          }
        });
      }

      for (const row of predRows) {
        calibrations.push({
          id: row.id,
          songId: row.songId,
          modelId: row.modelId,
          interactionDate: row.interactionDate,
          userScore: row.userScore,
          prediction: {
            prediction: parseFloat(row.prediction) || 0,
            accuracy: row.accuracy != null ? parseFloat(row.accuracy) : 0,
            idLastFit: row.lastFitId
          }
        });
      }

      return calibrations;
    } catch (error) {
      console.error('Error al obtener lista de calibración', error);
      throw error;
    }
  }
}

export default StatsModel;