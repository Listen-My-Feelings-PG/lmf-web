import { Component, OnInit } from '@angular/core';
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { Song } from '../../_types/generals.models';
import { ListComponent } from '../../list/list.component';
import { HttpService } from '../../_services/http.service';

@Component({
  selector: 'app-prediction',
  imports: [ListComponent],
  templateUrl: './prediction.component.html',
  styleUrl: './prediction.component.scss'
})
export class PredictionComponent implements OnInit {
  listForTraining: {
    list: Array<Song>,
    listFull: Array<Song>,
    playlistMode: 'multiple' | 'single'
  }

  constructor(
    private globalPlaylistService: GlobalPlaylistService,
    private httpService: HttpService
  ) {
    this.listForTraining = {
      list: [],
      playlistMode: 'single',
      listFull: []
    }
  }

  async ngOnInit(): Promise<void> {
    try {
      const songsForPrediction = await this.httpService.getSongsForPrediction();
      this.listForTraining = {
        listFull: songsForPrediction,
        playlistMode: 'single',
        list: songsForPrediction
      };
      this.globalPlaylistService.setLockRate(true);
    } catch (error) {
      console.error('Error al cargar las canciones para predicción:', error);
    }

  }

  playSong(event: Song): void {
    try {
      const setSongListResult = this.globalPlaylistService.setSongList(
        this.listForTraining.list,
        { emptyPlaylistList: true, clearSelectedPlaylist: true }
      );

      if (!setSongListResult.ok) {
        console.error('Error al configurar la lista de canciones:', setSongListResult.error);
        return;
      }

      const setSongPlayingResult = this.globalPlaylistService.setSongPlaying(event);
      if (!setSongPlayingResult.ok) {
        console.error('Error al reproducir canción:', setSongPlayingResult.error);
      }
    } catch (error) {
      console.error('Error al reproducir canción:', error);
    }
  }

  startPrediction(): void {

  }
}
