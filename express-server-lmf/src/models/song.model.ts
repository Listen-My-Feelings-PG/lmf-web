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
          ${songData.fileSize ?? null},
          ${songData.metadata ? JSON.stringify(songData.metadata) : null},
          1
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
      if (songData.tsPrediction !== undefined)
        updates.push('ca_ts_calif_global = ' + psql([songData.tsPrediction]));
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
          ${songData.tsPrediction !== undefined ? psql`, ca_ts_calif_global = ${songData.tsPrediction}` : psql``}
          ${songData.tsTrainLevelGlobal !== undefined ? psql`, ca_train_level_global = ${songData.tsTrainLevelGlobal}` : psql``}
          ${songData.tsFeaturesFileName !== undefined ? psql`, ca_ts_features_filename = ${songData.tsFeaturesFileName}` : psql``}
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
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName"
        FROM public.canciones
        WHERE ca_activo = B'0'`;
      return songs.map(song => new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null
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
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName"
        FROM public.canciones
        WHERE ca_activo = B'1'`;
      return songs.map(song => new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null
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
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName"
        FROM public.canciones
        WHERE ca_id = ${id} AND ca_activo = B'1'`;
      if (!song) return null;
      return new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null
      });
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
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName"
        FROM public.canciones
        WHERE ca_filename = ${fileName} AND ca_activo = B'1'`;
      if (!song) return null;
      return new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelLocal: song.tsTrainLevelLocal ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null
      });
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
          ca_train_level_global,
          ca_id_tipodato,
          ca_metadata,
          ca_ts_calif_global,
          ca_ts_features_filename,
          latest_cal.cl_accuracy as accuracy
      FROM rel_playlists_canciones
      left join canciones on ca_id=pr_ca_id
      LEFT JOIN LATERAL (
        SELECT cl_accuracy
        FROM calibracion
        WHERE cl_id_cancion = ca_id AND cl_tipo_interaccion = 'predict'
        ORDER BY cl_fecha_interaccion DESC
        LIMIT 1
      ) latest_cal ON true
      where pr_pl_id=${idPlaylist} AND ca_activo = B'1'`;
      return songs.map(song => new Song({
        id: song.ca_id,
        userScore: song.ca_calif_usuario ?? null,
        fileName: song.ca_filename,
        fileSize: song.ca_filesize,
        metadata: song.ca_metadata && song.ca_metadata.trim().startsWith('{') ? JSON.parse(song.ca_metadata) : undefined,
        tsPrediction: song.ca_ts_calif_global ?? null,
        tsTrainLevelGlobal: song.ca_train_level_global ?? null,
        tsFeaturesFileName: song.ca_ts_features_filename ?? null,
        idPlaylist: idPlaylist,
        accuracy: (song.ca_calif_usuario != null && song.ca_ts_calif_global != null && song.accuracy != null) ? parseFloat(song.accuracy) : null
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

  static async getAllSongsInDefaultPlaylist(): Promise<Array<Song>> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName",
          pr_pl_id as "idPlaylist",
          latest_cal.cl_accuracy as accuracy
        FROM rel_playlists_canciones
        left join canciones on ca_id=pr_ca_id
        left join playlists on pr_pl_id=pl_id
        LEFT JOIN LATERAL (
          SELECT cl_accuracy
          FROM calibracion
          WHERE cl_id_cancion = ca_id AND cl_tipo_interaccion = 'predict'
          ORDER BY cl_fecha_interaccion DESC
          LIMIT 1
        ) latest_cal ON true
        where pl_is_default = B'1' AND ca_activo = B'1'`;
      return songs.map(song => new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null,
        idPlaylist: song.idPlaylist,
        accuracy: (song.userScore != null && song.tsPrediction != null && song.accuracy != null) ? parseFloat(song.accuracy) : null
      }));
    } catch (error) {
      console.error('Error al obtener canciones sin predicción en playlist por defecto:', error);
      throw error;
    }
  }

  static async getAllSongsScoredByUserInDefaultPlaylist(): Promise<Array<Song>> {
    try {
      const songs = await psql<any[]>`SELECT 
          ca_id,
          ca_calif_usuario,
          ca_filesize,
          ca_filename,
          ca_train_level_global,
          ca_id_tipodato,
          ca_metadata,
          ca_ts_calif_global,
          ca_ts_features_filename,
          pr_pl_id as "idPlaylist"
      FROM rel_playlists_canciones
      left join canciones on ca_id=pr_ca_id
      left join playlists on pr_pl_id=pl_id
      where ca_calif_usuario is not null AND pl_is_default = B'1' AND ca_activo = B'1'`;
      return songs.map(song => new Song({
        id: song.ca_id,
        userScore: song.ca_calif_usuario ?? null,
        fileName: song.ca_filename,
        fileSize: song.ca_filesize,
        metadata: song.ca_metadata && song.ca_metadata.trim().startsWith('{') ? JSON.parse(song.ca_metadata) : undefined,
        tsPrediction: song.ca_ts_calif_global ?? null,
        tsTrainLevelGlobal: song.ca_train_level_global ?? null,
        tsFeaturesFileName: song.ca_ts_features_filename ?? null,
        idPlaylist: song.idPlaylist
      }));
    } catch (error) {
      console.error('Error al obtener canciones calificadas por el usuario:', error);
      throw error;
    }
  }

  /**
   * Obtener múltiples canciones por sus IDs (para extracción de features)
   */
  static async getSongsByIds(ids: number[]): Promise<Array<Song>> {
    try {
      if (ids.length === 0) return [];
      const songs = await psql<any[]>`SELECT 
          ca_id as id,
          ca_calif_usuario as "userScore",
          ca_filename as "fileName",
          ca_filesize as "fileSize",
          ca_id_tipodato,
          ca_metadata as metadata,
          ca_ts_calif_global as "tsPrediction",
          ca_train_level_global as "tsTrainLevelGlobal",
          ca_ts_features_filename as "tsFeaturesFileName"
        FROM public.canciones
        WHERE ca_id = ANY(${ids}) AND ca_activo = B'1'`;
      return songs.map(song => new Song({
        id: song.id,
        userScore: song.userScore ?? null,
        fileName: song.fileName,
        fileSize: song.fileSize,
        metadata: song.metadata && song.metadata.trim().startsWith('{') ? JSON.parse(song.metadata) : undefined,
        tsPrediction: song.tsPrediction ?? null,
        tsTrainLevelGlobal: song.tsTrainLevelGlobal ?? null,
        tsFeaturesFileName: song.tsFeaturesFileName ?? null
      }));
    } catch (error) {
      console.error('Error al obtener canciones por IDs:', error);
      throw error;
    }
  }

  /**
   * Actualizar el nombre de archivo de features de una canción
   */
  static async updateFeaturesFilename(songId: number, tsFeaturesFileName: string): Promise<{ success: boolean }> {
    try {
      await psql`
        UPDATE public.canciones
        SET ca_ts_features_filename = ${tsFeaturesFileName}
        WHERE ca_id = ${songId} AND ca_activo = B'1'
      `;
      return { success: true };
    } catch (error) {
      console.error('Error al actualizar features filename:', error);
      throw error;
    }
  }

  /**
   * Actualizar resultados de entrenamiento de una canción
   */
  static async updateTrainingResults(songId: number, data: {
    trainLevelGlobal?: number;
    trainLevelLocal?: number;
    globalScore?: number;
  }): Promise<void> {
    try {
      await psql`
        UPDATE public.canciones
        SET
          ca_train_level_global = COALESCE(${data.trainLevelGlobal ?? null}, ca_train_level_global),
          ca_ts_calif_global = COALESCE(${data.globalScore ?? null}, ca_ts_calif_global)
        WHERE ca_id = ${songId} AND ca_activo = B'1'
      `;
    } catch (error) {
      console.error('Error al actualizar resultados de entrenamiento:', error);
      throw error;
    }
  }

  /**
   * Obtener las relaciones playlist-canción para un conjunto de IDs de canciones
   */
  static async getPlaylistRelations(songIds: number[]): Promise<Array<{ songId: number; playlistId: number }>> {
    try {
      if (songIds.length === 0) return [];
      const rows = await psql<any[]>`
        SELECT pr_ca_id as "songId", pr_pl_id as "playlistId"
        FROM public.rel_playlists_canciones
        WHERE pr_ca_id = ANY(${songIds})
      `;
      return rows;
    } catch (error) {
      console.error('Error al obtener relaciones playlist-canción:', error);
      throw error;
    }
  }
}

export default SongModel;