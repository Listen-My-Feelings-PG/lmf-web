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
    idSongsForFeatures: Array<number>,
    songsForUpload: Array<Song>
  }
  private iterators: {
    idSongsForFeatures: any,
    songsForUpload: any
  }
  busyFlags: {
    idSongsForFeatures: boolean,
    songsForUpload: boolean
  }
  constructor(
    private http: HttpService
  ) {
    this.pools = {
      idSongsForFeatures: [],
      songsForUpload: []
    }
    this.iterators = {
      idSongsForFeatures: null,
      songsForUpload: null
    }
    this.busyFlags = {
      idSongsForFeatures: false,
      songsForUpload: false
    }
  }

  extractFeaturesFromSongs(idSongs: Array<number>, taskCallback: Function): void {
    const that = this;
    this.pools.idSongsForFeatures = Object.assign([], idSongs);
    if (!this.busyFlags.idSongsForFeatures) {
      this.iterators.idSongsForFeatures = this.pools.idSongsForFeatures[Symbol.iterator]();
      this.busyFlags.idSongsForFeatures = true;
      trigger();
    } else
      taskCallback(true, 'Pool is busy');

    function trigger() {
      let item = that.iterators.idSongsForFeatures.next();
      if (item.done)
        return checkPool(item);
      that.http.get(`download/tsfeatures?value=${item.value}`).subscribe({
        next: (data: any) => taskCallback(
          false, data, false, item.value, () => checkPool(item)
        ),
        error: (error: any) => taskCallback(
          true, `Error al extraer características: ${JSON.stringify(error)}`,
          false, item.value, () => checkPool(item)
        )
      });
    }

    function checkPool(item: any) {
      if (!item.done)
        trigger();
      else {
        that.pools.idSongsForFeatures = [];
        that.busyFlags.idSongsForFeatures = false;
        taskCallback(false, 'Pool finalizado', true, () => { return; });
      }
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

  addToPoolSongsForUpload(song: Song) {
    this.pools.songsForUpload.push(song);
  }

  uploadSongsToServer(taskCallback: Function): void {
    let that = this;
    if (!this.busyFlags.songsForUpload) {
      this.iterators.songsForUpload = this.pools.songsForUpload[Symbol.iterator]();
      this.busyFlags.songsForUpload = true;
      trigger();
    } else if (this.pools.songsForUpload.length == 0)
      return taskCallback(true, 'Pool is empty');
    else
      return taskCallback(true, 'Pool is busy');

    function trigger() {
      let item = that.iterators.songsForUpload.next();
      if (item.done)
        return checkPool(item);
      item.value.userScore = 0;
      item.value.tsPrediction = null;
      that.http.post('upload/file', item.value).subscribe({
        next: (data: any) => {
          taskCallback(false, { completed: false, listIndex: item.value.listIndex, storageStatus: 'uploaded', id: data.row.id });
          checkPool(item);
        },
        error: (error: { status: number; }) => {
          taskCallback(true, { completed: false, listIndex: item.value.listIndex, storageStatus: 'error', storageStatusErrReason: error.status == 403 ? 'duplicated' : 'other' });
          checkPool(item);
        }
      });
    }

    function checkPool(item: any) {
      if (!item.done)
        trigger();
      else {
        that.pools.songsForUpload = [];
        that.busyFlags.songsForUpload = false;
        taskCallback(false, { completed: true });
      }
    }

  }

  stopUploadSongsToServer() {
    this.pools.songsForUpload = [];
    this.iterators.songsForUpload = this.pools.songsForUpload[Symbol.iterator]();
    this.busyFlags.songsForUpload = false;
  }
}
