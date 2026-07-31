import { computed, Injectable, signal, WritableSignal } from '@angular/core';
import { Song } from '../../_models/generals.models';
import { Playlist, GlobalPlaylistSetup, UserScore } from '../../_models/generals.interfaces';
type Result<T> = { ok: true, value?: T } | { ok: false, error: string };

@Injectable({ providedIn: 'root' })
export class GlobalPlaylistService {
  private state: WritableSignal<GlobalPlaylistSetup>;

  constructor() {
    this.state = signal<GlobalPlaylistSetup>({
      initialized: false,
      playlists: [],
      playlistSelected: null,
      songsInPlaylistSelected: [],
      lockRate: false
    });
  }

  readonly playlists = computed(() => this.state().playlists);
  readonly songList = computed(() => this.state().songsInPlaylistSelected);
  readonly selectedPlaylist = computed(() => this.state().playlistSelected);
  readonly currentSong = computed(() => this.state().songPlaying);
  readonly initialized = computed(() => this.state().initialized);

  initialize(setup: GlobalPlaylistSetup): void {
    this.state.set({
      ...setup,
      initialized: true,
    });
  }

  setLockRate(locked: boolean): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede actualizar el estado de bloqueo de calificación.' };
    this.state.update(state => ({
      ...state,
      lockRate: locked
    }));
    return { ok: true };
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
    const songExists = currentState.songsInPlaylistSelected.some(s => s.id === song.id);
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
    const songIndex = currentState.songsInPlaylistSelected.findIndex(s => s.id === songPlaying.id);
    if (songIndex === -1)
      return { ok: false, error: 'La canción en reproducción no existe en la playlist seleccionada.' };
    const updatedSongList = [...currentState.songsInPlaylistSelected];
    updatedSongList[songIndex] = {
      ...updatedSongList[songIndex],
      userScore: score
    };
    this.state.update(state => ({
      ...state,
      songsInPlaylistSelected: updatedSongList,
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
    return { ok: true, value: currentState.playlistSelected || null };
  }

  setSelectedPlaylist(playlist: Playlist): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede seleccionar una playlist.' };
    const playlistExists = currentState.playlists.some(p => p.id === playlist.id);
    if (!playlistExists) return { ok: false, error: 'La playlist seleccionada no existe en la lista global.' };
    this.state.update(state => ({
      ...state,
      playlistSelected: playlist
    }));
    return { ok: true };
  }

  clearSelectedPlaylist(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la playlist seleccionada.' };
    this.state.update(state => ({
      ...state,
      playlistSelected: null
    }));
    return { ok: true };
  }

  getSongList(): Result<Array<Song>> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener la lista de canciones.' };
    return { ok: true, value: currentState.songsInPlaylistSelected || [] };
  }

  setSongList(songs: Array<Song>, options?: { emptyPlaylistList?: boolean, clearSelectedPlaylist?: boolean }): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede actualizar la lista de canciones.' };
    this.state.update(state => ({
      ...state,
      songsInPlaylistSelected: songs,
      playlists: options?.emptyPlaylistList ? [] : state.playlists,
      playlistSelected: options?.clearSelectedPlaylist ? null : state.playlistSelected
    }));
    return { ok: true };
  }

  clearSongList(): Result<void> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede limpiar la lista de canciones.' };
    this.state.update(state => ({
      ...state,
      songsInPlaylistSelected: []
    }));
    return { ok: true };
  }

  getLockRateState(): Result<boolean> {
    const currentState = this.state();
    if (!currentState.initialized) return { ok: false, error: 'La playlist global no ha sido inicializada. No se puede obtener el estado de bloqueo de calificación.' };
    return { ok: true, value: currentState.lockRate || false };
  }
}
