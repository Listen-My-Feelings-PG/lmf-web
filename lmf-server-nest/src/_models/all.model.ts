export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public userScore: number | null,
    public tsPrediction: number | null,
    public storageStatus: 'local' | 'uploaded' | 'error',
    public tsStatus: 'trained' | 'predicted' | 'retrained' | 'error' | null,
    public tsInitStatus: 'train' | 'predict' | 'retrain',
    public listIndex: number | null,
    public id?: number,
    public storageStatusErrReason?: 'duplicated' | 'other' | null,
    public tsFeaturesDimensions?: number | 'error',
    public tsFeaturesErrReason?: 'overload' | 'other'
  ) { }
}

export class Playlist {
  constructor(
    public name: string,
    public songs: Array<Song>,
    public model: Model,
    public isDefault: boolean,
    public id?: number
  ) { }
}

export class Model {
  constructor(
    public id: number,
    public global: boolean,
    public trainCount: number
  ) { }
}

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}