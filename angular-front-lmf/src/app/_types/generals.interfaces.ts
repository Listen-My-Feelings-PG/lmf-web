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
  songsInPlaylistSelected: Array<Song>,
  playlistSelected: Playlist | null,
  lockRate: boolean,
  songPlaying?: Song,
  initialized?: boolean
}

export interface Calibration {
  id?: number;
  songId: number;
  modelId: number;
  prediction?: {
    score: number;
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

