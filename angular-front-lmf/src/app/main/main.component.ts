import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { Playlist } from '../_types/generals.models';
import { HttpService } from '../_services/http.service';

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

  constructor(private httpService: HttpService) {
    this.playlists = {
      list: [],
      selected: null
    }
  }

  async ngOnInit(): Promise<void> {
    try {
      const playlists = await this.httpService.getAllPlaylists();
      if (playlists) {
        this.playlists.list = playlists;
        /*const globalPlaylist = playlists.find(pl => pl.isGlobal);
        if (globalPlaylist) {
          this.playlists.selected = globalPlaylist;
          const playlistContent = await this.httpService.getPlaylistContentByIdPlaylist(globalPlaylist.id!);
          console.log('playlistContent', playlistContent);
        }*/

      }
    } catch (error) {
      console.error('Error al cargar playlists:', error);
    }
  }


}
