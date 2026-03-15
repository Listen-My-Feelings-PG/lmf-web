import { Component, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';
import { ListComponent } from "../../list/list.component";
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { TrainingModality, UserScore } from '../../_types/generals.interfaces';

@Component({
  selector: 'app-training',
  imports: [ListComponent, CommonModule, FormsModule],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent {
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

  constructor(private httpService: HttpService, private globalPlaylistService: GlobalPlaylistService) {
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

  async tuneSong(idSong: number): Promise<void> {
    const tunedSong = await this.httpService.tuneSongByIdSong(idSong);
    const indexInList = this.listForTraining.list.findIndex(song => song.id === idSong);
    if (indexInList !== -1) {
      this.listForTraining.list[indexInList] = tunedSong;
      this.applyFiltersToList();
    }
  }

  private applyFiltersToList(): void {
    let filteredList: Array<Song> = JSON.parse(JSON.stringify(this.listForTraining.list));
    switch (this.selectedMode) {
      case 'clean':
        filteredList = filteredList.filter(song => song.tsTrainLevelGlobal === 0);
        break;
      case 'infer':
        filteredList = filteredList.filter(song => song.tsTrainLevelGlobal > 0);
        break;
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
