import { Component, OnInit } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { firstValueFrom } from 'rxjs';
import { PlaylistsService } from '../_services/http/playlists.service';
import { GlobalPlaylistService } from '../_services/system/global-playlist.service';
import { SocketService } from '../_services/system/socket.service';

@Component({
  selector: 'app-main',
  imports: [RouterOutlet, PlayerComponent],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  constructor(
    private playlistsService: PlaylistsService,
    private globalPlaylistService: GlobalPlaylistService,
    private router: Router,
    private socketService: SocketService
  ) { }

  async ngOnInit(): Promise<void> {
    this.socketService.connect();
    try {
      const playlists = await firstValueFrom(this.playlistsService.getAllPlaylists());
      if (playlists) {
        const playlistSelectedResult = this.globalPlaylistService.getSelectedPlaylist();
        const playlistSelected = playlistSelectedResult.ok ? playlistSelectedResult.value : null;
        const defaultPlaylist = playlists.find(pl => pl.isDefault);
        if (!playlistSelected && defaultPlaylist) {
          const songList = await firstValueFrom(this.playlistsService.getPlaylistContentByIdPlaylist(defaultPlaylist.id as number));
          if (songList) {
            this.globalPlaylistService.initialize({
              playlists: playlists,
              songsInPlaylistSelected: songList,
              playlistSelected: defaultPlaylist,
              lockRate: false
            });
          }
        }
      }
    } catch (error) {
      console.error('Error al cargar playlists:', error);
    }
  }

  navigateTo(view: 'training' | 'prediction' | 'stats' | 'vocadb'): void {
    this.router.navigate([`/main/${view}`]).catch(error => console.error(`Error al navegar a ${view}:`, error));
  }

  logout(): void {
    this.socketService.disconnect();
    sessionStorage.removeItem('lmf_token');
    this.router.navigate(['/login']);
  }
}
