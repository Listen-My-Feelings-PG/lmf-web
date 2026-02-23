import { Song } from "./generals.models";

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}

export interface Playlist {
  id: number;
  name: string,
  isGlobal: boolean,
  songs: Array<Song>
}

