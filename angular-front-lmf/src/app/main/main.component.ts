import { Component, OnInit } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
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
  constructor(
    private httpService: HttpService,
    private playlistService: PlaylistService,
    private router: Router
  ) { }

  async ngOnInit(): Promise<void> {
    try {
      const playlists = await this.httpService.getAllPlaylists();
      if (playlists) {
        const playlistSelected = this.playlistService.getPlaylistSelected();
        const defaultPlaylist = playlists.find(pl => pl.isDefault);
        if (!playlistSelected && defaultPlaylist) {
          const songList = await this.httpService.getPlaylistContentByIdPlaylist(defaultPlaylist.id as number);
          if (songList) {
            await this.playlistService.initializePlaylistGlobal({
              playlists: playlists,
              songList: songList,
              selected: defaultPlaylist
            });
          }
        }
      }
    } catch (error) {
      console.error('Error al cargar playlists:', error);
    }
  }

  navigateToTraining(): void {
    this.router.navigate(['/main/training']);
  }
}
