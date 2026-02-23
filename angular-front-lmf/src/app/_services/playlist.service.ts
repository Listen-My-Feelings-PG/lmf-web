import { Injectable } from '@angular/core';
import { Playlist, Song } from '../_types/generals.models';
import { BehaviorSubject, Subscription } from 'rxjs';
export interface PlaylistSetup {
  list: Array<Playlist>,
  selected: Playlist | null
}
@Injectable({
  providedIn: 'root'
})
export class PlaylistService {
  private playlistGlobal: BehaviorSubject<PlaylistSetup>

  constructor() {
    this.playlistGlobal = new BehaviorSubject<{
      list: Array<Playlist>,
      selected: Playlist | null
    }>({ list: [], selected: null });
  }

  public getEventSubscriptor(cb: (value: PlaylistSetup) => void): Subscription {
    return this.playlistGlobal.subscribe(cb);
  }

  public updateList(list: Array<Playlist>): void {
    const currentData = this.playlistGlobal.value;
    this.playlistGlobal.next({
      ...currentData,
      list
    });
  }

  public selectPlaylist(playlist: Playlist): void {
    const currentData = this.playlistGlobal.value;
    this.playlistGlobal.next({
      ...currentData,
      selected: playlist
    });
  }

  public updateSongsOfSelectedPlaylist(songs: Array<Song>): void {
    const currentData = this.playlistGlobal.value;
    if (currentData.selected) {
      const updatedSelected = {
        ...currentData.selected,
        songs
      };
      this.playlistGlobal.next({
        ...currentData,
        selected: updatedSelected
      });
    }
  }

  public initializePlaylistData(playlists: Array<Playlist>, selectedPlaylist: Playlist): void {
    this.playlistGlobal.next({
      list: playlists,
      selected: selectedPlaylist
    });
  }
}
