import { Component, OnDestroy, effect } from '@angular/core';
import { Song } from '../_types/generals.models';
import { GlobalPlaylistService } from '../_services/global-playlist.service';
import { HttpService } from '../_services/http.service';
import { UserScore } from '../_types/generals.interfaces';

@Component({
  selector: 'app-player',
  imports: [],
  templateUrl: './player.component.html',
  styleUrl: './player.component.scss'
})
export class PlayerComponent implements OnDestroy {
  setup: {
    list: Array<Song>,
    playingIndex: number | null,
    lockRate: boolean
  }

  // Audio player
  private audio: HTMLAudioElement;
  public isPlaying: boolean = false;
  public isLoading: boolean = false;
  public currentTime: number = 0;
  public duration: number = 0;
  public volume: number = 1;
  private currentBlobUrl: string | null = null;

  constructor(
    private globalPlaylistService: GlobalPlaylistService,
    private httpService: HttpService
  ) {
    this.setup = {
      playingIndex: null,
      list: [],
      lockRate: false
    }

    // Inicializar el elemento de audio
    this.audio = new Audio();
    this.setupAudioListeners();

    // Effect en constructor (contexto de inyección válido)
    effect(() => {
      const currentSongs = this.globalPlaylistService.songList();
      const songPlaying = this.globalPlaylistService.currentSong();
      const lockRateStatus = this.globalPlaylistService.getLockRateState();
      if (lockRateStatus.ok)
        this.setup.lockRate = lockRateStatus.value || false;

      if (!songPlaying) {
        if (this.setup.playingIndex !== null)
          this.stop();
        this.setup.list = currentSongs;
        return;
      }

      if (songPlaying) {
        const currentPlayingSong = this.setup.list[this.setup.playingIndex!];
        if (!currentPlayingSong || (currentPlayingSong.id !== songPlaying.id)) {
          this.setup.list = currentSongs;
          this.play(songPlaying!);
        }
      }

      // Detectar cambios en el contenido (ratings) incluso si no cambió la canción
      const songsContentChanged = currentSongs.some((song, index) => {
        const existingSong = this.setup.list[index];
        return !existingSong || song.userScore !== existingSong.userScore;
      });

      if (songsContentChanged)
        this.setup.list = currentSongs;
    });
  }



  private setupAudioListeners(): void {
    // Actualizar el tiempo actual
    this.audio.addEventListener('timeupdate', () => {
      this.currentTime = this.audio.currentTime;
    });

    // Cuando se carga la metadata del audio
    this.audio.addEventListener('loadedmetadata', () => {
      this.duration = this.audio.duration;
    });

    // Cuando el audio está listo para reproducir
    this.audio.addEventListener('canplay', () => {
      this.isLoading = false;
    });

    // Cuando el audio empieza a reproducir
    this.audio.addEventListener('play', () => {
      this.isPlaying = true;
    });

    // Cuando el audio se pausa
    this.audio.addEventListener('pause', () => {
      this.isPlaying = false;
    });

    // Cuando el audio termina
    this.audio.addEventListener('ended', () => {
      this.isPlaying = false;
      this.next();
    });

    // Cuando hay un error
    this.audio.addEventListener('error', (e) => {
      console.error('Error al reproducir audio:', e);
      this.isLoading = false;
      this.isPlaying = false;
    });
  }

  async play(song: Song): Promise<void> {
    return new Promise(async (resolve, reject) => {
      const songIndex = this.setup.list.findIndex(s => s.id === song.id);
      if (songIndex !== -1) {
        try {
          // Si es la misma canción y está pausada, solo reanudar
          if (this.setup.playingIndex === songIndex && this.audio.src && !this.isPlaying) {
            await this.audio.play();
            return resolve();
          }

          // Es una nueva canción, cargar y reproducir
          this.setup.playingIndex = songIndex;
          this.isLoading = true;

          // Limpiar URL de blob anterior
          if (this.currentBlobUrl) {
            URL.revokeObjectURL(this.currentBlobUrl);
            this.currentBlobUrl = null;
          }

          // Descargar la canción
          if (!song.id) {
            throw new Error('La canción no tiene ID');
          }

          const blob = await this.httpService.downloadSongByIdSong(song.id);
          this.currentBlobUrl = URL.createObjectURL(blob);

          // Configurar y reproducir
          this.audio.src = this.currentBlobUrl;
          this.audio.volume = this.volume;
          await this.audio.play();

          return resolve();
        } catch (error) {
          this.isLoading = false;
          console.error('Error al reproducir canción:', error);
          return reject(error);
        }
      } else {
        return reject(new Error('La canción seleccionada no existe en la playlist actual. No se puede reproducir.'));
      }
    });
  }

  pause(): void {
    if (this.audio && this.isPlaying) {
      this.audio.pause();
    }
  }

  resume(): void {
    if (this.audio && !this.isPlaying && this.audio.src) {
      this.audio.play().catch(err => console.error('Error al reanudar:', err));
    }
  }

  togglePlayPause(): void {
    if (this.isPlaying) {
      this.pause();
    } else {
      this.resume();
    }
  }

  next(): void {
    if (this.setup.playingIndex !== null && this.setup.playingIndex < this.setup.list.length - 1) {
      const nextIndex = this.setup.playingIndex + 1;
      const nextSong = this.setup.list[nextIndex];
      const result = this.globalPlaylistService.setSongPlaying(nextSong);
      if (!result.ok) {
        console.error('Error al reproducir siguiente canción:', result.error);
      }
    }
  }

  previous(): void {
    if (this.setup.playingIndex !== null && this.setup.playingIndex > 0) {
      const previousIndex = this.setup.playingIndex - 1;
      const previousSong = this.setup.list[previousIndex];
      const result = this.globalPlaylistService.setSongPlaying(previousSong);
      if (!result.ok) {
        console.error('Error al reproducir canción anterior:', result.error);
      }
    }
  }

  stop(): void {
    if (this.audio) {
      this.audio.pause();
      this.audio.currentTime = 0;
      this.setup.playingIndex = null;
    }
  }

  setVolume(volume: number): void {
    this.volume = Math.max(0, Math.min(1, volume));
    if (this.audio) {
      this.audio.volume = this.volume;
    }
  }

  seek(time: number): void {
    if (this.audio && this.duration > 0) {
      this.audio.currentTime = Math.max(0, Math.min(this.duration, time));
    }
  }

  getCurrentSong(): Song | null {
    if (this.setup.playingIndex !== null) {
      return this.setup.list[this.setup.playingIndex];
    }
    return null;
  }

  formatTime(seconds: number): string {
    if (!seconds || isNaN(seconds)) return '0:00';
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  onProgressBarClick(event: MouseEvent): void {
    if (this.duration > 0) {
      const progressBar = event.currentTarget as HTMLElement;
      const rect = progressBar.getBoundingClientRect();
      const clickX = event.clientX - rect.left;
      const percentage = clickX / rect.width;
      const newTime = percentage * this.duration;
      this.seek(newTime);
    }
  }

  setSongTitles(song: Song | null, tag: 'title' | 'artist' | 'album'): string {
    if (!song) return '';
    switch (tag) {
      case 'title':
        return song.metadata?.title || song.fileName;
      case 'artist':
        return song.metadata?.artist || '(artista desconocido)';
      case 'album':
        return song.metadata?.album || '(álbum desconocido)';
      default:
        return '';
    }
  }

  async rateSong(score: number): Promise<void> {
    if (this.setup.lockRate) return;

    // Validar que el score sea válido
    if (score < 0 || score > 3) {
      console.error('Score inválido:', score);
      return;
    }

    const currentSong = this.getCurrentSong();
    if (!currentSong || !currentSong.id) {
      console.error('No hay canción activa para calificar');
      return;
    }

    try {
      const songRated = await this.httpService.rateSongByIdSong(currentSong.id, score as UserScore);
      this.globalPlaylistService.rateSongPlaying(songRated.userScore as UserScore);
    } catch (error) {
      console.error('Error al calificar la canción:', error);
    }
  }

  ngOnDestroy(): void {
    // Limpiar el audio y liberar recursos
    if (this.audio) {
      this.audio.pause();
      this.audio.src = '';
    }

    // Limpiar URL de blob
    if (this.currentBlobUrl) {
      URL.revokeObjectURL(this.currentBlobUrl);
      this.currentBlobUrl = null;
    }
  }
}
