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
