export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public link: string,
    public userScore: number | null,
    public tsScore: number | null,
    public statusStorage: 'local' | 'uploaded' | 'uploading' | 'error',
    public id?: number,
    public listIndex?: number | null,
    public statusErrReason?: 'duplicated' | 'other' | null,
    public tsFeaturesDimensions?: number | 'error',
    public tsFeaturesErrReason?: 'overload' | 'other'
  ) { }
}

export interface LibrosaTsFeatures {
  mel_spectrogram: Array<Array<number>>,
  tempo: number
}