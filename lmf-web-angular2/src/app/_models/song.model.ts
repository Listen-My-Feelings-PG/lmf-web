export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public link: string,
    public userScore: number,
    public status: 'evaluated' | 'predict',
    public listIndex?: number,
    public uploadSuccess?: boolean,
    public errReason?: 'duplicated' | 'other',
    public id?: number
  ) { }
}