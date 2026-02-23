import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { Playlist } from '../_types/generals.models';

@Component({
  selector: 'app-main',
  imports: [RouterOutlet, PlayerComponent],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  playlists: {
    list: Array<Playlist>,
    selected: Playlist | null
  }

  constructor() {
    this.playlists = {
      list: [],
      selected: null
    }
  }

  ngOnInit(): void {
    const playListGlobal = this.playlists.list.find(p => p.isGlobal);
    if (playListGlobal) {
      this.playlists.selected = playListGlobal;
    } else {
      //Crear la playlist global
    }
  }


}
