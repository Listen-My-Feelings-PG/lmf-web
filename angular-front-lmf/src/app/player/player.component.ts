import { Component, OnInit } from '@angular/core';
import { Song } from '../_types/generals.models';
import { PlaylistService } from '../_services/playlist.service';
import { HttpService } from '../_services/http.service';

@Component({
  selector: 'app-player',
  imports: [],
  templateUrl: './player.component.html',
  styleUrl: './player.component.scss'
})
export class PlayerComponent implements OnInit {
  setup: {
    list: Array<Song>,
    playingIndex: number | null,
  }

  constructor(private playlistService: PlaylistService, private httpService: HttpService) {
    this.setup = {
      playingIndex: null,
      list: []
    }
  }

  ngOnInit(): void {
    this.playlistService.getEventSubscription((value) => {
      if (value.songPlaying) {
        const songPlaying = this.setup.list[this.setup.playingIndex!];
        if (!songPlaying || (songPlaying.id !== value.songPlaying.id)) {
          this.setup.list = value.selected?.songs || [];
          this.play(value.songPlaying!);
        }
      }
    });
  }


  play(song: Song): Promise<void> {
    return new Promise(async (resolve, reject) => {
      const songIndex = this.setup.list.findIndex(s => s.id === song.id);
      if (songIndex !== -1) {
        this.setup.playingIndex = songIndex;
        // Aquí se hará todo el proceso de reproducción del audio, tomando en cuenta el estatus de la canción (si es la misma que se está reproduciendo, si es una nueva, etc.)
        return resolve();
      } else
        return reject(new Error('La canción seleccionada no existe en la playlist actual. No se puede reproducir.'));
    });

  }

  pause(): void {
    // Aquí se hará todo el proceso para pausar la reproducción del audio.
  }

  next(): void {
    if (this.setup.playingIndex !== null && this.setup.playingIndex < this.setup.list.length - 1) {
      const nextIndex = this.setup.playingIndex + 1;
      const nextSong = this.setup.list[nextIndex];
      this.play(nextSong);
    }
  }

  previous(): void {
    if (this.setup.playingIndex !== null && this.setup.playingIndex > 0) {
      const previousIndex = this.setup.playingIndex - 1;
      const previousSong = this.setup.list[previousIndex];
      this.play(previousSong);
    }
  }

  stop(): void {
    this.setup.playingIndex = null;
    // Aquí se hará todo el proceso para detener la reproducción del audio.
  }
}
