import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';
import { ListComponent } from "../../list/list.component";

@Component({
  selector: 'app-training',
  imports: [ListComponent, CommonModule, FormsModule],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  listForTraining: {
    list: Array<Song>,
    playlistMode: 'multiple' | 'single'
  }

  configPanelCollapsed = false;
  selectedMode: 'clean' | 'infer' = 'clean';
  includePlaylistTraining = false;
  selectedRatings: Set<number> = new Set();

  constructor(private httpService: HttpService) {
    this.listForTraining = {
      list: [],
      playlistMode: 'single'
    }
  }

  async ngOnInit(): Promise<void> {
    try {
      const scoredSongs = await this.httpService.getSongsScoredByUser();
      // Crear un nuevo objeto para forzar la detección de cambios
      this.listForTraining = {
        list: scoredSongs,
        playlistMode: 'multiple'
      };
    } catch (error) {
      console.error('Error al cargar datos para entrenamiento:', error);
    }
  }

  toggleConfigPanel(): void {
    this.configPanelCollapsed = !this.configPanelCollapsed;
  }

  toggleRating(rating: number): void {
    if (this.selectedRatings.has(rating)) {
      this.selectedRatings.delete(rating);
    } else {
      this.selectedRatings.add(rating);
    }
  }

  isRatingSelected(rating: number): boolean {
    return this.selectedRatings.has(rating);
  }

  getActiveFiltersText(): string {
    const filters: string[] = [];

    if (this.selectedMode === 'infer') {
      filters.push('Modo: Inferir');
    }

    if (this.includePlaylistTraining) {
      filters.push('Incluye Playlist');
    }

    if (this.selectedRatings.size > 0) {
      const ratings = Array.from(this.selectedRatings).sort().map(r => `Rating ${r}`).join(', ');
      filters.push(ratings);
    }

    return filters.length > 0 ? filters.join(' • ') : 'Sin filtros aplicados';
  }

}
