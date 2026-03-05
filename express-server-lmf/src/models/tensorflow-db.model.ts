import { psql } from "../main";
import { TensorFlowModel } from "../types/generals.models";

/**
 * Mapea un row de la BD al interface TensorFlowModel
 */
function mapRow(row: any): TensorFlowModel {
  return {
    id: row.ts_id,
    active: row.active ?? true,
    trainedSongs: row.ts_canciones_entrenadas,
    completedEpochs: row.ts_epocas_completadas,
    createdDate: row.ts_fechacreacion,
    registeredDate: row.ts_fecharegistro,
    filename: row.ts_filename,
    loss: parseFloat(row.ts_perdida) || 0,
    accuracy: parseFloat(row.ts_precision) || 0,
    version: row.ts_version,
    isGlobal: row.isGlobal ?? false,
    learningRate: parseFloat(row.ts_learning_rate) || 0.001,
    batchSize: row.ts_batch_size ?? 32,
    numClasses: row.ts_num_clases ?? 4,
    inputDim: row.ts_input_dim ?? 128,
    architecture: row.ts_arquitectura || undefined
  };
}

const SELECT_FIELDS = psql`
  ts_id,
  ts_activo = B'1' as "active",
  ts_canciones_entrenadas,
  ts_epocas_completadas,
  ts_fechacreacion,
  ts_fecharegistro,
  ts_filename,
  ts_perdida,
  ts_precision,
  ts_version,
  ts_is_global = B'1' as "isGlobal",
  ts_learning_rate,
  ts_batch_size,
  ts_num_clases,
  ts_input_dim,
  ts_arquitectura
`;

export default class TsModelModel {

  /**
   * Obtener el modelo global activo (el más reciente por versión)
   */
  static async getGlobalModel(): Promise<TensorFlowModel | null> {
    try {
      const [row] = await psql<any[]>`
        SELECT ${SELECT_FIELDS}
        FROM public.ts_modelos
        WHERE ts_is_global = B'1' AND ts_activo = B'1'
        ORDER BY ts_version DESC
        LIMIT 1
      `;
      return row ? mapRow(row) : null;
    } catch (error) {
      console.error('Error al obtener modelo global:', error);
      throw error;
    }
  }

  /**
   * Obtener un modelo por su ID
   */
  static async getById(id: number): Promise<TensorFlowModel | null> {
    try {
      const [row] = await psql<any[]>`
        SELECT ${SELECT_FIELDS}
        FROM public.ts_modelos
        WHERE ts_id = ${id} AND ts_activo = B'1'
      `;
      return row ? mapRow(row) : null;
    } catch (error) {
      console.error('Error al obtener modelo por ID:', error);
      throw error;
    }
  }

  /**
   * Crear un nuevo modelo en la BD
   */
  static async create(data: Omit<TensorFlowModel, 'id' | 'active' | 'createdDate' | 'registeredDate'>): Promise<TensorFlowModel> {
    try {
      const [row] = await psql<any[]>`
        INSERT INTO public.ts_modelos (
          ts_canciones_entrenadas,
          ts_epocas_completadas,
          ts_fechacreacion,
          ts_filename,
          ts_perdida,
          ts_precision,
          ts_version,
          ts_is_global,
          ts_learning_rate,
          ts_batch_size,
          ts_num_clases,
          ts_input_dim,
          ts_arquitectura
        ) VALUES (
          ${data.trainedSongs},
          ${data.completedEpochs},
          NOW(),
          ${data.filename},
          ${data.loss},
          ${data.accuracy},
          ${data.version},
          ${data.isGlobal ? psql`B'1'` : psql`B'0'`},
          ${data.learningRate},
          ${data.batchSize},
          ${data.numClasses},
          ${data.inputDim},
          ${data.architecture || null}
        )
        RETURNING ${SELECT_FIELDS}
      `;
      return mapRow(row);
    } catch (error) {
      console.error('Error al crear modelo:', error);
      throw error;
    }
  }

  /**
   * Actualizar métricas del modelo después del entrenamiento
   */
  static async updateAfterTraining(id: number, data: {
    trainedSongs: number;
    completedEpochs: number;
    loss: number;
    accuracy: number;
    version: number;
  }): Promise<void> {
    try {
      await psql`
        UPDATE public.ts_modelos
        SET
          ts_canciones_entrenadas = ${data.trainedSongs},
          ts_epocas_completadas = ${data.completedEpochs},
          ts_perdida = ${data.loss},
          ts_precision = ${data.accuracy},
          ts_version = ${data.version}
        WHERE ts_id = ${id}
      `;
    } catch (error) {
      console.error('Error al actualizar modelo:', error);
      throw error;
    }
  }
}
