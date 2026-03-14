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
  userScore: UserScore;
  tsPredictionGlobal: number | null;
  tsPredictionLocal: number | null;
  epochsTrainedGlobal: number;
  epochsTrainedLocal: number;
  accuracyGlobal: number | null;
  accuracyLocal: number | null;
  learningRateGlobal: number | null;
  learningRateLocal: number | null;
}

export type TrainingModality = 'clean' | 'infer' | 'none';

export type UserScore = 0 | 1 | 2 | 3 | null;

