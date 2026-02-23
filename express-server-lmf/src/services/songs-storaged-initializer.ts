import fs from 'fs';
import path from 'path';
import SongModel from '../models/song.model';
import PlaylistModel from '../models/playlist.model';
import { Song } from '../types/generals.models';

const GLOBAL_PLAYLIST_ID = 1;

/**
 * Sincroniza el contenido del directorio de audio con la base de datos
 * MODO ESPEJO:
 * - Agrega canciones nuevas encontradas en el directorio
 * - Elimina canciones de la BD que ya no existen en el directorio
 * - Asocia canciones nuevas a la playlist global
 * 
 * NOTA: Al eliminar una canción, su asociación con playlists también se elimina
 * automáticamente mediante la FK con ON DELETE CASCADE
 */
export async function syncStoragedSongs(audioPath: string): Promise<void> {
  try {
    console.info('🔄 Iniciando sincronización en espejo de canciones...');

    // 1. Verificar que el directorio existe
    if (!fs.existsSync(audioPath)) {
      console.warn(`⚠️  El directorio ${audioPath} no existe. Se omite la sincronización.`);
      return;
    }

    // 2. Leer archivos del directorio
    const filesInDirectory = fs.readdirSync(audioPath)
      .filter(file => {
        const ext = path.extname(file).toLowerCase();
        return ext === '.mp3' || ext === '.wav' || ext === '.ogg' || ext === '.m4a';
      });

    console.info(`📁 Archivos encontrados en directorio: ${filesInDirectory.length}`);

    // 3. Obtener canciones de la base de datos
    const songsInDB = await SongModel.getAll();
    const songsInDBMap = new Map(songsInDB.map(song => [song.fileName, song]));

    console.info(`💾 Canciones en base de datos: ${songsInDB.length}`);

    // 4. Identificar canciones nuevas (en directorio pero no en BD)
    const newFiles = filesInDirectory.filter(file => !songsInDBMap.has(file));

    // 5. Identificar canciones a eliminar (en BD pero no en directorio)
    const songsToDelete = songsInDB.filter(song => !filesInDirectory.includes(song.fileName!));

    // 6. Agregar canciones nuevas
    const newSongIds: number[] = [];
    for (const fileName of newFiles) {
      try {
        const filePath = path.join(audioPath, fileName);
        const stats = fs.statSync(filePath);

        const newSong: Song = {
          fileName,
          fileSize: stats.size,
          dataType: 'file'
        };

        const result = await SongModel.newSong(newSong);
        newSongIds.push(result.id);
        console.info(`  ✅ Agregada: ${fileName} (ID: ${result.id})`);
      } catch (error) {
        console.error(`  ❌ Error al agregar ${fileName}:`, error);
      }
    }

    // 7. Eliminar canciones que ya no existen
    if (songsToDelete.length > 0) {
      console.warn(`⚠️  Se eliminarán ${songsToDelete.length} canción(es) sin archivo físico:`);
      for (const song of songsToDelete) {
        console.warn(`     - ${song.fileName} (ID: ${song.id})`);
      }
    }

    for (const song of songsToDelete) {
      try {
        await SongModel.physicalDeleteById(song.id!);
        console.info(`  🗑️  Eliminada: ${song.fileName} (ID: ${song.id})`);
      } catch (error) {
        console.error(`  ❌ Error al eliminar ${song.fileName}:`, error);
      }
    }

    // 8. Sincronizar con la playlist global
    if (newSongIds.length > 0) {
      await syncPlaylistGlobal(newSongIds);
    }

    // Resumen
    console.info('✨ Sincronización completada:');
    console.info(`  • Canciones agregadas: ${newSongIds.length}`);
    console.info(`  • Canciones eliminadas: ${songsToDelete.length}`);
    console.info(`  • Total en BD: ${songsInDB.length + newSongIds.length - songsToDelete.length}`);
    console.info(`  • Archivos en directorio: ${filesInDirectory.length}`);

  } catch (error) {
    console.error('❌ Error durante la sincronización:', error);
    throw error;
  }
}

/**
 * Sincroniza la playlist global con las canciones nuevas
 * - Agrega nuevas canciones a la playlist
 * 
 * NOTA: Las relaciones con canciones eliminadas se gestionan automáticamente
 * mediante la FK con ON DELETE CASCADE (la eliminación de canciones elimina sus asociaciones)
 */
async function syncPlaylistGlobal(newSongIds: number[]): Promise<void> {
  try {
    // Verificar que existe la playlist global
    const globalPlaylist = await PlaylistModel.getGlobalPlaylist();
    if (!globalPlaylist) {
      console.warn('⚠️  No existe una playlist global. Se omite la sincronización de playlist.');
      return;
    }

    // Agregar nuevas canciones a la playlist
    for (const songId of newSongIds) {
      try {
        await PlaylistModel.addSongToPlaylist(GLOBAL_PLAYLIST_ID, songId);
      } catch (error) {
        console.error(`  ❌ Error al agregar canción ${songId} a playlist global:`, error);
      }
    }

    if (newSongIds.length > 0) {
      console.info(`  🎵 Agregadas ${newSongIds.length} canciones a la playlist global`);
    }

  } catch (error) {
    console.error('❌ Error al sincronizar playlist global:', error);
    throw error;
  }
}

/**
 * Función de inicialización que se llama al arrancar el servidor
 */
export async function initializeStoragedSongs(audioPath: string): Promise<void> {
  console.info('='.repeat(50));
  console.info('🎵 Listen My Feelings - Inicialización de Canciones');
  console.info('='.repeat(50));

  try {
    await syncStoragedSongs(audioPath);
    console.info('='.repeat(50));
  } catch (error) {
    console.error('❌ Error crítico durante la inicialización de canciones:', error);
    console.info('='.repeat(50));
    // No lanzamos el error para permitir que el servidor arranque
    // incluso si falla la sincronización
  }
}
