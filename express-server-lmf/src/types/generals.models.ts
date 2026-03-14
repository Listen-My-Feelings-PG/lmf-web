import { UserScore } from "./generals.types";

export class Song {
  public id?: number;
  public fileName!: string;
  public userScore: UserScore = null;
  public tsPrediction: number | null = null;
  public tsTrainLevelLocal: number = 0;
  public tsTrainLevelGlobal: number = 0;
  public tsFeaturesFileName: string | null = null;
  public fileSize?: number;
  public dataType?: 'file';
  public idPlaylist?: number;
  public accuracy?: number | null;
  public metadata?: {
    title: string,
    artist: string,
    album: string,
    urlAlbumArt: string
  };
  public stats?: Array<Calibration>;
  constructor(data: Partial<Song> = {}) {
    Object.assign(this, data);
  }
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
  interactionType: 'fit' | 'predict';
  interactionDate: Date;
  globalScore?: number;
  userScore: number;
  configEpochs: number;
  loss?: number;
  accuracy?: number | null;
  learningRate?: number;
  batchSize?: number;
}
