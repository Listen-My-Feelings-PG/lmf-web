import { Component, OnInit } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { HttpService } from '../_services/http.service';
import { GlobalPlaylistService } from '../_services/global-playlist.service';

@Component({
  selector: 'app-main',
  imports: [RouterOutlet, PlayerComponent],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  constructor(
    private httpService: HttpService,
    private globalPlaylistService: GlobalPlaylistService,
    private router: Router
  ) { }

  async ngOnInit(): Promise<void> {
    try {
      const playlists = await this.httpService.getAllPlaylists();
      if (playlists) {
        const playlistSelectedResult = this.globalPlaylistService.getSelectedPlaylist();
        const playlistSelected = playlistSelectedResult.ok ? playlistSelectedResult.value : null;
        const defaultPlaylist = playlists.find(pl => pl.isDefault);
        if (!playlistSelected && defaultPlaylist) {
          const songList = await this.httpService.getPlaylistContentByIdPlaylist(defaultPlaylist.id as number);
          if (songList) {
            this.globalPlaylistService.initialize({
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
