import { Component, OnInit, OnDestroy } from '@angular/core';
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { Song } from '../../_types/generals.models';
import { ListComponent } from '../../list/list.component';
import { HttpService } from '../../_services/http.service';
import { SocketService } from '../../_services/socket.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-prediction',
  imports: [ListComponent],
  templateUrl: './prediction.component.html',
  styleUrl: './prediction.component.scss'
})
export class PredictionComponent implements OnInit, OnDestroy {
  listForTraining: {
    list: Array<Song>,
    listFull: Array<Song>,
    playlistMode: 'multiple' | 'single'
  }

  private socketSubs: Subscription[] = [];

  constructor(
    private globalPlaylistService: GlobalPlaylistService,
    private httpService: HttpService,
    private socketService: SocketService
  ) {
    this.listForTraining = {
      list: [],
      playlistMode: 'single',
      listFull: []
    }
  }

  async ngOnInit(): Promise<void> {
    this.socketSubs.push(
      this.socketService.taskExec$.subscribe(() => {
        this.reloadSongs();
      }),
      this.socketService.taskFinish$.subscribe(() => {
        this.reloadSongs();
      })
    );
    await this.reloadSongs();
  }

  ngOnDestroy(): void {
    this.socketSubs.forEach(sub => sub.unsubscribe());
  }

  async reloadSongs(): Promise<void> {
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

  async startPrediction(songIds?: number[]): Promise<void> {
    try {
      const ids = songIds ?? this.listForTraining.list.map(song => song.id as number);
      await this.httpService.predictSongsByIds(ids);
    } catch (error) {
      console.error('Error al iniciar la predicción:', error);
    }
  }
}
