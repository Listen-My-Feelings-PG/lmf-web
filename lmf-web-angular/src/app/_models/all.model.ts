export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public userScore: number | null, //Dentro de cualquier playlist, se aceptará una calificación de 0
    public tsPrediction: number | null,
    public storageStatus: 'local' | 'uploading' | 'uploaded' | 'downloading' | 'downloaded' | 'error', //Sólo se manipulará en el frontend
    public tsStatus: 'training' | 'trained' | 'predicting' | 'predicted' | 'retrained' | 'error' | null, //Sólo se manipulará en el frontend
    public tsInitStatus: 'train' | 'predict' | 'retrain', //Sólo se manipulará en el frontend
    public id?: number,
    public storageStatusErrReason?: 'duplicated' | 'other' | null, //Sólo se manipulará en el frontend
    public tsFeaturesDimensions?: number | 'error' | null,
    public tsFeaturesErrReason?: 'overload' | 'other' | null //Sólo se manipulará en el frontend
  ) { }
}

export class Playlist {
  constructor(
    public name: string,
    public songs: Array<Song>,
    public songsForPredict: Array<Song>,
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
    public trainCount: number
  ) { }
}

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}