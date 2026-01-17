const { psql } = require('../main');

/**
 * Modelo para manejar modelos de TensorFlow en la base de datos
 */
class ModelModel {
  /**
   * Obtener todos los modelos
   */
  static async getAll() {
    try {
      const models = await psql`
        SELECT 
          mo_id as id,
          mo_nombre as name,
          mo_fecha_creacion as created_at,
          mo_fecha_modificacion as updated_at,
          mo_pl_id as playlist_id,
          mo_ruta as path,
          mo_activo as active
        FROM public.modelos
        WHERE mo_activo = true
        ORDER BY mo_fecha_creacion DESC
      `;
      return models;
    } catch (error) {
      console.error('Error al obtener modelos:', error);
      throw error;
    }
  }

  /**
   * Obtener modelo por ID
   */
  static async getById(id) {
    try {
      const [model] = await psql`
        SELECT 
          mo_id as id,
          mo_nombre as name,
          mo_fecha_creacion as created_at,
          mo_fecha_modificacion as updated_at,
          mo_pl_id as playlist_id,
          mo_ruta as path,
          mo_activo as active
        FROM public.modelos
        WHERE mo_id = ${id} AND mo_activo = true
      `;
      return model;
    } catch (error) {
      console.error('Error al obtener modelo:', error);
      throw error;
    }
  }

  /**
   * Obtener modelo por playlist
   */
  static async getByPlaylist(playlistId) {
    try {
      const [model] = await psql`
        SELECT 
          mo_id as id,
          mo_nombre as name,
          mo_fecha_creacion as created_at,
          mo_fecha_modificacion as updated_at,
          mo_pl_id as playlist_id,
          mo_ruta as path,
          mo_activo as active
        FROM public.modelos
        WHERE mo_pl_id = ${playlistId} AND mo_activo = true
        ORDER BY mo_fecha_creacion DESC
        LIMIT 1
      `;
      return model;
    } catch (error) {
      console.error('Error al obtener modelo por playlist:', error);
      throw error;
    }
  }

  /**
   * Crear nuevo modelo
   */
  static async create(modelData) {
    try {
      const [model] = await psql`
        INSERT INTO public.modelos (
          mo_nombre,
          mo_fecha_creacion,
          mo_fecha_modificacion,
          mo_pl_id,
          mo_ruta,
          mo_activo
        ) VALUES (
          ${modelData.name},
          NOW(),
          NOW(),
          ${modelData.playlistId},
          ${modelData.path},
          true
        )
        RETURNING mo_id as id, mo_nombre as name, mo_ruta as path
      `;
      return model;
    } catch (error) {
      console.error('Error al crear modelo:', error);
      throw error;
    }
  }

  /**
   * Actualizar ruta del modelo
   */
  static async updatePath(id, path) {
    try {
      await psql`
        UPDATE public.modelos
        SET 
          mo_ruta = ${path},
          mo_fecha_modificacion = NOW()
        WHERE mo_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar modelo:', error);
      throw error;
    }
  }

  /**
   * Desactivar modelo
   */
  static async deactivate(id) {
    try {
      await psql`
        UPDATE public.modelos
        SET mo_activo = false
        WHERE mo_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al desactivar modelo:', error);
      throw error;
    }
  }

  /**
   * Obtener modelo global (más reciente)
   */
  static async getGlobal() {
    try {
      const [playlist] = await psql`
        SELECT pl_id as id FROM public.playlists
        WHERE pl_global = true
        LIMIT 1
      `;

      if (!playlist) return null;

      return await this.getByPlaylist(playlist.id);
    } catch (error) {
      console.error('Error al obtener modelo global:', error);
      throw error;
    }
  }
}

module.exports = ModelModel;
