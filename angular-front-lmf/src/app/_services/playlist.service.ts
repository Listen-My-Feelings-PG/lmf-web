import { Injectable } from '@angular/core';
import { Playlist, Song } from '../_types/generals.models';
import { BehaviorSubject, Subscription } from 'rxjs';
export interface PlaylistSetup {
  list: Array<Playlist>,
  selected: Playlist | null,
  initialized?: boolean
}
@Injectable({
  providedIn: 'root'
})
export class PlaylistService {
  private playlistGlobal: BehaviorSubject<PlaylistSetup>;

  constructor() {
    this.playlistGlobal = new BehaviorSubject<PlaylistSetup>({
      list: [],
      selected: null,
      initialized: false
    });
  }

  public getEventSubscription(callback: (value: PlaylistSetup) => void): Subscription {
    return this.playlistGlobal.subscribe((value) => {
      if (value.initialized)
        callback(value);
    });
  }


  public updatePlaylistList(list: Array<Playlist>): void {
    const current = this.playlistGlobal.getValue();
    this.playlistGlobal.next({
      ...current,
      list
    });
  }

  public setSelectedPlaylist(playlist: Playlist): Promise<void> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      if (current.initialized) {
        const playlistExists = current.list.some(p => p.id === playlist.id);
        if (playlistExists) {
          this.playlistGlobal.next({
            ...current,
            selected: playlist
          });
          return resolve();
        } else
          return reject(new Error('La playlist seleccionada no existe en la lista global.'))
      } else
        return reject(new Error('La playlist global no ha sido inicializada. No se puede seleccionar una playlist.'))
    });
  }

  public getPlaylistSelected(): Playlist | null {
    return this.playlistGlobal.getValue().selected;
  }

  public updateContentOfSelectedPlaylist(songs: Array<Song>): Promise<void> {
    return new Promise((resolve, reject) => {
      const current = this.playlistGlobal.getValue();
      if (current.initialized) {
        const selected = current.selected;
        if (selected) {
          const updatedPlaylist = { ...selected, songs };
          this.playlistGlobal.next({
            ...current,
            selected: updatedPlaylist,
            list: current.list.map(pl => pl.id === updatedPlaylist.id ? updatedPlaylist : pl)
          });
          return resolve();
        } else
          return reject(new Error('No hay una playlist seleccionada para actualizar su contenido.'))
      } else
        return reject(new Error('La playlist global no ha sido inicializada. No se puede actualizar el contenido de la playlist seleccionada.'))
    });
  }

  public initializePlaylistGlobal(setup: PlaylistSetup): void {
    this.playlistGlobal.next({
      ...setup,
      initialized: true
    });
  }
}
