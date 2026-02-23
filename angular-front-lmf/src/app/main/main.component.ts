import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { HttpService } from '../_services/http.service';
import { PlaylistService } from '../_services/playlist.service';

@Component({
  selector: 'app-main',
  imports: [RouterOutlet, PlayerComponent],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  constructor(private httpService: HttpService, private playlistService: PlaylistService) { }

  async ngOnInit(): Promise<void> {
    try {
      const playlists = await this.httpService.getAllPlaylists();
      if (playlists) {
        const playlistSelected = this.playlistService.getPlaylistSelected();
        const globalPlaylist = playlists.find(pl => pl.isGlobal);
        if (!playlistSelected && globalPlaylist) {
          const songList = await this.httpService.getPlaylistContentByIdPlaylist(globalPlaylist.id as number);
          if (songList) {
            globalPlaylist.songs = songList;
            await this.playlistService.initializePlaylistGlobal({
              list: playlists,
              selected: globalPlaylist
            });
          }
        }
      }
    } catch (error) {
      console.error('Error al cargar playlists:', error);
    }
  }

  newPlayList(confirm: boolean): void {

  }
}
