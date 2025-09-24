import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, combineLatest } from 'rxjs';
import { map } from 'rxjs/operators';
import { AppState, Playlist, Song, ProcessingPool, TaskProgress } from '../_models/types';

@Injectable({
  providedIn: 'root'
})
export class StateService {
  private readonly initialState: AppState = {
    playlists: {
      list: [],
      selected: null,
      default: null,
      loaded: false
    },
    tensorflow: {
      initialized: false,
      memoryUsage: 0,
      activeModels: []
    },
    processing: {
      upload: this.createEmptyPool<Song>(),
      featureExtraction: this.createEmptyPool<number>(),
      training: this.createEmptyPool<Song>()
    },
    ui: {
      loading: false,
      currentView: 'training',
      modalStates: {}
    }
  };

  private readonly state$ = new BehaviorSubject<AppState>(this.initialState);

  // Selectores principales
  readonly playlists$ = this.state$.pipe(map(state => state.playlists));
  readonly selectedPlaylist$ = this.state$.pipe(map(state => state.playlists.selected));
  readonly defaultPlaylist$ = this.state$.pipe(map(state => state.playlists.default));
  readonly tensorflow$ = this.state$.pipe(map(state => state.tensorflow));
  readonly processing$ = this.state$.pipe(map(state => state.processing));
  readonly ui$ = this.state$.pipe(map(state => state.ui));

  // Selectores derivados
  readonly isAnyProcessing$ = this.processing$.pipe(
    map(processing =>
      processing.upload.busy ||
      processing.featureExtraction.busy ||
      processing.training.busy
    )
  );

  readonly overallProgress$ = this.processing$.pipe(
    map(processing => {
      const pools = [processing.upload, processing.featureExtraction, processing.training];
      const totalTasks = pools.reduce((sum, pool) => sum + pool.progress.total, 0);
      const completedTasks = pools.reduce((sum, pool) => sum + pool.progress.current, 0);

      return totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;
    })
  );

  constructor() { }

  // Estado getter
  getCurrentState(): AppState {
    return this.state$.value;
  }

  // Actualizadores de playlists
  setPlaylists(playlists: Playlist[]): void {
    this.updateState(state => ({
      ...state,
      playlists: {
        ...state.playlists,
        list: playlists,
        loaded: true
      }
    }));
  }

  setSelectedPlaylist(playlist: Playlist | null): void {
    this.updateState(state => ({
      ...state,
      playlists: {
        ...state.playlists,
        selected: playlist
      }
    }));
  }

  setDefaultPlaylist(playlist: Playlist | null): void {
    this.updateState(state => ({
      ...state,
      playlists: {
        ...state.playlists,
        default: playlist
      }
    }));
  }

  addPlaylist(playlist: Playlist): void {
    this.updateState(state => ({
      ...state,
      playlists: {
        ...state.playlists,
        list: [...state.playlists.list, playlist]
      }
    }));
  }

  updatePlaylistSongs(playlistId: number, songs: Song[]): void {
    this.updateState(state => {
      const updatedList = state.playlists.list.map(pl =>
        pl.id === playlistId ? { ...pl, songs } : pl
      );

      let updatedSelected = state.playlists.selected;
      if (updatedSelected?.id === playlistId) {
        updatedSelected = { ...updatedSelected, songs };
      }

      let updatedDefault = state.playlists.default;
      if (updatedDefault?.id === playlistId) {
        updatedDefault = { ...updatedDefault, songs };
      }

      return {
        ...state,
        playlists: {
          ...state.playlists,
          list: updatedList,
          selected: updatedSelected,
          default: updatedDefault
        }
      };
    });
  }

  updateSongInPlaylist(playlistId: number, songId: number, updates: Partial<Song>): void {
    this.updateState(state => {
      const updateSongsInPlaylist = (playlist: Playlist | null): Playlist | null => {
        if (!playlist || playlist.id !== playlistId) return playlist;

        return {
          ...playlist,
          songs: playlist.songs.map(song =>
            song.id === songId ? { ...song, ...updates } : song
          )
        };
      };

      return {
        ...state,
        playlists: {
          ...state.playlists,
          list: state.playlists.list.map(pl => updateSongsInPlaylist(pl) || pl),
          selected: updateSongsInPlaylist(state.playlists.selected),
          default: updateSongsInPlaylist(state.playlists.default)
        }
      };
    });
  }

  // Actualizadores de TensorFlow
  setTensorflowInitialized(initialized: boolean): void {
    this.updateState(state => ({
      ...state,
      tensorflow: {
        ...state.tensorflow,
        initialized
      }
    }));
  }

  updateTensorflowMemory(memoryUsage: number): void {
    this.updateState(state => ({
      ...state,
      tensorflow: {
        ...state.tensorflow,
        memoryUsage
      }
    }));
  }

  setActiveModels(models: string[]): void {
    this.updateState(state => ({
      ...state,
      tensorflow: {
        ...state.tensorflow,
        activeModels: models
      }
    }));
  }

  // Actualizadores de procesamiento
  updateUploadPool(pool: Partial<ProcessingPool<Song>>): void {
    this.updateProcessingPool('upload', pool);
  }

  updateFeatureExtractionPool(pool: Partial<ProcessingPool<number>>): void {
    this.updateProcessingPool('featureExtraction', pool);
  }

  updateTrainingPool(pool: Partial<ProcessingPool<Song>>): void {
    this.updateProcessingPool('training', pool);
  }

  updateProgress(poolType: keyof AppState['processing'], progress: Partial<TaskProgress>): void {
    this.updateState(state => ({
      ...state,
      processing: {
        ...state.processing,
        [poolType]: {
          ...state.processing[poolType],
          progress: {
            ...state.processing[poolType].progress,
            ...progress
          }
        }
      }
    }));
  }

  // Actualizadores de UI
  setLoading(loading: boolean): void {
    this.updateState(state => ({
      ...state,
      ui: {
        ...state.ui,
        loading
      }
    }));
  }

  setCurrentView(view: string): void {
    this.updateState(state => ({
      ...state,
      ui: {
        ...state.ui,
        currentView: view
      }
    }));
  }

  setModalState(modalId: string, isOpen: boolean): void {
    this.updateState(state => ({
      ...state,
      ui: {
        ...state.ui,
        modalStates: {
          ...state.ui.modalStates,
          [modalId]: isOpen
        }
      }
    }));
  }

  // Reset de estado
  resetProcessingPools(): void {
    this.updateState(state => ({
      ...state,
      processing: {
        upload: this.createEmptyPool<Song>(),
        featureExtraction: this.createEmptyPool<number>(),
        training: this.createEmptyPool<Song>()
      }
    }));
  }

  resetState(): void {
    this.state$.next(this.initialState);
  }

  // Métodos privados de utilidad
  private updateState(updateFn: (state: AppState) => AppState): void {
    const currentState = this.state$.value;
    const newState = updateFn(currentState);
    this.state$.next(newState);
  }

  private updateProcessingPool<T>(
    poolType: keyof AppState['processing'],
    updates: Partial<ProcessingPool<T>>
  ): void {
    this.updateState(state => ({
      ...state,
      processing: {
        ...state.processing,
        [poolType]: {
          ...state.processing[poolType],
          ...updates
        }
      }
    }));
  }

  private createEmptyPool<T>(): ProcessingPool<T> {
    return {
      items: [],
      busy: false,
      progress: {
        current: 0,
        total: 0,
        status: 'idle'
      },
      iterator: null
    };
  }
}
