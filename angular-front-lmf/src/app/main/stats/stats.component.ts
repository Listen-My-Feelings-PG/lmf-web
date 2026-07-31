import { Component, OnInit } from '@angular/core';
import { Song } from '../../_models/generals.models';
import { Calibration } from '../../_models/generals.interfaces';
import { GlobalPlaylistService } from '../../_services/system/global-playlist.service';
import { firstValueFrom } from 'rxjs';
import { PlaylistsService } from '../../_services/http/playlists.service';
import { StatsService } from '../../_services/http/stats.service';
import { StatsListComponent } from '../../stats-list/stats-list.component';

@Component({
  selector: 'app-stats',
  imports: [StatsListComponent],
  templateUrl: './stats.component.html',
  styleUrl: './stats.component.scss'
})
export class StatsComponent implements OnInit {
  songList: Array<Song>;

  constructor(
    private globalPlaylistService: GlobalPlaylistService,
    private playlistsService: PlaylistsService,
    private statsService: StatsService
  ) {
    this.songList = [];
  }

  async ngOnInit(): Promise<void> {
    await this.loadData();
  }

  async loadData(): Promise<void> {
    try {
      const playlists = await firstValueFrom(this.playlistsService.getAllPlaylists());
      if (playlists && playlists.length) {
        const defaultPlaylist = playlists.find(pl => pl.isDefault);
        if (defaultPlaylist?.id) {
          const songs = await firstValueFrom(this.playlistsService.getAllSongsByPlaylistId(defaultPlaylist.id));
          const calibrationList = await firstValueFrom(this.statsService.getAllSongsCalibrationByIdPlaylist(defaultPlaylist.id));

          // Agrupar calibraciones de predicción por songId
          const calibrationMap = new Map<number, Calibration[]>();
          for (const cal of calibrationList) {
            if (cal.prediction) {
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
      }
    } catch (error) {
      console.error('Error al cargar datos de estadísticas:', error);
    }
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
