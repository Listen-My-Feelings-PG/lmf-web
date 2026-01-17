const { psql } = require('../main');

/**
 * Modelo para manejar canciones en la base de datos
 */
class SongModel {
  /**
   * Obtener todas las canciones
   */
  static async getAll() {
    try {
      const songs = await psql`
        SELECT 
          ca_id as id,
          ca_nombre as name,
          ca_calif_usuario as user_rating,
          ca_file_size as file_size,
          ca_file_name as file_name,
          ca_train_level_global as train_level,
          ca_id_tipodato as data_type_id,
          ca_activo as active,
          ca_ts_features as features_file,
          ca_ts_prediccion as prediction,
          ca_ts_init_status as init_status,
          ca_ts_status as status,
          "idDataTypeId" as id_data_type
        FROM public.canciones
        WHERE ca_activo = true
        ORDER BY ca_id DESC
      `;
      return songs;
    } catch (error) {
      console.error('Error al obtener canciones:', error);
      throw error;
    }
  }

  /**
   * Obtener una canción por ID
   */
  static async getById(id) {
    try {
      const [song] = await psql`
        SELECT 
          ca_id as id,
          ca_nombre as name,
          ca_calif_usuario as user_rating,
          ca_file_size as file_size,
          ca_file_name as file_name,
          ca_train_level_global as train_level,
          ca_id_tipodato as data_type_id,
          ca_activo as active,
          ca_ts_features as features_file,
          ca_ts_prediccion as prediction,
          ca_ts_init_status as init_status,
          ca_ts_status as status
        FROM public.canciones
        WHERE ca_id = ${id} AND ca_activo = true
      `;
      return song;
    } catch (error) {
      console.error('Error al obtener canción:', error);
      throw error;
    }
  }

  /**
   * Crear una nueva canción
   */
  static async create(songData) {
    try {
      const [song] = await psql`
        INSERT INTO public.canciones (
          ca_nombre,
          ca_file_size,
          ca_file_name,
          ca_train_level_global,
          ca_id_tipodato,
          ca_activo,
          ca_ts_init_status,
          ca_calif_usuario
        ) VALUES (
          ${songData.name},
          ${songData.fileSize},
          ${songData.fileName},
          ${songData.trainLevel || 0},
          ${songData.dataTypeId || 1},
          true,
          ${songData.initStatus || 'train'},
          ${songData.userRating || null}
        )
        RETURNING ca_id as id
      `;
      return song;
    } catch (error) {
      console.error('Error al crear canción:', error);
      throw error;
    }
  }

  /**
   * Actualizar calificación de usuario
   */
  static async updateRating(id, rating) {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_calif_usuario = ${rating}
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar calificación:', error);
      throw error;
    }
  }

  /**
   * Actualizar estado de características
   */
  static async updateFeaturesStatus(id, featuresFile, status) {
    try {
      await psql`
        UPDATE public.canciones
        SET 
          ca_ts_features = ${featuresFile},
          ca_ts_status = ${status}
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar estado de características:', error);
      throw error;
    }
  }

  /**
   * Actualizar predicción
   */
  static async updatePrediction(id, prediction) {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_ts_prediccion = ${prediction}
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar predicción:', error);
      throw error;
    }
  }

  /**
   * Obtener canciones por estado
   */
  static async getByStatus(status) {
    try {
      const songs = await psql`
        SELECT 
          ca_id as id,
          ca_nombre as name,
          ca_file_name as file_name,
          ca_ts_features as features_file,
          ca_calif_usuario as user_rating
        FROM public.canciones
        WHERE ca_ts_init_status = ${status} 
        AND ca_activo = true
        ORDER BY ca_id ASC
      `;
      return songs;
    } catch (error) {
      console.error('Error al obtener canciones por estado:', error);
      throw error;
    }
  }

  /**
   * Eliminar canción (soft delete)
   */
  static async delete(id) {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_activo = false
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al eliminar canción:', error);
      throw error;
    }
  }

  /**
   * Obtener canciones de una playlist
   */
  static async getByPlaylist(playlistId) {
    try {
      const songs = await psql`
        SELECT 
          c.ca_id as id,
          c.ca_nombre as name,
          c.ca_calif_usuario as user_rating,
          c.ca_file_size as file_size,
          c.ca_file_name as file_name,
          c.ca_ts_features as features_file,
          c.ca_ts_prediccion as prediction,
          c.ca_ts_init_status as init_status,
          c.ca_ts_status as status
        FROM public.canciones c
        INNER JOIN public.canciones_playlists cp ON c.ca_id = cp.cp_ca_id
        WHERE cp.cp_pl_id = ${playlistId} AND c.ca_activo = true
        ORDER BY c.ca_id DESC
      `;
      return songs;
    } catch (error) {
      console.error('Error al obtener canciones de playlist:', error);
      throw error;
    }
  }
}

module.exports = SongModel;
