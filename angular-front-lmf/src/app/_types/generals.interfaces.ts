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

