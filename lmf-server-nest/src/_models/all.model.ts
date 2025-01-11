export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public link: string,
    public userScore: number | null,
    public tsScore: number | null,
    public status: 'local' | 'uploaded' | 'uploading' | 'error',
    public id?: number,
    public errReason?: 'duplicated' | 'other',
    public listIndex?: number,
  ) { }
}

