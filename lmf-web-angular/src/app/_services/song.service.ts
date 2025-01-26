import { Injectable } from '@angular/core';
import { Song } from '../_models/all.model';
import { HttpService } from './http.service';

export interface SpectrogramSpecs {
  maxValue: number,
  firstIndex: number,
  lastIndex: number
  resized: Array<Array<number>>,
  interval: number
}

@Injectable({
  providedIn: 'root'
})
export class SongService {
  private pools: {
    idSongs: Array<number>,
    songs: Array<Song>
  }
  private iterators: {
    idSongs: any,
    songs: any
  }
  busyFlags: {
    idSongs: boolean,
    songs: boolean
  }
  constructor(
    private http: HttpService
  ) {
    this.pools = {
      idSongs: [],
      songs: []
    }
    this.iterators = {
      idSongs: null,
      songs: null
    }
    this.busyFlags = {
      idSongs: false,
      songs: false
    }
  }

  customizeSpectrogram(mel_spectrogram: Array<Array<number>>, tempo: number, extendTempo: boolean): Promise<SpectrogramSpecs> {
    return new Promise((resolve) => {
      let control: { firstIndex: number, lastIndex: number, maxValue: number } = {
        firstIndex: -1, lastIndex: 20000, maxValue: 0
      };
      mel_spectrogram.forEach((row: any[], y: any) => {
        row.forEach((column, x) => {
          if (column > 0 && control.firstIndex == -1)
            control.firstIndex = x;
          else if (column > 0 && control.firstIndex > x)
            control.firstIndex = x;

          if (row[19999 - x] > 0 && control.lastIndex == 20000)
            control.lastIndex = 19999 - x;
          else if (row[19999 - x] > 0 && control.lastIndex < (19999 - x))
            control.lastIndex = 19999 - x;

          if (column > control.maxValue)
            control.maxValue = column;
        })
      });

      let interval = Math.trunc((control.lastIndex - control.firstIndex) / tempo);
      let resized = mel_spectrogram.map((obj) => {
        let row: Array<any> = [];

        for (let i = 0; i < 20000; i++) {
          row.push(obj[i]);
        }
        return row;
      });
      resized.push([]);
      for (let i = 0; i < 20000; i++) {
        if ((!extendTempo && i < control.lastIndex) || extendTempo)
          resized[128].push(i % interval == 0 ? 1 : 0);
        else
          resized[128].push(0);

      }

      resolve({
        resized,
        maxValue: control.maxValue,
        firstIndex: control.firstIndex,
        lastIndex: control.lastIndex,
        interval
      });
    });
  }

  addToPoolSongs(song: Song) {
    this.pools.songs.push(song);
  }

  uploadSongsToServer(listForFill: Array<Song>) {
    let that = this;
    return new Promise((resolve, reject) => {
      if (!this.busyFlags.songs) {
        this.iterators.songs = this.pools.songs[Symbol.iterator]();
        this.busyFlags.songs = true;
        trigger();
      } else
        reject('Pool is busy');

      function trigger() {
        let item = that.iterators.songs.next();
        if (item.done)
          return checkPool(item);
        item.value.userScore = 0;
        item.value.tsPrediction = null;
        that.http.post('upload/file', item.value, true).subscribe({
          next: (data: any) => {
            let listSong = listForFill[item.value.listIndex];
            listSong.storageStatus = 'uploaded';
            listSong.id = data.row.id;
            checkPool(item);
          },
          error: (error: { status: number; }) => {
            let listSong = listForFill[item.value.listIndex];
            listSong.storageStatus = 'error';
            listSong.storageStatusErrReason = error.status == 403 ? 'duplicated' : 'other';
            checkPool(item);
          }
        });
      }

      function checkPool(item: any) {
        if (!item.done)
          trigger();
        else {
          that.pools.songs = [];
          that.busyFlags.songs = false;
          resolve(listForFill);
        }
      }

    })
  }

  stopUploadSongsToServer() {
    this.pools.songs = [];
    this.iterators.songs = this.pools.songs[Symbol.iterator]();
    this.busyFlags.songs = false;
  }
}
