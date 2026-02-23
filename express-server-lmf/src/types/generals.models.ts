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
  tsScore?: number;
  tsTrainLevelLocal?: number;
  tsTrainLevelGlobal?: number
}

export interface Playlist {
  id?: number;
  dateCreated?: Date;
  name: string;
  songs?: Song[];
  isGlobal: boolean;
}
