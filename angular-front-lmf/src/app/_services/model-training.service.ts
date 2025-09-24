import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, firstValueFrom } from 'rxjs';
import { TensorflowService, ModelTrainingProgress } from './tensorflow-v2.service';
import { AudioProcessingService } from './audio-processing.service';
import { HttpService } from './http.service';
import { StateService } from './state.service';
import { Song, Playlist, TaskProgress } from '../_models/types';

export interface TrainingTask {
  song: Song;
  status: 'pending' | 'extracting' | 'training' | 'completed' | 'error';
  progress?: number;
  error?: string;
  epochs?: number;
}

export interface TrainingSession {
  id: string;
  playlistId: number;
  tasks: TrainingTask[];
  startTime: Date;
  endTime?: Date;
  status: 'running' | 'completed' | 'error' | 'cancelled';
  totalEpochs: number;
  completedEpochs: number;
}

@Injectable({
  providedIn: 'root'
})
export class ModelTrainingService {
  private readonly currentSession$ = new BehaviorSubject<TrainingSession | null>(null);
  private readonly trainingHistory$ = new BehaviorSubject<TrainingSession[]>([]);

  readonly currentSession = this.currentSession$.asObservable();
  readonly trainingHistory = this.trainingHistory$.asObservable();

  constructor(
    private tensorflow: TensorflowService,
    private audioProcessing: AudioProcessingService,
    private http: HttpService,
    private state: StateService
  ) { }

  /**
   * Entrena el modelo con las canciones seleccionadas
   */
  async trainModel(
    songs: Song[],
    playlist: Playlist,
    globalPlaylist: Playlist,
    mode: 'single' | 'batch' = 'batch'
  ): Promise<void> {
    // Filtrar canciones listas para entrenar
    const validSongs = songs.filter(song =>
      song.userScore !== null &&
      song.storageStatus === 'uploaded' &&
      (song.tsStatus === null || song.tsStatus === 'error')
    );

    if (validSongs.length === 0) {
      throw new Error('No hay canciones válidas para entrenar');
    }

    // Crear sesión de entrenamiento
    const session = this.createTrainingSession(playlist.id!, validSongs);
    this.currentSession$.next(session);

    try {
      // Inicializar modelo si es necesario
      await this.tensorflow.createModel(false);

      // Procesar canciones
      for (const task of session.tasks) {
        await this.trainSingleSong(task, session);
      }

      // Guardar modelo actualizado
      await this.saveModelWeights(playlist, globalPlaylist);

      // Finalizar sesión
      session.status = 'completed';
      session.endTime = new Date();
      this.finalizeSession(session);

    } catch (error) {
      session.status = 'error';
      session.endTime = new Date();
      this.currentSession$.next(session);

      console.error('Error durante el entrenamiento:', error);
      throw error;
    }
  }

  /**
   * Entrena una sola canción
   */
  async trainSingleSongStandalone(song: Song, playlistId: number): Promise<void> {
    const session = this.createTrainingSession(playlistId, [song]);
    this.currentSession$.next(session);

    try {
      await this.trainSingleSong(session.tasks[0], session);
      await this.saveModelWeights(
        { id: playlistId } as Playlist,
        this.state.getCurrentState().playlists.default!
      );

      session.status = 'completed';
      session.endTime = new Date();
      this.finalizeSession(session);

    } catch (error) {
      session.status = 'error';
      session.endTime = new Date();
      this.currentSession$.next(session);
      throw error;
    }
  }

  /**
   * Cancela la sesión de entrenamiento actual
   */
  cancelCurrentSession(): void {
    const session = this.currentSession$.value;
    if (session && session.status === 'running') {
      session.status = 'cancelled';
      session.endTime = new Date();
      this.finalizeSession(session);
    }
  }

  /**
   * Obtiene el progreso general del entrenamiento actual
   */
  getCurrentProgress(): Observable<TaskProgress> {
    return new Observable(observer => {
      this.currentSession.subscribe(session => {
        if (!session) {
          observer.next({
            current: 0,
            total: 0,
            status: 'idle'
          });
          return;
        }

        const completed = session.tasks.filter(t =>
          t.status === 'completed' || t.status === 'error'
        ).length;

        observer.next({
          current: completed,
          total: session.tasks.length,
          status: session.status === 'running' ? 'processing' :
            session.status === 'completed' ? 'completed' : 'error',
          message: this.getSessionStatusMessage(session)
        });
      });
    });
  }

  /**
   * Limpia el historial de entrenamientos
   */
  clearHistory(): void {
    this.trainingHistory$.next([]);
  }

  // Métodos privados

  private createTrainingSession(playlistId: number, songs: Song[]): TrainingSession {
    const epochsConfig = this.tensorflow.getEpochsConfig();

    const tasks: TrainingTask[] = songs.map(song => {
      const epochs = song.userScore ? epochsConfig[`score${song.userScore}` as keyof typeof epochsConfig] : 10;
      return {
        song,
        status: 'pending',
        epochs
      };
    });

    const totalEpochs = tasks.reduce((sum, task) => sum + (task.epochs || 0), 0);

    return {
      id: this.generateSessionId(),
      playlistId,
      tasks,
      startTime: new Date(),
      status: 'running',
      totalEpochs,
      completedEpochs: 0
    };
  }

  private async trainSingleSong(task: TrainingTask, session: TrainingSession): Promise<void> {
    if (session.status === 'cancelled') {
      throw new Error('Entrenamiento cancelado');
    }

    try {
      // Marcar como en extracción
      task.status = 'extracting';
      this.updateSession(session);

      // Obtener características de audio
      const features = await this.audioProcessing.getSongFeatures(task.song.id!);

      // Personalizar espectrograma
      const customized = await this.audioProcessing.customizeSpectrogram(
        features.melSpectrogram,
        features.tempo,
        false
      );

      // Marcar como en entrenamiento
      task.status = 'training';
      this.updateSession(session);

      // Entrenar modelo
      await this.tensorflow.trainSong(
        false, // Usar modelo de playlist
        customized.resized,
        task.song.userScore!,
        task.epochs!,
        (progress: ModelTrainingProgress) => {
          task.progress = (progress.epoch / task.epochs!) * 100;
          session.completedEpochs = this.calculateCompletedEpochs(session);
          this.updateSession(session);
        }
      );

      // Actualizar estado en servidor
      await this.audioProcessing.updateSongStatus(task.song.id!, {
        tsStatus: 'trained',
        tsInitStatus: task.song.tsInitStatus
      });

      // Actualizar estado local
      task.song.tsStatus = 'trained';
      task.status = 'completed';
      task.progress = 100;

    } catch (error) {
      task.status = 'error';
      task.error = error instanceof Error ? error.message : 'Error desconocido';
      task.song.tsStatus = 'error';
      task.song.tsStatusErrReason = 'training-error';

      // Actualizar estado en servidor
      await this.audioProcessing.updateSongStatus(task.song.id!, {
        tsStatus: 'error',
        tsInitStatus: task.song.tsInitStatus
      });

      throw error;
    } finally {
      this.updateSession(session);
    }
  }

  private async saveModelWeights(playlist: Playlist, globalPlaylist: Playlist): Promise<void> {
    try {
      const weights = this.tensorflow.getModelWeights(false);
      if (!weights) {
        throw new Error('No se pudieron obtener los pesos del modelo');
      }

      const blob = new Blob([JSON.stringify(weights)], { type: 'application/json' });
      const file = new File([blob], 'model-weights.json', { type: 'application/json' });

      const formData = new FormData();
      formData.append('file', file);
      formData.append('data', JSON.stringify({
        playlist: {
          idSelected: playlist.id,
          idGlobal: globalPlaylist.id
        },
        models: {
          idSelected: playlist.model?.id,
          idGlobal: globalPlaylist.model?.id
        }
      }));

      await firstValueFrom(
        this.http.upload('upload/model-weights', formData)
      );

    } catch (error) {
      console.error('Error al guardar pesos del modelo:', error);
      throw error;
    }
  }

  private updateSession(session: TrainingSession): void {
    this.currentSession$.next({ ...session });
  }

  private finalizeSession(session: TrainingSession): void {
    // Agregar al historial
    const history = this.trainingHistory$.value;
    this.trainingHistory$.next([...history, session]);

    // Limpiar sesión actual
    this.currentSession$.next(null);

    // Actualizar estado global
    this.state.updateProgress('training', {
      status: session.status === 'completed' ? 'completed' : 'error',
      current: session.tasks.length,
      total: session.tasks.length
    });
  }

  private calculateCompletedEpochs(session: TrainingSession): number {
    return session.tasks.reduce((sum, task) => {
      if (task.status === 'completed') {
        return sum + (task.epochs || 0);
      } else if (task.status === 'training' && task.progress) {
        return sum + Math.floor((task.epochs || 0) * (task.progress / 100));
      }
      return sum;
    }, 0);
  }

  private generateSessionId(): string {
    return `session_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  private getSessionStatusMessage(session: TrainingSession): string {
    const completedTasks = session.tasks.filter(t => t.status === 'completed').length;
    const totalTasks = session.tasks.length;

    switch (session.status) {
      case 'running':
        return `Entrenando canciones: ${completedTasks}/${totalTasks}`;
      case 'completed':
        return 'Entrenamiento completado exitosamente';
      case 'error':
        return 'Error durante el entrenamiento';
      case 'cancelled':
        return 'Entrenamiento cancelado';
      default:
        return 'Estado desconocido';
    }
  }
}
