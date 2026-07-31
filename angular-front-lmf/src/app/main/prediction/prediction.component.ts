import { Component, OnInit, OnDestroy, ViewChild } from '@angular/core';
import { GlobalPlaylistService } from '../../_services/system/global-playlist.service';
import { Song } from '../../_models/generals.models';
import { ListComponent } from '../../list/list.component';
import { firstValueFrom } from 'rxjs';
import { SongsService } from '../../_services/http/songs.service';
import { SocketService } from '../../_services/system/socket.service';
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
  };

  currentFilter: 'all' | 'unrated' | 'rated' | 'no-finetune' = 'all';

  @ViewChild(ListComponent) listComponent!: ListComponent;

  private socketSubs: Subscription[] = [];

  constructor(
    private globalPlaylistService: GlobalPlaylistService,
    private songsService: SongsService,
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
      const songsForPrediction = await firstValueFrom(this.songsService.getSongsForPrediction());
      this.listForTraining.listFull = songsForPrediction;
      this.applyFilter();
      this.globalPlaylistService.setLockRate(true);
    } catch (error) {
      console.error('Error al cargar las canciones para predicción:', error);
    }
  }

  setFilter(filter: 'all' | 'unrated' | 'rated' | 'no-finetune'): void {
    this.currentFilter = filter;
    this.applyFilter();
  }

  applyFilter(): void {
    if (this.listComponent) {
      this.listComponent.selectedRows.set(new Set());
    }
    switch (this.currentFilter) {
      case 'unrated':
        this.listForTraining.list = this.listForTraining.listFull.filter(s => s.userScore === null || s.userScore === undefined);
        break;
      case 'rated':
        this.listForTraining.list = this.listForTraining.listFull.filter(s => s.userScore !== null && s.userScore !== undefined);
        break;
      case 'no-finetune':
        // tsTrainLevelGlobal <= 1 (0 = not trained, 1 = clean training only)
        this.listForTraining.list = this.listForTraining.listFull.filter(s => (s.tsTrainLevelGlobal || 0) <= 1);
        break;
      case 'all':
      default:
        this.listForTraining.list = [...this.listForTraining.listFull];
        break;
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
      const ids = (songIds && songIds.length > 0) ? songIds : this.listForTraining.list.map(song => song.id as number);
      if (ids.length === 0) return;
      await firstValueFrom(this.songsService.predictSongsByIds(ids));
      if (this.listComponent) {
        this.listComponent.selectedRows.set(new Set());
      }
    } catch (error) {
      console.error('Error al iniciar la predicción:', error);
    }
  }

  get isAnySelected(): boolean {
    return this.listComponent ? this.listComponent.selectedRows().size > 0 : false;
  }
}
