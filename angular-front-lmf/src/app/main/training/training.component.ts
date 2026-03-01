import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';
import { ListComponent } from "../../list/list.component";
import { GlobalPlaylistService } from '../../_services/global-playlist.service';
import { UserScore } from '../../_types/generals.interfaces';

@Component({
  selector: 'app-training',
  imports: [ListComponent, CommonModule, FormsModule],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  listForTraining: {
    list: Array<Song>,
    listFull: Array<Song>,
    playlistMode: 'multiple' | 'single'
  }

  configPanelCollapsed = false;
  selectedMode: 'clean' | 'infer';
  includePlaylistTraining = false;
  selectedRatings: Set<number> = new Set();

  // Estado del botón de entrenamiento
  trainingMessage: string | null = null;
  trainingMessageType: 'success' | 'error' | 'locked' = 'success';

  constructor(private httpService: HttpService, private globalPlaylistService: GlobalPlaylistService) {
    this.selectedMode = 'clean';
    this.listForTraining = {
      list: [],
      playlistMode: 'single',
      listFull: []
    }
  }

  private applyFiltersToList(): void {
    let filteredList = this.listForTraining.listFull;
    filteredList = this.selectedMode === 'clean' ? filteredList.filter(song => song.tsTrainLevelGlobal === 0) : filteredList.filter(song => song.tsTrainLevelGlobal < 0)
    if (this.includePlaylistTraining)
      filteredList = this.selectedMode === 'clean' ? filteredList.filter(song => song.tsTrainLevelLocal === 0) : filteredList.filter(song => song.tsTrainLevelLocal < 0)
    const ratingsSelected = Array.from(this.selectedRatings);
    if (ratingsSelected.length > 0)
      filteredList = filteredList.filter(song => ratingsSelected.includes(song.userScore as number));
    console.log('filteredList', filteredList.filter(song => song.userScore === null));
    this.listForTraining.list = filteredList;
  }

  setModality(mode: 'clean' | 'infer'): void {
    this.selectedMode = mode;
    this.applyFiltersToList();
  }

  async ngOnInit(): Promise<void> {
    try {
      const scoredSongs = await this.httpService.getSongsScoredByUser();
      this.listForTraining = {
        listFull: scoredSongs,
        playlistMode: 'multiple',
        list: scoredSongs.filter((song) => song.tsTrainLevelGlobal === 0)
      };
    } catch (error) {
      console.error('Error al cargar datos para entrenamiento:', error);
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

  rateSongByUser(event: { song: Song, score: UserScore }): void {
    try {
      this.httpService.rateSongByIdSong(event.song.id as number, event.score as UserScore).then(() => {
        const result = this.globalPlaylistService.setSongList(
          this.listForTraining.list,
          { emptyPlaylistList: true, clearSelectedPlaylist: true }
        );
        if (!result.ok) {
          console.error('Error al actualizar la lista de canciones:', result.error);
        }
      }).catch(error => {
        console.error('Error al calificar canción:', error);
      });
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
    if (this.includePlaylistTraining)
      filters.push('Incluye Playlist');
    if (this.selectedRatings.size > 0) {
      const ratings = Array.from(this.selectedRatings).sort().map(r => `Rating ${r}`).join(', ');
      filters.push(ratings);
    }
    return filters.length > 0 ? filters.join(' • ') : 'Sin filtros aplicados';
  }

  async startTraining(): Promise<void> {
    const songIds = this.listForTraining.list.map(song => song.id as number);

    if (songIds.length === 0) return;

    this.trainingMessage = null;

    try {
      const result = await this.httpService.trainSongsByIds(songIds);
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
