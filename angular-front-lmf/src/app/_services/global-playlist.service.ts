import { computed, Injectable, signal, Signal, WritableSignal } from '@angular/core';
import { Song } from '../_types/generals.models';
import { Playlist, GlobalPlaylistSetup, UserScore } from '../_types/generals.interfaces';
type Result<T> = { ok: true, value?: T } | { ok: false, error: string };

@Injectable({ providedIn: 'root' })
export class GlobalPlaylistService {
  private state: WritableSignal<GlobalPlaylistSetup>;

  constructor() {
    this.state = signal<GlobalPlaylistSetup>({
      initialized: false,
      playlists: [],
      selected: null,
      songList: []
    });
  }

  readonly playlists = computed(() => this.state().playlists);
  readonly songList = computed(() => this.state().songList);
  readonly selectedPlaylist = computed(() => this.state().selected);
  readonly currentSong = computed(() => this.state().songPlaying);
  readonly initialized = computed(() => this.state().initialized);

  initialize(setup: GlobalPlaylistSetup): void {
    this.state.set({
      ...setup,
      initialized: true
    });
  }

  getSongPlaying(): Result<Song | null> {
    const currentState = this.state();
    if (!currentState.initialized)
      return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener la canción en reproducción.' };
    return { ok: true, value: currentState.songPlaying || null };
  }

  setSongPlaying(song: Song): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized)
      return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede reproducir una canción.' };
    const songExists = currentState.songList.some(s => s.id === song.id);
    if (!songExists)
      return { ok: false, error: 'La canción seleccionada no existe en la playlist seleccionada.' };
    this.state.update(state => ({
      ...state,
      songPlaying: song
    }));
    return { ok: true };
  }

  clearSongPlaying(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized)
      return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la canción en reproducción.' };
    this.state.update(state => ({
      ...state,
      songPlaying: undefined
    }));
    return { ok: true };
  }

  rateSongPlaying(score: UserScore): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized)
      return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede calificar la canción en reproducción.' };
    const songPlaying = currentState.songPlaying;
    if (!songPlaying)
      return { ok: false, error: 'No hay una canción en reproducción. No se puede calificar.' };
    const songIndex = currentState.songList.findIndex(s => s.id === songPlaying.id);
    if (songIndex === -1)
      return { ok: false, error: 'La canción en reproducción no existe en la playlist seleccionada.' };
    const updatedSongList = [...currentState.songList];
    updatedSongList[songIndex] = {
      ...updatedSongList[songIndex],
      userScore: score
    };
    this.state.update(state => ({
      ...state,
      songList: updatedSongList,
      songPlaying: {
        ...state.songPlaying!,
        userScore: score
      }
    }));
    return { ok: true };
  }

  getCurrentPlaylistList(): Result<Array<Playlist>> {
    const currentState = this.state();
    if (!currentState.initialized)
      return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener la lista de playlists.' };
    return { ok: true, value: currentState.playlists || [] };
  }

  setCurrentPlaylistList(list: Array<Playlist>): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede actualizar la lista de playlists.' };
    this.state.update(state => ({
      ...state,
      playlists: list
    }));
    return { ok: true };
  }

  clearCurrentPlaylistList(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la lista de playlists.' };
    this.state.update(state => ({
      ...state,
      playlists: []
    }));
    return { ok: true };
  }

  getSelectedPlaylist(): Result<Playlist | null> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener la playlist seleccionada.' };
    return { ok: true, value: currentState.selected || null };
  }

  setSelectedPlaylist(playlist: Playlist): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede seleccionar una playlist.' };
    const playlistExists = currentState.playlists.some(p => p.id === playlist.id);
    if (!playlistExists) return { ok: false, error: 'La playlist seleccionada no existe en la lista global.' };
    this.state.update(state => ({
      ...state,
      selected: playlist
    }));
    return { ok: true };
  }

  clearSelectedPlaylist(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la playlist seleccionada.' };
    this.state.update(state => ({
      ...state,
      selected: null
    }));
    return { ok: true };
  }

  getSongList(): Result<Array<Song>> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener la lista de canciones.' };
    return { ok: true, value: currentState.songList || [] };
  }

  setSongList(songs: Array<Song>, options?: { emptyPlaylistList?: boolean, clearSelectedPlaylist?: boolean }): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede actualizar la lista de canciones.' };
    this.state.update(state => ({
      ...state,
      songList: songs,
      playlists: options?.emptyPlaylistList ? [] : state.playlists,
      selected: options?.clearSelectedPlaylist ? null : state.selected
    }));
    return { ok: true };
  }

  clearSongList(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la lista de canciones.' };
    this.state.update(state => ({
      ...state,
      songList: []
    }));
    return { ok: true };
  }
}
