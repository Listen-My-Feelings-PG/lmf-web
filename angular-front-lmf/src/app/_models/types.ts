// Interfaces y tipos centralizados para el sistema
export interface AudioFeatures {
  melSpectrogram: number[][];
  tempo: number;
  spectrogramDimensions: {
    width: number;
    height: number;
  };
}

export interface Song {
  id?: number;
  name: string;
  type: 'file' | 'link';
  file: File | null;
  userScore: number | null;
  tsPrediction: number | null;
  storageStatus: SongStorageStatus;
  tsStatus: SongTsStatus | null;
  tsInitStatus: SongTsInitStatus;
  storageStatusErrReason?: SongStorageErrorReason | null;
  tsFeaturesDimensions?: number | 'error' | null;
  tsStatusErrReason?: SongTsErrorReason;
  fileSize?: number;
  fileName?: string;
}

export type SongStorageStatus = 'local' | 'uploading' | 'uploaded' | 'downloading' | 'downloaded' | 'updated' | 'error';
export type SongTsStatus = 'training' | 'trained' | 'predicting' | 'predicted' | 'retrained' | 'error';
export type SongTsInitStatus = 'train' | 'predict' | 'retrain';
export type SongStorageErrorReason = 'duplicated' | 'other';
export type SongTsErrorReason = 'features-notfound' | 'training-error' | 'customize-error' | 'other';

export interface Playlist {
  id?: number;
  name: string;
  songs: Song[];
  songsForPredict: Song[];
  model: TsModel | null;
  isGlobal: boolean;
  active?: boolean;
  creationDate?: string;
}

export interface TsModel {
  id: number;
  type: 'tensorflow';
  global: boolean;
  trainCount: number;
  data: any;
  fileName?: string;
  description?: string;
  creationDate?: string;
  active?: boolean;
}

export interface ModelConfig {
  epochs: {
    score1: number;
    score2: number;
    score3: number;
  };
  architecture: {
    inputShape: [number, number];
    layers: LayerConfig[];
  };
  compilation: {
    optimizer: string;
    loss: string;
    metrics: string[];
  };
}

export interface LayerConfig {
  type: 'dense' | 'flatten' | 'conv2d' | 'maxPooling2d';
  units?: number;
  activation?: string;
  inputShape?: number[];
  filters?: number;
  kernelSize?: number[];
  poolSize?: number[];
}

export interface SpectrogramSpecs {
  maxValue: number;
  firstIndex: number;
  lastIndex: number;
  resized: number[][];
  interval: number;
}

export interface TaskProgress {
  current: number;
  total: number;
  status: 'idle' | 'processing' | 'completed' | 'error';
  message?: string;
  error?: string;
}

export interface ProcessingPool<T> {
  items: T[];
  busy: boolean;
  progress: TaskProgress;
  iterator: Iterator<T> | null;
}

export interface ApiResponse<T = any> {
  message: string;
  data?: T;
  error?: string;
  status: 'success' | 'error';
}

export interface ToastProperties {
  key: 'default' | 'custom' | null;
  severity: 'success' | 'info' | 'warn' | 'error';
  summary: string;
  detail: string;
  life?: number;
  data?: any;
}

export interface AppState {
  playlists: {
    list: Playlist[];
    selected: Playlist | null;
    default: Playlist | null;
    loaded: boolean;
  };
  tensorflow: {
    initialized: boolean;
    memoryUsage: number;
    activeModels: string[];
  };
  processing: {
    upload: ProcessingPool<Song>;
    featureExtraction: ProcessingPool<number>;
    training: ProcessingPool<Song>;
  };
  ui: {
    loading: boolean;
    currentView: string;
    modalStates: Record<string, boolean>;
  };
}

// Eventos del sistema
export interface SystemEvent {
  type: 'song-uploaded' | 'features-extracted' | 'model-trained' | 'prediction-completed' | 'error-occurred';
  payload: any;
  timestamp: Date;
}

// Configuración de la aplicación
export interface AppConfig {
  api: {
    baseUrl: string;
    timeout: number;
  };
  tensorflow: {
    backend: 'cpu' | 'webgl';
    memoryLimit: number;
  };
  audio: {
    maxFileSize: number;
    supportedFormats: string[];
    sampleRate: number;
  };
  ui: {
    pageSize: number;
    debounceTime: number;
    toastDuration: number;
  };
}
