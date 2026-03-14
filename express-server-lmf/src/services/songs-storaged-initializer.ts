import fs from 'fs';
import path from 'path';
import SongModel from '../models/song.model';
import PlaylistModel from '../models/playlist.model';
import { Song } from '../types/generals.models';

const DEFAULT_PLAYLIST_ID = 1;

/**
 * Sincroniza el contenido del directorio de audio con la base de datos
 * MODO ESPEJO CON BORRADO LÓGICO:
 * - Agrega canciones nuevas encontradas en el directorio
 * - Reactiva canciones inactivas si su archivo vuelve a existir
 * - Desactiva canciones (ca_activo = 0) que ya no existen en el directorio
 * - Asocia canciones nuevas a la playlist default
 * 
 * NOTA: Las canciones solo se desactivan, nunca se eliminan físicamente
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

    // 3. Verificar y reactivar canciones inactivas que vuelven a existir
    const inactiveSongs = await SongModel.getInactive();
    const reactivatedSongs: number[] = [];

    for (const song of inactiveSongs) {
      if (filesInDirectory.includes(song.fileName!)) {
        try {
          await SongModel.reactivateById(song.id!);
          reactivatedSongs.push(song.id!);
          console.info(`  ✅ Reactivada: ${song.fileName} (ID: ${song.id})`);
        } catch (error) {
          console.error(`  ❌ Error al reactivar ${song.fileName}:`, error);
        }
      }
    }

    // 4. Obtener canciones activas de la base de datos
    const songsInDB = await SongModel.getAll();
    const songsInDBMap = new Map(songsInDB.map(song => [song.fileName, song]));

    console.info(`💾 Canciones activas en base de datos: ${songsInDB.length}`);

    // 5. Identificar canciones nuevas (en directorio pero no en BD activas)
    const newFiles = filesInDirectory.filter(file => !songsInDBMap.has(file));

    // 6. Identificar canciones a desactivar (en BD activas pero no en directorio)
    const songsToDeactivate = songsInDB.filter(song => !filesInDirectory.includes(song.fileName!));

    // 7. Agregar canciones nuevas
    const newSongIds: number[] = [];
    for (const fileName of newFiles) {
      try {
        const filePath = path.join(audioPath, fileName);
        const stats = fs.statSync(filePath);

        const newSong = new Song({
          fileName,
          fileSize: stats.size
        });

        const result = await SongModel.newSong(newSong);
        newSongIds.push(result.id);
        console.info(`  ✅ Agregada: ${fileName} (ID: ${result.id})`);
      } catch (error) {
        console.error(`  ❌ Error al agregar ${fileName}:`, error);
      }
    }

    // 8. Desactivar canciones que ya no existen (borrado lógico)
    if (songsToDeactivate.length > 0) {
      console.warn(`⚠️  Se desactivarán ${songsToDeactivate.length} canción(es) sin archivo físico:`);
      for (const song of songsToDeactivate) {
        console.warn(`     - ${song.fileName} (ID: ${song.id})`);
      }
    }

    for (const song of songsToDeactivate) {
      try {
        await SongModel.logicalDeleteById(song.id!);
        console.info(`  🔒 Desactivada: ${song.fileName} (ID: ${song.id})`);
      } catch (error) {
        console.error(`  ❌ Error al desactivar ${song.fileName}:`, error);
      }
    }

    // 9. Sincronizar con la playlist default
    if (newSongIds.length > 0 || reactivatedSongs.length > 0) {
      await syncPlaylistDefault([...newSongIds, ...reactivatedSongs]);
    }

    // Resumen
    console.info('✨ Sincronización completada:');
    console.info(`  • Canciones reactivadas: ${reactivatedSongs.length}`);
    console.info(`  • Canciones agregadas: ${newSongIds.length}`);
    console.info(`  • Canciones desactivadas: ${songsToDeactivate.length}`);
    console.info(`  • Total activas en BD: ${songsInDB.length + newSongIds.length + reactivatedSongs.length - songsToDeactivate.length}`);
    console.info(`  • Archivos en directorio: ${filesInDirectory.length}`);

  } catch (error) {
    console.error('❌ Error durante la sincronización:', error);
    throw error;
  }
}

/**
 * Sincroniza la playlist default con las canciones nuevas y reactivadas
 * - Agrega nuevas canciones a la playlist
 * - Agrega canciones reactivadas a la playlist
 * 
 * NOTA: Las canciones desactivadas permanecen en la playlist para mantener el historial
 */
async function syncPlaylistDefault(songIds: number[]): Promise<void> {
  try {
    // Verificar que existe la playlist default
    const defaultPlaylist = await PlaylistModel.getDefaultPlaylist();
    if (!defaultPlaylist) {
      console.warn('⚠️  No existe una playlist default. Se omite la sincronización de playlist.');
      return;
    }

    // Agregar canciones nuevas y reactivadas a la playlist
    for (const songId of songIds) {
      try {
        await PlaylistModel.addSongToPlaylist(DEFAULT_PLAYLIST_ID, songId);
      } catch (error) {
        console.error(`  ❌ Error al agregar canción ${songId} a playlist default:`, error);
      }
    }

    if (songIds.length > 0) {
      console.info(`  🎵 Agregadas ${songIds.length} canciones a la playlist default`);
    }

  } catch (error) {
    console.error('❌ Error al sincronizar playlist default:', error);
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
