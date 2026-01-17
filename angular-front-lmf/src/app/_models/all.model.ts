import { Decimal } from 'decimal.js';

export class Song {
  public id?: number;
  public name!: string;
  public type!: 'file' | 'link';
  public file: File | null = null;
  public userScore: number | null = null;
  public userRating: number | null = null;
  public tsPrediction: number | null = null;
  public prediction: number | null = null;
  public storageStatus: 'local' | 'uploading' | 'uploaded' | 'downloading' | 'downloaded' | 'updated' | 'error' = 'local';
  public tsStatus: 'training' | 'trained' | 'predicting' | 'predicted' | 'retrained' | 'error' | null = null;
  public tsInitStatus: 'train' | 'predict' | 'retrain' = 'train';
  public storageStatusErrReason?: 'duplicated' | 'other' | null;
  public tsFeaturesDimensions?: number | 'error' | null;
  public tsStatusErrReason?: 'features-notfound' | 'training-error' | 'customize-error' | 'other';
  public featuresFile?: string | null;
  public fileSize?: number;
  public audioUrl?: string;
  public playlistId?: number;

  constructor(data: Partial<Song> = {}) {
    Object.assign(this, data);
    this.userRating = this.userRating || this.userScore;
    this.prediction = this.prediction || this.tsPrediction;
  }
}

export class Playlist {
  constructor(
    public name: string,
    public songs: Array<Song>,
    public songsForPredict: Array<Song>,
    public model: TsModel | null,
    public isGlobal: boolean,
    public id?: number,
    public songCount?: number
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

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}

export type TsModelJSON = Array<Array<Array<Decimal>>>