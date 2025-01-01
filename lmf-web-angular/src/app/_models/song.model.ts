export class Song {
  constructor(
    public name: string,
    public type: 'file' | 'link',
    public file: File | null,
    public link: string,
    public score: number
  ) { }
}