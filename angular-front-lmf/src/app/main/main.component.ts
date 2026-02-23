import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { Playlist, Song } from '../_types/generals.models';
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
        const globalPlaylist = playlists.find(pl => pl.isGlobal);
        if (globalPlaylist) {
          // Cargar el contenido de la playlist antes de inicializar el estado
          const playlistContent = await this.httpService.getPlaylistContentByIdPlaylist(globalPlaylist.id!);
          globalPlaylist.songs = playlistContent as unknown as Array<Song>;

          // Inicializar todo el estado de una sola vez (una sola emisión)
          this.playlistService.initializePlaylistData(playlists, globalPlaylist);
        } else {
          // Si no hay playlist global, solo actualizar la lista
          this.playlistService.updateList(playlists);
        }
      }
    } catch (error) {
      console.error('Error al cargar playlists:', error);
    }
  }


}
