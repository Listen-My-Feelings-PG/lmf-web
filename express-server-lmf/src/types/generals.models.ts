export interface Song {
  id?: number;
  userScore?: number;
  fileName: string;
  fileSize: number;
  dataType: 'file' | 'link';
  metadata?: {
    title: string,
    artist: string,
    album: string,
    urlAlbumArt: string
  };
  tsGlobalScore?: number;
  tsTrainLevelLocal?: number;
  tsTrainLevelGlobal?: number;
  tsProbScore0?: number;
  tsProbScore1?: number;
  tsProbScore2?: number;
  tsProbScore3?: number;
  tsFeaturesFileName?: string;
  idPlaylist?: number;
}

export interface Playlist {
  id?: number;
  dateCreated?: Date;
  name: string;
  songs?: Song[];
  isDefault: boolean;
  modelId?: number;
}

export interface TensorFlowModel {
  id?: number;
  active?: boolean;
  trainedSongs: number;
  completedEpochs: number;
  createdDate?: Date;
  registeredDate?: Date;
  filename: string;
  loss: number;
  accuracy: number;
  version: number;
  isGlobal: boolean;
  learningRate: number;
  batchSize: number;
  numClasses: number;
  inputDim: number;
  architecture?: string;
}

export interface Calibration {
  id?: number;
  songId: number;
  modelId: number;
  interactionType: 'fit' | 'predict' | 'infer';
  interactionDate: Date;
  globalScore?: number;
  userScore: number;
  configEpochs: number;
  probScore0?: number;
  probScore1?: number;
  probScore2?: number;
  probScore3?: number;
  loss?: number;
  accuracy?: number;
  learningRate?: number;
  batchSize?: number;
}
