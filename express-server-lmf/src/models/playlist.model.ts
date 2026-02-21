import { psql } from '../main';

/**
 * Modelo para manejar playlists en la base de datos
 */
class PlaylistModel {
  /**
   * Obtener todas las playlists
   */
  static async getAll(includeGlobal = true): Promise<any[]> {
    try {
      const playlists = await psql<any[]>`
        SELECT 
          pl_id as id,
          pl_nombre as name,
          pl_fecha_creacion as created_at,
          pl_fecha_modificacion as updated_at,
          pl_us_id as user_id,
          pl_global as is_global
        FROM public.playlists
        WHERE ${includeGlobal ? psql`1=1` : psql`pl_global = false`}
        ORDER BY pl_global DESC, pl_fecha_creacion DESC
      `;
      return playlists;
    } catch (error) {
      console.error('Error al obtener playlists:', error);
      throw error;
    }
  }

  /**
   * Obtener playlist por ID
   */
  static async getById(id: number): Promise<any | undefined> {
    try {
      const [playlist] = await psql<any[]>`
        SELECT 
          pl_id as id,
          pl_nombre as name,
          pl_fecha_creacion as created_at,
          pl_fecha_modificacion as updated_at,
          pl_us_id as user_id,
          pl_global as is_global
        FROM public.playlists
        WHERE pl_id = ${id}
      `;
      return playlist;
    } catch (error) {
      console.error('Error al obtener playlist:', error);
      throw error;
    }
  }

  /**
   * Crear nueva playlist
   */
  static async create(name: string, isGlobal = false): Promise<any> {
    try {
      const [playlist] = await psql<any[]>`
        INSERT INTO public.playlists (
          pl_nombre,
          pl_fecha_creacion,
          pl_fecha_modificacion,
          pl_global
        ) VALUES (
          ${name},
          NOW(),
          NOW(),
          ${isGlobal}
        )
        RETURNING pl_id as id, pl_nombre as name, pl_global as is_global
      `;
      return playlist;
    } catch (error) {
      console.error('Error al crear playlist:', error);
      throw error;
    }
  }

  /**
   * Actualizar nombre de playlist
   */
  static async updateName(id: number, name: string): Promise<{ success: boolean }> {
    try {
      await psql`
        UPDATE public.playlists
        SET 
          pl_nombre = ${name},
          pl_fecha_modificacion = NOW()
        WHERE pl_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar playlist:', error);
      throw error;
    }
  }

  /**
   * Eliminar playlist
   */
  static async delete(id: number): Promise<{ success: boolean }> {
    try {
      // Primero eliminar las relaciones con canciones
      await psql`
        DELETE FROM public.canciones_playlists
        WHERE cp_pl_id = ${id}
      `;

      // Luego eliminar la playlist
      await psql`
        DELETE FROM public.playlists
        WHERE pl_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al eliminar playlist:', error);
      throw error;
    }
  }

  /**
   * Agregar canción a playlist
   */
  static async addSong(
    playlistId: number,
    songId: number
  ): Promise<{ success: boolean; message?: string }> {
    try {
      // Verificar si ya existe la relación
      const [exists] = await psql<{ cp_id: number }[]>`
        SELECT cp_id FROM public.canciones_playlists
        WHERE cp_pl_id = ${playlistId} AND cp_ca_id = ${songId}
      `;

      if (exists) {
        return { success: true, message: 'La canción ya está en la playlist' };
      }

      await psql`
        INSERT INTO public.canciones_playlists (cp_pl_id, cp_ca_id)
        VALUES (${playlistId}, ${songId})
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al agregar canción a playlist:', error);
      throw error;
    }
  }

  /**
   * Remover canción de playlist
   */
  static async removeSong(
    playlistId: number,
    songId: number
  ): Promise<{ success: boolean }> {
    try {
      await psql`
        DELETE FROM public.canciones_playlists
        WHERE cp_pl_id = ${playlistId} AND cp_ca_id = ${songId}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al remover canción de playlist:', error);
      throw error;
    }
  }

  /**
   * Obtener playlist global
   */
  static async getGlobal(): Promise<any | undefined> {
    try {
      const [playlist] = await psql<any[]>`
        SELECT 
          pl_id as id,
          pl_nombre as name,
          pl_fecha_creacion as created_at,
          pl_fecha_modificacion as updated_at,
          pl_global as is_global
        FROM public.playlists
        WHERE pl_global = true
        LIMIT 1
      `;
      return playlist;
    } catch (error) {
      console.error('Error al obtener playlist global:', error);
      throw error;
    }
  }
}

export default PlaylistModel;
