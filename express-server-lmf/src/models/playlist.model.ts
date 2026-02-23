import { psql } from "../main";
import { Playlist } from "../types/generals.models";

class PlaylistModel {
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

  static async new(playlist: Playlist): Promise<{ id: number }> {
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
}

export default PlaylistModel;