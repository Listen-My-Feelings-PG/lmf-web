import { Song } from "./generals.models";

export interface Playlist {
  id: number;
  name: string,
  isDefault: boolean,
  songs: Array<Song>
}

export interface HttpResponseSuccess {
  sucess: true,
  data: any,
  message: string
  timestamp: string
}

export interface PlaylistSetup {
  list: Array<Playlist>,
  selected: Playlist | null,
  songPlaying?: Song,
  initialized?: boolean
}

export type UserScore = 0 | 1 | 2 | 3 | null;

