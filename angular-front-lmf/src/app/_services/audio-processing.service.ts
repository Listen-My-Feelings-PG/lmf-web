import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, Subject, firstValueFrom } from 'rxjs';
import { HttpService } from './http.service';
import { StateService } from './state.service';
import { Song, SpectrogramSpecs, AudioFeatures, TaskProgress } from '../_models/types';

export interface FeatureExtractionTask {
  songId: number;
  status: 'pending' | 'processing' | 'completed' | 'error';
  progress?: number;
  error?: string;
}

export interface UploadTask {
  song: Song;
  playlistId: number;
  globalPlaylistId: number;
  status: 'pending' | 'uploading' | 'completed' | 'error';
  progress?: number;
  error?: string;
}

@Injectable({
  providedIn: 'root'
})
export class AudioProcessingService {
  private readonly uploadTasks$ = new BehaviorSubject<UploadTask[]>([]);
  private readonly featureExtractionTasks$ = new BehaviorSubject<FeatureExtractionTask[]>([]);
  private readonly spectrogramCache = new Map<number, SpectrogramSpecs>();

  readonly uploadTasks = this.uploadTasks$.asObservable();
  readonly featureExtractionTasks = this.featureExtractionTasks$.asObservable();

  constructor(
    private http: HttpService,
    private state: StateService
  ) { }

  /**
   * Procesa la subida de múltiples canciones de forma optimizada
   */
  async uploadSongs(
    songs: Song[],
    playlistId: number,
    globalPlaylistId: number
  ): Promise<void> {
    const tasks: UploadTask[] = songs.map(song => ({
      song,
      playlistId,
      globalPlaylistId,
      status: 'pending'
    }));

    this.uploadTasks$.next(tasks);
    this.state.updateProgress('upload', {
      total: tasks.length,
      current: 0,
      status: 'processing'
    });

    try {
      const concurrencyLimit = 3; // Límite de subidas simultáneas
      await this.processConcurrentTasks(tasks, this.uploadSingleSong.bind(this), concurrencyLimit);

      this.state.updateProgress('upload', { status: 'completed' });
    } catch (error) {
      console.error('Error durante la subida de canciones:', error);
      this.state.updateProgress('upload', {
        status: 'error',
        message: 'Error al subir algunas canciones'
      });
    }
  }

  /**
   * Extrae características de múltiples canciones
   */
  async extractFeatures(songIds: number[]): Promise<AudioFeatures[]> {
    const tasks: FeatureExtractionTask[] = songIds.map(id => ({
      songId: id,
      status: 'pending'
    }));

    this.featureExtractionTasks$.next(tasks);
    this.state.updateProgress('featureExtraction', {
      total: tasks.length,
      current: 0,
      status: 'processing'
    });

    const results: AudioFeatures[] = [];

    try {
      for (const task of tasks) {
        try {
          const features = await this.extractSingleSongFeatures(task.songId);
          results.push(features);

          task.status = 'completed';
          this.updateFeatureExtractionProgress();
        } catch (error) {
          task.status = 'error';
          task.error = error instanceof Error ? error.message : 'Error desconocido';
          console.error(`Error extrayendo características de canción ${task.songId}:`, error);
        }
      }

      this.state.updateProgress('featureExtraction', { status: 'completed' });
      return results;
    } catch (error) {
      this.state.updateProgress('featureExtraction', {
        status: 'error',
        message: 'Error en la extracción de características'
      });
      throw error;
    }
  }

  /**
   * Personaliza un espectrograma para el entrenamiento
   */
  async customizeSpectrogram(
    melSpectrogram: number[][],
    tempo: number,
    extendTempo: boolean = false
  ): Promise<SpectrogramSpecs> {
    return new Promise((resolve, reject) => {
      try {
        const control = {
          firstIndex: -1,
          lastIndex: 20000,
          maxValue: 0
        };

        // Analizar espectrograma para encontrar bounds y valor máximo
        melSpectrogram.forEach((row) => {
          row.forEach((value, index) => {
            if (value > 0 && control.firstIndex === -1) {
              control.firstIndex = index;
            }

            if (value > 0 && control.firstIndex > index) {
              control.firstIndex = index;
            }

            const reverseIndex = 19999 - index;
            if (row[reverseIndex] > 0 && control.lastIndex === 20000) {
              control.lastIndex = reverseIndex;
            } else if (row[reverseIndex] > 0 && control.lastIndex < reverseIndex) {
              control.lastIndex = reverseIndex;
            }

            if (value > control.maxValue) {
              control.maxValue = value;
            }
          });
        });

        // Calcular intervalo basado en tempo
        const interval = Math.trunc((control.lastIndex - control.firstIndex) / tempo);

        // Crear espectrograma redimensionado
        const resized = melSpectrogram.map(row => [...row]);

        // Agregar fila de tempo
        const tempoRow: number[] = [];
        for (let i = 0; i < 20000; i++) {
          if ((!extendTempo && i < control.lastIndex) || extendTempo) {
            tempoRow.push(i % interval === 0 ? 1 : 0);
          } else {
            tempoRow.push(0);
          }
        }
        resized.push(tempoRow);

        const result: SpectrogramSpecs = {
          resized,
          maxValue: control.maxValue,
          firstIndex: control.firstIndex,
          lastIndex: control.lastIndex,
          interval
        };

        resolve(result);
      } catch (error) {
        console.error('Error al personalizar espectrograma:', error);
        reject(error);
      }
    });
  }

  /**
   * Obtiene características de una canción con caché
   */
  async getSongFeatures(songId: number, useCache: boolean = true): Promise<AudioFeatures> {
    if (useCache && this.spectrogramCache.has(songId)) {
      const cached = this.spectrogramCache.get(songId)!;
      return this.spectrogramToAudioFeatures(cached);
    }

    const features = await this.extractSingleSongFeatures(songId);

    if (useCache) {
      // Convertir a SpectrogramSpecs para caché
      const specs = await this.customizeSpectrogram(features.melSpectrogram, features.tempo);
      this.spectrogramCache.set(songId, specs);
    }

    return features;
  }

  /**
   * Actualiza el estado de una canción en el servidor
   */
  async updateSongStatus(
    songId: number,
    updates: {
      tsStatus?: Song['tsStatus'];
      tsInitStatus?: Song['tsInitStatus'];
      storageStatus?: Song['storageStatus'];
      tsPrediction?: number | null;
      userScore?: number | null;
    }
  ): Promise<void> {
    try {
      await firstValueFrom(
        this.http.post('songs/update-status', {
          idSong: songId,
          ...updates
        }, true)
      );
    } catch (error) {
      console.error('Error al actualizar estado de canción:', error);
      throw error;
    }
  }

  /**
   * Limpia el caché de espectrogramas
   */
  clearCache(): void {
    this.spectrogramCache.clear();
  }

  /**
   * Obtiene estadísticas del caché
   */
  getCacheStats(): { size: number; keys: number[] } {
    return {
      size: this.spectrogramCache.size,
      keys: Array.from(this.spectrogramCache.keys())
    };
  }

  // Métodos privados

  private async uploadSingleSong(task: UploadTask): Promise<void> {
    task.status = 'uploading';
    this.updateUploadTasks();

    try {
      const formData = new FormData();
      if (task.song.file) {
        formData.append('file', task.song.file);
      }
      formData.append('name', task.song.name);
      formData.append('tsInitStatus', task.song.tsInitStatus);
      formData.append('idPlaylist', task.playlistId.toString());
      formData.append('idPlaylistGlobal', task.globalPlaylistId.toString());

      const response = await firstValueFrom(
        this.http.upload('upload/song', formData)
      );

      task.status = 'completed';
      task.song.id = response.data?.sRow?.id;
      task.song.storageStatus = 'uploaded';
    } catch (error) {
      task.status = 'error';
      task.error = error instanceof Error ? error.message : 'Error al subir canción';
      task.song.storageStatus = 'error';

      if (error && typeof error === 'object' && 'status' in error) {
        task.song.storageStatusErrReason = error.status === 403 ? 'duplicated' : 'other';
      }

      throw error;
    } finally {
      this.updateUploadTasks();
    }
  }

  private async extractSingleSongFeatures(songId: number): Promise<AudioFeatures> {
    try {
      const response = await firstValueFrom(
        this.http.get(`download/ts-features?value=${songId}`)
      );

      const data = response.data || response; // Soporte para ambos formatos de respuesta

      return {
        melSpectrogram: data.mel_spectrogram,
        tempo: data.tempo,
        spectrogramDimensions: {
          width: data.mel_spectrogram[0]?.length || 0,
          height: data.mel_spectrogram.length || 0
        }
      };
    } catch (error) {
      console.error(`Error extrayendo características de canción ${songId}:`, error);
      throw error;
    }
  }

  private async processConcurrentTasks<T>(
    tasks: T[],
    processor: (task: T) => Promise<void>,
    concurrencyLimit: number
  ): Promise<void> {
    const executing: Promise<void>[] = [];

    for (const task of tasks) {
      const promise = processor(task).finally(() => {
        const index = executing.indexOf(promise);
        if (index > -1) {
          executing.splice(index, 1);
        }
      });

      executing.push(promise);

      if (executing.length >= concurrencyLimit) {
        await Promise.race(executing);
      }
    }

    await Promise.all(executing);
  }

  private updateUploadTasks(): void {
    const tasks = this.uploadTasks$.value;
    this.uploadTasks$.next([...tasks]);

    const completed = tasks.filter(t => t.status === 'completed' || t.status === 'error').length;
    this.state.updateProgress('upload', { current: completed });
  }

  private updateFeatureExtractionProgress(): void {
    const tasks = this.featureExtractionTasks$.value;
    const completed = tasks.filter(t => t.status === 'completed' || t.status === 'error').length;
    this.state.updateProgress('featureExtraction', { current: completed });
  }

  private spectrogramToAudioFeatures(specs: SpectrogramSpecs): AudioFeatures {
    return {
      melSpectrogram: specs.resized,
      tempo: specs.interval, // Aproximación basada en el intervalo
      spectrogramDimensions: {
        width: specs.resized[0]?.length || 0,
        height: specs.resized.length || 0
      }
    };
  }
}
