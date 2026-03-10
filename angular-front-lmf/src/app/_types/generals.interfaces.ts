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

export type UserScore = 0 | 1 | 2 | 3 | null;

