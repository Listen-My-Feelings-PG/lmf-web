import { Song } from "./generals.models";

export interface Playlist {
  id: number;
  name: string,
  isGlobal: boolean,
  songs: Array<Song>
}

export interface HttpResponseSuccess {
  sucess: true,
  data: any,
  message: string
  timestamp: string
}

