import { Component, effect, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';
import { ListComponent } from "../../list/list.component";
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { TrainingModality, UserScore } from '../../_types/generals.interfaces';
import { SocketService } from '../../_services/socket.service';
import { Subscription } from 'rxjs';
import { ToastService } from '../../_services/toast.service';

@Component({
  selector: 'app-training',
  imports: [ListComponent, CommonModule, FormsModule],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit, OnDestroy {
  listForTraining: {
    listFiltered: Array<Song>,
    list: Array<Song>
  }

  configPanelCollapsed = false;
  selectedMode: TrainingModality;
  selectedRatings: Set<number> = new Set();

  // Estado del botón de entrenamiento
  trainingMessage: string | null = null;
  trainingMessageType: 'success' | 'error' | 'locked' = 'success';
  private socketSubs: Subscription[] = [];

  constructor(private httpService: HttpService, private globalPlaylistService: GlobalPlaylistService, private socketService: SocketService, private toastService: ToastService) {
    this.selectedMode = 'none';
    this.listForTraining = {
      listFiltered: [],
      list: []
    }
    effect(async () => {
      const playlists = this.globalPlaylistService.getCurrentPlaylistList();
      if (playlists.ok && playlists.value?.length) {
        const defaultPlaylist = playlists.value?.find(pl => pl.isDefault);
        const songs = await this.httpService.getAllSongsByPlaylistId(defaultPlaylist?.id as number);
        this.listForTraining.list = songs;
        this.applyFiltersToList();
      }
    });
  }

  ngOnInit(): void {
    this.socketSubs.push(
      this.socketService.taskExec$.subscribe(() => {
        // No recargamos la lista en el inicio porque ya usamos bloqueo optimista en el front
      }),
      this.socketService.taskFinish$.subscribe(() => {
        this.reloadSongs();
      })
    );
  }

  ngOnDestroy(): void {
    this.socketSubs.forEach(sub => sub.unsubscribe());
  }

  async reloadSongs(): Promise<void> {
    const playlists = this.globalPlaylistService.getCurrentPlaylistList();
    if (playlists.ok && playlists.value?.length) {
      const defaultPlaylist = playlists.value?.find(pl => pl.isDefault);
      const songs = await this.httpService.getAllSongsByPlaylistId(defaultPlaylist?.id as number);
      this.listForTraining.list = songs;
      this.applyFiltersToList();
    }
  }

  async tuneSong(idSong: number): Promise<void> {
    try {
      const response = await this.httpService.tuneSongByIdSong(idSong);
      this.toastService.show(response.message, 'info');
    } catch (error: any) {
      console.warn('Fine-tuning no procesado:', error?.error?.error?.message || error);
    }
  }

  // Este método queda para actualizaciones futuras de lista rápida,
  // pero por ahora reloadSongs() a través de sockets hace el trabajo.
  removeDeletedSongs(songIds: number[]): void {
    const deletedIds = new Set(songIds);
    this.listForTraining.list = this.listForTraining.list.filter(song => !deletedIds.has(song.id!));
    this.applyFiltersToList();
  }

  private applyFiltersToList(): void {
    let filteredList: Array<Song> = JSON.parse(JSON.stringify(this.listForTraining.list));
    if (this.selectedMode === 'clean') {
      filteredList = filteredList.filter(song => song.tsTrainLevelGlobal == 0);
    } else if (this.selectedMode === 'infer') {
      filteredList = filteredList.filter(song => song.tsTrainLevelGlobal > 0);
    }
    const ratingsSelected = Array.from(this.selectedRatings);
    if (ratingsSelected.length > 0)
      filteredList = filteredList.filter(song => ratingsSelected.includes(song.userScore as number));
    this.listForTraining.listFiltered = filteredList;
  }

  setModality(mode: TrainingModality): void {
    this.selectedMode = mode;
    this.applyFiltersToList();
  }

  playSong(event: Song): void {
    try {
      this.globalPlaylistService.setLockRate(false);
      this.globalPlaylistService.setSongList(
        this.listForTraining.listFiltered,
        { emptyPlaylistList: true, clearSelectedPlaylist: true }
      );
      this.globalPlaylistService.setSongPlaying(event);
    } catch (error) {
      console.error('Error al reproducir canción:', error);
    }
  }

  async rateSongByUser(event: { song: Song, score: UserScore }): Promise<void> {
    try {
      const ratedSong = await this.httpService.rateSongByIdSong(event.song.id as number, event.score as UserScore);
      let indexInList = this.listForTraining.listFiltered.findIndex(song => song.id === event.song.id);
      if (indexInList !== -1) {
        this.listForTraining.listFiltered[indexInList] = ratedSong;
        this.listForTraining.listFiltered = [...this.listForTraining.listFiltered];
      }
    } catch (error) {
      console.error('Error al calificar canción:', error);
    }
  }

  toggleConfigPanel(): void {
    this.configPanelCollapsed = !this.configPanelCollapsed;
  }

  toggleRating(rating: number): void {
    this.selectedRatings.has(rating) ? this.selectedRatings.delete(rating) : this.selectedRatings.add(rating);
    this.applyFiltersToList();
  }

  isRatingSelected(rating: number): boolean {
    return this.selectedRatings.has(rating);
  }

  getActiveFiltersText(): string {
    const filters: string[] = [];
    if (this.selectedMode === 'infer')
      filters.push('Modo: Inferir');
    if (this.selectedRatings.size > 0) {
      const ratings = Array.from(this.selectedRatings).sort().map(r => `Rating ${r}`).join(', ');
      filters.push(ratings);
    }
    return filters.length > 0 ? filters.join(' • ') : 'Sin filtros aplicados';
  }

  async startTraining(): Promise<void> {
    const songIds = this.listForTraining.listFiltered.filter((s) => s.userScore !== null).map(song => song.id as number);
    if (songIds.length === 0) return;

    this.trainingMessage = null;

    try {
      const result = await this.httpService.trainSongsByIds(songIds, this.selectedMode, false);
      this.trainingMessage = result.message;
      this.trainingMessageType = 'success';
    } catch (error: any) {
      const status = error?.error?.status;
      if (status === 423) {
        this.trainingMessage = 'Ya hay un proceso de extracción activo. Intente más tarde.';
        this.trainingMessageType = 'locked';
      } else {
        this.trainingMessage = 'Error al iniciar el entrenamiento.';
        this.trainingMessageType = 'error';
      }
      console.error('Error al iniciar el entrenamiento:', error);
    }
  }
}
