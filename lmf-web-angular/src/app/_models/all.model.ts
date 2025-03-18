export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public userScore: number | null, //Dentro de cualquier playlist, se aceptará una calificación de 0
    public tsPrediction: number | null,
    public storageStatus: 'local' | 'uploading' | 'uploaded' | 'downloading' | 'downloaded' | 'updated' | 'error',
    public tsStatus: 'training' | 'trained' | 'predicting' | 'predicted' | 'retrained' | 'error' | null,
    public tsInitStatus: 'train' | 'predict' | 'retrain',
    public id?: number,
    public storageStatusErrReason?: 'duplicated' | 'other' | null,
    public tsFeaturesDimensions?: number | 'error' | null,
    public tsStatusErrReason?: 'features-notfound' | 'training-error' | 'customize-error' | 'other'
  ) { }
}

export class Playlist {
  constructor(
    public name: string,
    public songs: Array<Song>,
    public songsForPredict: Array<Song>,
    public model: TsModel | null,
    public isGlobal: boolean,
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

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}