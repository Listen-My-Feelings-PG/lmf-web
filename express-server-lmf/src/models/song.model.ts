import { psql } from "../main";
import { Song } from "../types/generals.models";

/**
 * Modelo para manejar canciones en la base de datos
 */
class SongModel {
  /**
   * Crear una nueva canciÃ³n
   */
  static async new(songData: Song): Promise<{ id: number }> {
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
      if (songData.tsScore !== undefined)
        updates.push('ca_ts_prediccion = ' + psql([songData.tsScore]));
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
          ${songData.tsScore !== undefined ? psql`, ca_ts_prediccion = ${songData.tsScore}` : psql``}
          ${songData.tsTrainLevelLocal !== undefined ? psql`, ca_train_level_local = ${songData.tsTrainLevelLocal}` : psql``}
          ${songData.tsTrainLevelGlobal !== undefined ? psql`, ca_train_level_global = ${songData.tsTrainLevelGlobal}` : psql``}
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
}

export default SongModel;