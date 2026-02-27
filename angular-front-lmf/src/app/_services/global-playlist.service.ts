import { Injectable } from '@angular/core';
import { Song } from '../_types/generals.models';
import { BehaviorSubject, Subscription } from 'rxjs';
import { Playlist, GlobalPlaylistSetup, UserScore } from '../_types/generals.interfaces';
@Injectable({
  providedIn: 'root'
})
export class GlobalPlaylistService {
  private playlistGlobal: BehaviorSubject<GlobalPlaylistSetup>;

  constructor() {
    this.playlistGlobal = new BehaviorSubject<GlobalPlaylistSetup>({
      playlists: [],
      songList: [],
      selected: null,
      initialized: false
    });
  }

  songPlaying(mode: 'get' | 'set' | 'clear', song?: Song): Promise<Song | null> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      switch (mode) {
        case 'get':
          return resolve(current.songPlaying || null);
        case 'set':
          if (current.initialized) {
            const playListSelected = current.selected;
            if (playListSelected) {
              const songExists = current.songList.some(s => s.id === song?.id);
              if (songExists && song) {
                this.playlistGlobal.next({
                  ...current,
                  songPlaying: song
                });
                return resolve(song);
              } else
                return reject(new Error('La canción seleccionada no existe en la playlist seleccionada.'))
            }
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede reproducir una canción.'));
          break;
        case 'clear':
          if (current.initialized) {
            this.playlistGlobal.next({
              ...current,
              songPlaying: undefined
            });
            return resolve(null);
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede limpiar la canción en reproducción.'));
      }
    });
  }

  currentPlaylistList(mode: 'set' | 'get' | 'clear', list?: Array<Playlist>): Promise<Array<Playlist> | null> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      switch (mode) {
        case 'get':
          return resolve(current.playlists || null);
        case 'set':
          if (current.initialized) {
            this.playlistGlobal.next({
              ...current,
              playlists: list || []
            });
            return resolve(null);
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede actualizar la lista de playlists.'));
        case 'clear':
          this.playlistGlobal.next({
            ...current,
            playlists: []
          });
          return resolve([]);
      }
    });
  }

  selectedPlaylist(mode: 'set' | 'get' | 'clear', playlist?: Playlist): Promise<Playlist | null> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      switch (mode) {
        case 'get':
          return resolve(current.selected || null);
        case 'set':
          if (current.initialized) {
            const playlistExists = current.playlists.some(p => p.id === playlist?.id);
            if (playlistExists && playlist) {
              this.playlistGlobal.next({
                ...current,
                selected: playlist
              });
              return resolve(playlist);
            } else
              return reject(new Error('La playlist seleccionada no existe en la lista global.'));
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede seleccionar una playlist.'));
        case 'clear':
          if (current.initialized) {
            this.playlistGlobal.next({
              ...current,
              selected: null
            });
            return resolve(null);
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede limpiar la playlist seleccionada.'));
      }
    });
  }

  songList(mode: 'set' | 'get' | 'clear', songs?: Array<Song>, emptyPlaylistList?: boolean, clearSelectedPlaylist?: boolean): Promise<Array<Song> | null> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      switch (mode) {
        case 'get':
          return resolve(current.songList || null);
        case 'set':
          if (current.initialized) {
            if (emptyPlaylistList)
              current.playlists = [];

            if (clearSelectedPlaylist)
              current.selected = null;

            this.playlistGlobal.next({
              ...current,
              songList: songs || []
            });
            return resolve(songs || []);
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede actualizar el contenido de la playlist seleccionada.'));
        case 'clear':
          if (current.initialized) {
            this.playlistGlobal.next({
              ...current,
              songList: []
            });
            return resolve([]);
          } else
            return reject(new Error('La playlist global no ha sido inicializada. No se puede limpiar el contenido de la playlist seleccionada.'));
      }
    });
  }

  public setSongRating(songId: number, rating: UserScore): Promise<void> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      if (current.initialized) {
        const updatedList = current.songList.map(s =>
          s.id === songId
            ? { ...s, userScore: rating }
            : s
        );
        this.playlistGlobal.next({
          ...current,
          songList: updatedList
        });
        return resolve();
      } else
        return reject(new Error('La playlist global no ha sido inicializada. No se puede actualizar el rating de la canción.'));
    });
  }

  public initialize(setup: GlobalPlaylistSetup): void {
    this.playlistGlobal.next({
      ...setup,
      initialized: true
    });
  }

  public getEventSubscription(callback: (value: GlobalPlaylistSetup) => void): Subscription {
    return this.playlistGlobal.subscribe((value) => {
      if (value.initialized)
        callback(value);
    });
  }
}
