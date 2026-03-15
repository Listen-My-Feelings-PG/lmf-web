import { Song } from "./generals.models";

export interface Playlist {
  id: number;
  name: string,
  isDefault: boolean,
  modelId?: number
}

export interface HttpResponseSuccess {
  sucess: true,
  data: any,
  message: string
  timestamp: string
}

export interface GlobalPlaylistSetup {
  playlists: Array<Playlist>,
  songList: Array<Song>,
  selected: Playlist | null,
  lockRate: boolean,
  songPlaying?: Song,
  initialized?: boolean
}

export interface Calibration {
  id?: number;
  songId: number;
  modelId: number;
  prediction?: {
    prediction: number;
    accuracy: number;
    idLastFit: number | null;
  },
  training?: {
    isFineTuning: boolean;
    epochs: number;
    loss: number;
    batchSize: number;
    validationSplit: number;
    mae: number;
  }
  interactionDate: Date;
  userScore?: number;
}

export type TrainingModality = 'clean' | 'infer' | 'none';

export type UserScore = 0 | 1 | 2 | 3 | null;

