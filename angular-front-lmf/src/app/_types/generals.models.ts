import { UserScore } from "./generals.interfaces";

export class Song {
  public id?: number;
  public fileName!: string;
  public userScore: UserScore = null;
  public tsPrediction: number | null = null;
  public tsTrainLevelLocal: number = 0;
  public tsTrainLevelGlobal: number = 0;
  public tsFeaturesFileName: string | null = null;
  public idPlaylist?: number;
  public accuracy?: number | null;
  public metadata?: {
    title: string,
    artist: string,
    album: string,
    urlAlbumArt: string
  };
  constructor(data: Partial<Song> = {}) {
    Object.assign(this, data);
  }
}

export class Playlist {
  constructor(
    public name: string,
    public songs: Array<Song>,
    public model: TensorFlowModel | null,
    public isDefault: boolean,
    public id?: number
  ) { }
}

export class TensorFlowModel {
  constructor(
    public id: number,
    public type: 'tensorflow',
    public global: boolean,
    public trainCount: number,
    public data: any
  ) { }
}