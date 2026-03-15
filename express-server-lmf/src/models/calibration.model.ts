import { psql } from "../main";
import { Calibration } from "../types/generals.models";

export default class CalibrationModel {

  /**
   * Crear un registro de calibración (interacción canción-modelo)
   */
  static async create(data: Omit<Calibration, 'id'>): Promise<void> {
    try {
      await psql`
        INSERT INTO public.calibracion (
          cl_id_cancion,
          cl_id_modelo,
          cl_tipo_interaccion,
          cl_fecha_interaccion,
          cl_ts_prediccion,
          cl_user_score,
          cl_ts_config_epocas,
          cl_loss,
          cl_accuracy,
          cl_learning_rate,
          cl_batch_size
        ) VALUES (
          ${data.songId},
          ${data.modelId},
          ${data.interactionType},
          ${data.interactionDate},
          ${data.tsPrediction ?? null},
          ${data.userScore},
          ${data.configEpochs},
          ${data.loss ?? null},
          ${data.accuracy ?? null},
          ${data.learningRate ?? null},
          ${data.batchSize ?? null}
        )
      `;
    } catch (error) {
      console.error('Error al crear registro de calibración:', error);
      throw error;
    }
  }

  /**
   * Crear múltiples registros de calibración en batch
   */
  static async createBatch(entries: Omit<Calibration, 'id'>[]): Promise<void> {
    if (entries.length === 0) return;
    try {
      const rows = entries.map(e => ({
        cl_id_cancion: e.songId,
        cl_id_modelo: e.modelId,
        cl_tipo_interaccion: e.interactionType,
        cl_fecha_interaccion: e.interactionDate,
        cl_ts_prediccion: e.tsPrediction ?? null,
        cl_user_score: e.userScore,
        cl_ts_config_epocas: e.configEpochs,
        cl_loss: e.loss ?? null,
        cl_accuracy: e.accuracy ?? null,
        cl_learning_rate: e.learningRate ?? null,
        cl_batch_size: e.batchSize ?? null
      }));

      await psql`
        INSERT INTO public.calibracion ${psql(rows,
        'cl_id_cancion', 'cl_id_modelo', 'cl_tipo_interaccion',
        'cl_fecha_interaccion', 'cl_ts_prediccion', 'cl_user_score',
        'cl_ts_config_epocas', 'cl_loss', 'cl_accuracy',
        'cl_learning_rate', 'cl_batch_size'
      )}
      `;
    } catch (error) {
      console.error('Error al crear registros de calibración en batch:', error);
      throw error;
    }
  }
}
