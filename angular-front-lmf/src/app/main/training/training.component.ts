import { Component, OnInit } from '@angular/core';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';
import { ListComponent } from "../../list/list.component";

@Component({
  selector: 'app-training',
  imports: [ListComponent],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  listForTraining: {
    list: Array<Song>,
    playlistMode: 'multiple' | 'single'
  }

  constructor(private httpService: HttpService) {
    this.listForTraining = {
      list: [],
      playlistMode: 'single'
    }
  }

  async ngOnInit(): Promise<void> {
    try {
      const scoredSongs = await this.httpService.getSongsScoredByUser();
      this.listForTraining.list = scoredSongs;
      this.listForTraining.playlistMode = 'multiple';
    } catch (error) {
      console.error('Error al cargar datos para entrenamiento:', error);
    }
  }

}
