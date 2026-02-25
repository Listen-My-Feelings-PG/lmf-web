import { psql } from "../main";
import { Song } from "../types/generals.models";

/**
 * Modelo para manejar canciones en la base de datos
 */
class SongModel {
  /**
   * Crear una nueva canciÃ³n
   */
  static async newSong(songData: Song): Promise<{ id: number }> {
    try {
      const [song] = await psql<{ id: number }[]>`
        INSERT INTO public.canciones (
          ca_filename,
          ca_filesize,
          ca_metadata,
          ca_id_tipodato
        ) VALUES (
          ${songData.fileName},
          ${songData.fileSize},
          ${songData.metadata ? JSON.stringify(songData.metadata) : null},
          ${songData.dataType === 'file' ? 1 : 2}
        )
        RETURNING ca_id as id
      `;
      return song;
    } catch (error) {
      console.error('Error al crear canción:', error);
      throw error;
    }
  }

  static async updateById(id: number, songData: Partial<Song>): Promise<{ success: boolean }> {
    try {
      const updates: string[] = [];
      if (songData.fileName !== undefined)
        updates.push('ca_filename = ' + psql([songData.fileName]));
      if (songData.userScore !== undefined)
        updates.push('ca_calif_usuario = ' + psql([songData.userScore]));
      if (songData.metadata !== undefined)
        updates.push('ca_metadata = ' + psql([songData.metadata ? JSON.stringify(songData.metadata) : null]));
      if (songData.dataType !== undefined)
        updates.push('ca_id_tipodato = ' + psql([songData.dataType === 'file' ? 1 : 2]));
      if (songData.tsGlobalScore !== undefined)
        updates.push('ca_ts_calif_global = ' + psql([songData.tsGlobalScore]));
      if (songData.tsTrainLevelLocal !== undefined)
        updates.push('ca_train_level_local = ' + psql([songData.tsTrainLevelLocal]));
      if (songData.tsTrainLevelGlobal !== undefined)
        updates.push('ca_train_level_global = ' + psql([songData.tsTrainLevelGlobal]));
      if (updates.length === 0)
        return { success: false };
      await psql`
        UPDATE public.canciones
        SET 
          ${songData.fileName !== undefined ? psql`ca_filename = ${songData.fileName}` : psql``}
          ${songData.userScore !== undefined ? psql`, ca_calif_usuario = ${songData.userScore}` : psql``}
          ${songData.metadata !== undefined ? psql`, ca_metadata = ${songData.metadata ? JSON.stringify(songData.metadata) : null}` : psql``}
          ${songData.dataType !== undefined ? psql`, ca_id_tipodato = ${songData.dataType === 'file' ? 1 : 2}` : psql``}
          ${songData.tsGlobalScore !== undefined ? psql`, ca_ts_calif_global = ${songData.tsGlobalScore}` : psql``}
          ${songData.tsTrainLevelLocal !== undefined ? psql`, ca_train_level_local = ${songData.tsTrainLevelLocal}` : psql``}
          ${songData.tsTrainLevelGlobal !== undefined ? psql`, ca_train_level_global = ${songData.tsTrainLevelGlobal}` : psql``}
          ${songData.tsProbScore0 !== undefined ? psql`, ca_ts_prob_calif_0 = ${songData.tsProbScore0}` : psql``}
          ${songData.tsProbScore1 !== undefined ? psql`, ca_ts_prob_calif_1 = ${songData.tsProbScore1}` : psql``}
          ${songData.tsProbScore2 !== undefined ? psql`, ca_ts_prob_calif_2 = ${songData.tsProbScore2}` : psql``}
          ${songData.tsProbScore3 !== undefined ? psql`, ca_ts_prob_calif_3 = ${songData.tsProbScore3}` : psql``}
        WHERE ca_id = ${id}
      `;

      return { success: true };
    } catch (error) {
      console.error('Error al actualizar canción:', error);
      throw error;
    }
  }

  static async physicalDeleteById(id: number): Promise<{ success: boolean }> {
    try {
      await psql`
        DELETE FROM public.canciones
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al eliminar canción:', error);
      throw error;
    }
  }

  /**
   * Borrado lógico de una canción (ca_activo = 0)
   */
  static async logicalDeleteById(id: number): Promise<{ success: boolean }> {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_activo = B'0'
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al desactivar canción:', error);
      throw error;
    }
  }

  /**
   * Reactivar una canción (ca_activo = 1)
   */
  static async reactivateById(id: number): Promise<{ success: boolean }> {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_activo = B'1'
        WHERE ca_id = ${id}
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al reactivar canción:', error);
      throw error;
    }
  }

  /**
   * Obtener todas las canciones inactivas (ca_activo = 0)
   */
  static async getInactive(): Promise<Song[]> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsGlobalScore",
          ca_train_level_local as "tsTrainLevelLocal",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_prob_calif_0 as "tsProbScore0",
          ca_ts_prob_calif_1 as "tsProbScore1",
          ca_ts_prob_calif_2 as "tsProbScore2",
          ca_ts_prob_calif_3 as "tsProbScore3"
        FROM public.canciones
        WHERE ca_activo = B'0'`;
      return songs.map(song => ({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsGlobalScore: song.tsGlobalScore ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsProbScore0: song.tsProbScore0 ?? null,
        tsProbScore1: song.tsProbScore1 ?? null,
        tsProbScore2: song.tsProbScore2 ?? null,
        tsProbScore3: song.tsProbScore3 ?? null
      }));
    } catch (error) {
      console.error('Error al obtener canciones inactivas:', error);
      throw error;
    }
  }

  static async getAll(): Promise<Song[]> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsGlobalScore",
          ca_train_level_local as "tsTrainLevelLocal",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_prob_calif_0 as "tsProbScore0",
          ca_ts_prob_calif_1 as "tsProbScore1",
          ca_ts_prob_calif_2 as "tsProbScore2",
          ca_ts_prob_calif_3 as "tsProbScore3"
        FROM public.canciones
        WHERE ca_activo = B'1'`;
      return songs.map(song => ({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsGlobalScore: song.tsGlobalScore ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsProbScore0: song.tsProbScore0 ?? null,
        tsProbScore1: song.tsProbScore1 ?? null,
        tsProbScore2: song.tsProbScore2 ?? null,
        tsProbScore3: song.tsProbScore3 ?? null
      }));
    } catch (error) {
      console.error('Error al obtener todas las canciones:', error);
      throw error;
    }
  }

  static async getSongById(id: number): Promise<Song | null> {
    try {
      const [song] = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsGlobalScore",
          ca_train_level_local as "tsTrainLevelLocal",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_prob_calif_0 as "tsProbScore0",
          ca_ts_prob_calif_1 as "tsProbScore1",
          ca_ts_prob_calif_2 as "tsProbScore2",
          ca_ts_prob_calif_3 as "tsProbScore3"
        FROM public.canciones
        WHERE ca_id = ${id} AND ca_activo = B'1'`;
      if (!song) return null;
      return {
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsGlobalScore: song.tsGlobalScore ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsProbScore0: song.tsProbScore0 ?? null,
        tsProbScore1: song.tsProbScore1 ?? null,
        tsProbScore2: song.tsProbScore2 ?? null,
        tsProbScore3: song.tsProbScore3 ?? null
      };
    } catch (error) {
      console.error('Error al buscar canción por ID:', error);
      throw error;
    }
  }

  static async getByFileName(fileName: string): Promise<Song | null> {
    try {
      const [song] = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsGlobalScore",
          ca_train_level_local as "tsTrainLevelLocal",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_prob_calif_0 as "tsProbScore0",
          ca_ts_prob_calif_1 as "tsProbScore1",
          ca_ts_prob_calif_2 as "tsProbScore2",
          ca_ts_prob_calif_3 as "tsProbScore3"
        FROM public.canciones
        WHERE ca_filename = ${fileName} AND ca_activo = B'1'`;
      if (!song) return null;
      return {
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsGlobalScore: song.tsGlobalScore ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsProbScore0: song.tsProbScore0 ?? null,
        tsProbScore1: song.tsProbScore1 ?? null,
        tsProbScore2: song.tsProbScore2 ?? null,
        tsProbScore3: song.tsProbScore3 ?? null
      };
    } catch (error) {
      console.error('Error al buscar canción por nombre:', error);
      throw error;
    }
  }

  static async getAllSongsByPlaylistId(idPlaylist: number): Promise<Array<Song>> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id,
          ca_calif_usuario,
          ca_filesize,
          ca_filename,
          ca_train_level_local,
          ca_train_level_global,
          ca_id_tipodato,
          ca_metadata,
          ca_ts_calif_global,
          ca_ts_prob_calif_0,
          ca_ts_prob_calif_1,
          ca_ts_prob_calif_2,
          ca_ts_prob_calif_3
      FROM rel_playlists_canciones
      left join canciones on ca_id=pr_ca_id
      where pr_pl_id=${idPlaylist} AND ca_activo = B'1'`;
      return songs.map(song => ({
        id: song.ca_id,
        userScore: song.ca_calif_usuario ?? null,
        fileName: song.ca_filename,
        fileSize: song.ca_filesize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.ca_metadata && song.ca_metadata.trim().startsWith('{') ? JSON.parse(song.ca_metadata) : undefined,
        tsGlobalScore: song.ca_ts_calif_global ?? null,
        tsTrainLevelLocal: song.ca_train_level_local ?? null,
        tsTrainLevelGlobal: song.ca_train_level_global ?? null,
        tsProbScore0: song.ca_ts_prob_calif_0 ?? null,
        tsProbScore1: song.ca_ts_prob_calif_1 ?? null,
        tsProbScore2: song.ca_ts_prob_calif_2 ?? null,
        tsProbScore3: song.ca_ts_prob_calif_3 ?? null,
        idPlaylist: idPlaylist
      }));
    } catch (error) {
      console.error('Error al obtener canciones por ID de playlist:', error);
      throw error;
    }
  }

  static async setSongUserScoreByIdSong(idSong: number, userScore: number): Promise<{ success: boolean }> {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_calif_usuario = ${userScore}
        WHERE ca_id = ${idSong} AND ca_activo = B'1'
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar la calificación de la canción:', error);
      throw error;
    }
  }

  static async getAllSongsScoredByUser(): Promise<Array<Song>> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id,
          ca_calif_usuario,
          ca_filesize,
          ca_filename,
          ca_train_level_local,
          ca_train_level_global,
          ca_id_tipodato,
          ca_metadata,
          ca_ts_calif_global,
          ca_ts_prob_calif_0,
          ca_ts_prob_calif_1,
          ca_ts_prob_calif_2,
          ca_ts_prob_calif_3,
          pr_pl_id as "idPlaylist"
      FROM rel_playlists_canciones
      left join canciones on ca_id=pr_ca_id
      where ca_calif_usuario is not null AND ca_activo = B'1'`;
      return songs.map(song => ({
        id: song.ca_id,
        userScore: song.ca_calif_usuario ?? null,
        fileName: song.ca_filename,
        fileSize: song.ca_filesize,
        dataType: song.ca_id_tipodato === 1 ? 'file' : 'link',
        metadata: song.ca_metadata && song.ca_metadata.trim().startsWith('{') ? JSON.parse(song.ca_metadata) : undefined,
        tsGlobalScore: song.ca_ts_calif_global ?? null,
        tsTrainLevelLocal: song.ca_train_level_local ?? null,
        tsTrainLevelGlobal: song.ca_train_level_global ?? null,
        tsProbScore0: song.ca_ts_prob_calif_0 ?? null,
        tsProbScore1: song.ca_ts_prob_calif_1 ?? null,
        tsProbScore2: song.ca_ts_prob_calif_2 ?? null,
        tsProbScore3: song.ca_ts_prob_calif_3 ?? null,
        idPlaylist: song.idPlaylist
      }));
    } catch (error) {
      console.error('Error al obtener canciones calificadas por el usuario:', error);
      throw error;
    }
  }
}

export default SongModel;