import { UserScore } from "./generals.interfaces";

export class Song {
  public id?: number;
  public fileName!: string;
  public userScore: UserScore = null;
  public tsGlobalScore: number | null = null;
  public tsTrainLevelLocal: number = 0;
  public tsTrainLevelGlobal: number = 0;
  public tsProbScore0: number | null = null;
  public tsProbScore1: number | null = null;
  public tsProbScore2: number | null = null;
  public tsProbScore3: number | null = null;
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
    public model: TsModel | null,
    public isDefault: boolean,
    public id?: number
  ) { }
}

export class TsModel {
  constructor(
    public id: number,
    public type: 'tensorflow',
    public global: boolean,
    public trainCount: number,
    public data: any
  ) { }
}