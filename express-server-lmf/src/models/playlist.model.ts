import { psql } from "../main";
import { Playlist } from "../types/generals.models";

export default class PlaylistModel {
  static async getGlobalPlaylist(): Promise<Playlist | null> {
    try {
      const [playlist] = await psql<Playlist[]>`
      SELECT * FROM public.playlists 
      WHERE pl_is_global = B'1' 
      AND pl_activo = B'1'
      LIMIT 1
      `;
      return playlist || null;
    } catch (error) {
      console.error('Error al obtener playlist global:', error);
      throw error;
    }
  }

  static async newPlaylist(playlist: Playlist): Promise<{ id: number }> {
    try {
      const [result] = await psql<{ pl_id: number }[]>`
        INSERT INTO public.playlists (
          pl_nombre,
          pl_is_global
        ) VALUES (
          ${playlist.name},
          ${playlist.isGlobal}
        )
        RETURNING pl_id
      `;
      if (!result) {
        throw new Error('No se pudo crear la playlist');
      }
      return { id: result.pl_id };
    } catch (error) {
      console.error('Error al crear nueva playlist:', error);
      throw error;
    }
  }

  static async addSongToPlaylist(playlistId: number, songId: number): Promise<{ success: boolean }> {
    try {
      // Verificar si la relación ya existe
      const [existing] = await psql<{ pc_id: number }[]>`
        SELECT pc_id FROM public.rel_playlists_canciones
        WHERE pr_pl_id = ${playlistId} AND pr_ca_id = ${songId}
      `;

      if (existing) {
        return { success: true }; // Ya existe la relación
      }

      await psql`
        INSERT INTO public.rel_playlists_canciones (pr_pl_id, pr_ca_id)
        VALUES (${playlistId}, ${songId})
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al agregar canción a playlist:', error);
      throw error;
    }
  }

  static async removeSongFromPlaylist(playlistId: number, songId: number): Promise<{ success: boolean }> {
    try {
      await psql`
        DELETE FROM public.rel_playlists_canciones
        WHERE pr_pl_id = ${playlistId} AND pr_ca_id = ${songId}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al eliminar canción de playlist:', error);
      throw error;
    }
  }

  static async getPlaylistSongs(playlistId: number): Promise<number[]> {
    try {
      const songs = await psql<{ pr_ca_id: number }[]>`
        SELECT pr_ca_id FROM public.rel_playlists_canciones
        WHERE pr_pl_id = ${playlistId}
      `;
      return songs.map(s => s.pr_ca_id);
    } catch (error) {
      console.error('Error al obtener canciones de playlist:', error);
      throw error;
    }
  }

  static async getAll(): Promise<Playlist[]> {
    try {
      const playlists = await psql<any[]>`
        SELECT 
          pl_id as id,
          pl_nombre as name,
          pl_id_fecha_creacion as "dateCreated",
          pl_is_global = B'1' as "isGlobal"
        FROM public.playlists
        WHERE pl_activo = B'1'
        ORDER BY pl_id_fecha_creacion DESC
      `;
      return playlists;
    } catch (error) {
      console.error('Error al obtener todas las playlists:', error);
      throw error;
    }
  }

  static async getById(playlistId: number): Promise<Playlist | null> {
    try {
      const [playlist] = await psql<any[]>`
        SELECT 
          pl_id as id,
          pl_nombre as name,
          pl_id_fecha_creacion as "dateCreated",
          pl_is_global = B'1' as "isGlobal"
        FROM public.playlists
        WHERE pl_id = ${playlistId} AND pl_activo = B'1'
      `;
      return playlist || null;
    } catch (error) {
      console.error('Error al obtener playlist por ID:', error);
      throw error;
    }
  }
}