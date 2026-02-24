import { Component, OnInit } from '@angular/core';
import { Song } from '../../_types/generals.models';
import { HttpService } from '../../_services/http.service';

@Component({
  selector: 'app-training',
  imports: [],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  listForTraining: {
    list: Array<Song & { idPlaylist: number }>,
    playlistMode: 'multiple' | 'single'
  }

  constructor(private httpService: HttpService) {
    this.listForTraining = {
      list: [],
      playlistMode: 'single'
    }
  }

  ngOnInit(): void { }

}
