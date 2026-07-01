import { Component, effect, OnInit, OnDestroy, AfterViewInit, AfterContentInit } from '@angular/core';
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
  currentFilter: 'all' | 'unrated' | 'rated' | 'no-finetune' = 'all';
  ratingFilterReference: 'user' | 'prediction' | 'both' = 'user';
  useAccuracyFilter: boolean = false;
  maxAccuracy: number = 100;
  selectedRatings: Set<number> = new Set();

  // Estado del botón de entrenamiento
  trainingMessage: string | null = null;
  trainingMessageType: 'success' | 'error' | 'locked' = 'success';
  private socketSubscriptions: Subscription[] = [];

  constructor(
    private httpService: HttpService,
    private globalPlaylistService: GlobalPlaylistService,
    private socketService: SocketService,
    private toastService: ToastService
  ) {
    this.currentFilter = 'all';
    this.listForTraining = {
      listFiltered: [],
      list: []
    }
  }

  ngOnInit(): void {
    this.reloadSongs();
    this.generateSocketSubscribers();
  }

  generateSocketSubscribers(): void {
    this.socketSubscriptions.push(
      this.socketService.taskFinish$.subscribe(() => {
        this.reloadSongs();
      })
    );
  }

  ngOnDestroy(): void {
    this.socketSubscriptions.forEach(sub => sub.unsubscribe());
  }

  async reloadSongs(): Promise<void> {
    const playlists = await this.httpService.getAllPlaylists();
    if (playlists && playlists.length) {
      const defaultPlaylist = playlists.find(pl => pl.isDefault);
      if (defaultPlaylist?.id) {
        const songs = await this.httpService.getAllSongsByPlaylistId(defaultPlaylist.id);
        this.listForTraining.list = songs;
        this.applyFiltersToList();
      }
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

    // Filtro de Modalidad
    switch (this.currentFilter) {
      case 'unrated':
        if (this.ratingFilterReference === 'user') {
          filteredList = filteredList.filter(s => s.userScore == null);
        } else if (this.ratingFilterReference === 'prediction') {
          filteredList = filteredList.filter(s => s.tsPrediction == null);
        } else {
          filteredList = filteredList.filter(s => s.userScore == null && s.tsPrediction == null);
        }
        break;
      case 'rated':
        if (this.ratingFilterReference === 'user') {
          filteredList = filteredList.filter(s => s.userScore != null);
        } else if (this.ratingFilterReference === 'prediction') {
          filteredList = filteredList.filter(s => s.tsPrediction != null);
        } else {
          filteredList = filteredList.filter(s => s.userScore != null && s.tsPrediction != null);
        }
        break;
      case 'no-finetune':
        filteredList = filteredList.filter(s => (s.tsTrainLevelGlobal || 0) <= 1 && !s.hasFineTuning);
        break;
      case 'all':
      default:
        break;
    }

    // Filtro de Calificación
    const ratingsSelected = Array.from(this.selectedRatings);
    if (ratingsSelected.length > 0) {
      if (this.ratingFilterReference === 'user') {
        filteredList = filteredList.filter(song => song.userScore != null && ratingsSelected.includes(song.userScore as number));
      } else if (this.ratingFilterReference === 'prediction') {
        filteredList = filteredList.filter(song => song.tsPrediction != null && ratingsSelected.includes(song.tsPrediction as number));
      } else {
        filteredList = filteredList.filter(song =>
          (song.userScore != null && ratingsSelected.includes(song.userScore as number)) ||
          (song.tsPrediction != null && ratingsSelected.includes(song.tsPrediction as number))
        );
      }
    }

    // Filtro de Precisión Máxima
    if (this.useAccuracyFilter) {
      if (this.maxAccuracy === 0) {
        filteredList = filteredList.filter(song => song.accuracy === null || song.accuracy === undefined);
      } else if (this.maxAccuracy > 0) {
        filteredList = filteredList.filter(song => song.accuracy !== null && song.accuracy !== undefined && song.accuracy <= this.maxAccuracy);
      }
    }

    this.listForTraining.listFiltered = filteredList;
  }

  setModality(mode: 'all' | 'unrated' | 'rated' | 'no-finetune'): void {
    this.currentFilter = mode;
    this.applyFiltersToList();
  }

  setRatingReference(ref: 'user' | 'prediction' | 'both'): void {
    this.ratingFilterReference = ref;
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
    if (this.currentFilter !== 'all')
      filters.push(`Filtro: ${this.currentFilter}`);
    if (this.useAccuracyFilter)
      filters.push(`Precisión: ${this.maxAccuracy === 0 ? 'Sin calcular' : '<=' + this.maxAccuracy + '%'}`);
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
      // Enviamos 'infer' para que el backend acepte entrenar exactamente la lista que hemos filtrado
      const result = await this.httpService.trainSongsByIds(songIds, 'infer', false);
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
