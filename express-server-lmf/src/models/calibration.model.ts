import { psql } from "../main";

// ─── Tipos internos para inserción ──────────────────────────────────────────

export interface TrainingEntry {
  songId: number;
  isFineTuning: boolean;
  modelId: number;
  userScore: number;
  epochs: number;
  loss: number;
  batchSize: number;
  validationSplit: number;
  mae: number;
}

export interface PredictionEntry {
  songId: number;
  modelId: number;
  prediction: number;
  userScore: number | null;
  accuracy: number | null;
  lastFitId: number | null;
}

// ─── Modelo para tabla entrenamientos ────────────────────────────────────────

export class TrainingRecordModel {

  /**
   * Crear un registro de entrenamiento y retornar su ID
   */
  static async create(data: TrainingEntry): Promise<number> {
    try {
      const [row] = await psql<{ id: number }[]>`
        INSERT INTO public.entrenamientos (
          en_id_cancion, en_is_fine_tuning, en_id_modelo,
          en_calif_usuario, en_ts_epocas, en_ts_loss,
          en_ts_batch_size, en_ts_validation_split, en_ts_mae
        ) VALUES (
          ${data.songId},
          ${data.isFineTuning ? '1' : '0'}::bit(1),
          ${data.modelId},
          ${data.userScore},
          ${data.epochs},
          ${data.loss},
          ${String(data.batchSize)},
          ${data.validationSplit},
          ${data.mae}
        )
        RETURNING en_id as id
      `;
      return row.id;
    } catch (error) {
      console.error('Error al crear registro de entrenamiento:', error);
      throw error;
    }
  }

  /**
   * Crear múltiples registros de entrenamiento en batch
   */
  static async createBatch(entries: TrainingEntry[]): Promise<void> {
    if (entries.length === 0) return;
    try {
      for (const data of entries) {
        await psql`
          INSERT INTO public.entrenamientos (
            en_id_cancion, en_is_fine_tuning, en_id_modelo,
            en_calif_usuario, en_ts_epocas, en_ts_loss,
            en_ts_batch_size, en_ts_validation_split, en_ts_mae
          ) VALUES (
            ${data.songId},
            ${data.isFineTuning ? '1' : '0'}::bit(1),
            ${data.modelId},
            ${data.userScore},
            ${data.epochs},
            ${data.loss},
            ${String(data.batchSize)},
            ${data.validationSplit},
            ${data.mae}
          )
        `;
      }
    } catch (error) {
      console.error('Error al crear registros de entrenamiento en batch:', error);
      throw error;
    }
  }

  /**
   * Obtener el ID del último entrenamiento para cada canción
   */
  static async getLastFitIdForSongs(songIds: number[]): Promise<Map<number, number>> {
    if (songIds.length === 0) return new Map();
    try {
      const rows = await psql<{ songId: number; fitId: number }[]>`
        SELECT DISTINCT ON (en_id_cancion)
          en_id_cancion as "songId",
          en_id as "fitId"
        FROM public.entrenamientos
        WHERE en_id_cancion = ANY(${songIds})
        ORDER BY en_id_cancion, en_fecha DESC
      `;
      const map = new Map<number, number>();
      for (const row of rows) {
        map.set(row.songId, row.fitId);
      }
      return map;
    } catch (error) {
      console.error('Error al obtener último entrenamiento:', error);
      throw error;
    }
  }

  /**
   * Verificar qué canciones ya tienen predicciones (para determinar isFineTuning)
   */
  static async songsWithPredictions(songIds: number[]): Promise<Set<number>> {
    if (songIds.length === 0) return new Set();
    try {
      const rows = await psql<{ songId: number }[]>`
        SELECT DISTINCT pd_id_cancion as "songId"
        FROM public.predicciones
        WHERE pd_id_cancion = ANY(${songIds})
      `;
      return new Set(rows.map(r => r.songId));
    } catch (error) {
      console.error('Error al verificar canciones con predicciones:', error);
      throw error;
    }
  }
}

// ─── Modelo para tabla predicciones ──────────────────────────────────────────

export class PredictionRecordModel {

  /**
   * Crear un registro de predicción y retornar su ID
   */
  static async create(data: PredictionEntry): Promise<number> {
    try {
      const [row] = await psql<{ id: number }[]>`
        INSERT INTO public.predicciones (
          pd_id_cancion, pd_id_modelo, pd_ts_prediccion,
          pd_user_score, pd_accuracy, pd_id_last_fit
        ) VALUES (
          ${data.songId},
          ${data.modelId},
          ${data.prediction},
          ${data.userScore},
          ${data.accuracy},
          ${data.lastFitId}
        )
        RETURNING pd_id as id
      `;
      return row.id;
    } catch (error) {
      console.error('Error al crear registro de predicción:', error);
      throw error;
    }
  }

  /**
   * Crear múltiples registros de predicción en batch
   */
  static async createBatch(entries: PredictionEntry[]): Promise<void> {
    if (entries.length === 0) return;
    try {
      const rows = entries.map(e => ({
        pd_id_cancion: e.songId,
        pd_id_modelo: e.modelId,
        pd_ts_prediccion: e.prediction,
        pd_user_score: e.userScore,
        pd_accuracy: e.accuracy,
        pd_id_last_fit: e.lastFitId
      }));

      await psql`
        INSERT INTO public.predicciones ${psql(rows,
        'pd_id_cancion', 'pd_id_modelo', 'pd_ts_prediccion',
        'pd_user_score', 'pd_accuracy', 'pd_id_last_fit'
      )}
      `;
    } catch (error) {
      console.error('Error al crear registros de predicción en batch:', error);
      throw error;
    }
  }
}
