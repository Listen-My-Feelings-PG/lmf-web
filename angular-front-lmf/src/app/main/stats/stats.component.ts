import { Component, effect } from '@angular/core';
import { Song } from '../../_types/generals.models';
import { Calibration } from '../../_types/generals.interfaces';
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { HttpService } from '../../_services/http.service';
import { StatsListComponent } from '../../stats-list/stats-list.component';

@Component({
  selector: 'app-stats',
  imports: [StatsListComponent],
  templateUrl: './stats.component.html',
  styleUrl: './stats.component.scss'
})
export class StatsComponent {
  songList: Array<Song>;

  constructor(private globalPlaylistService: GlobalPlaylistService, private httpService: HttpService) {
    this.songList = [];
    effect(async () => {
      const playlists = this.globalPlaylistService.getCurrentPlaylistList();
      if (playlists.ok && playlists.value?.length) {
        const defaultPlaylist = playlists.value?.find(pl => pl.isDefault);
        const songs = await this.httpService.getAllSongsByPlaylistId(defaultPlaylist?.id as number);
        const calibrationList = await this.httpService.getAllSongsCalibrationByIdPlaylist(defaultPlaylist?.id as number);

        // Agrupar calibraciones "predict" por songId
        const calibrationMap = new Map<number, Calibration[]>();
        for (const cal of calibrationList) {
          if (cal.interactionType === 'predict') {
            const existing = calibrationMap.get(cal.songId) || [];
            existing.push(cal);
            calibrationMap.set(cal.songId, existing);
          }
        }

        // Asignar stats a cada canción
        this.songList = songs.map(song => {
          song.stats = calibrationMap.get(song.id!) || [];
          return song;
        });
      }
    });
  }

  playSong(event: Song): void {
    try {
      this.globalPlaylistService.setLockRate(false);
      this.globalPlaylistService.setSongList(
        this.songList,
        { emptyPlaylistList: true, clearSelectedPlaylist: true }
      );
      this.globalPlaylistService.setSongPlaying(event);
    } catch (error) {
      console.error('Error al reproducir canción:', error);
    }
  }
}
