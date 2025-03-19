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
  private indexes: {
    idSongsForFeatures: number,
    songsForUpload: number
  }
  busyFlags: {
    idSongsForFeatures: boolean,
    songsForUpload: boolean
  }

  constructor(
    private http: HttpService
  ) {
    this.indexes = {
      idSongsForFeatures: -1,
      songsForUpload: -1
    }
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

  extractFeaturesFromSongs(
    idSongs: Array<number>,
    taskCallback: (
      error: boolean,
      data: any,
      done: boolean,
      idSong?: number,
      Callback?: Function
    ) => void
  ): void {
    const that = this;
    this.pools.idSongsForFeatures = Object.assign([], idSongs);
    if (!this.busyFlags.idSongsForFeatures) { //Bloqueo del método hasta que termine el pool actual
      this.iterators.idSongsForFeatures = this.pools.idSongsForFeatures[Symbol.iterator]();
      this.busyFlags.idSongsForFeatures = true;
      trigger(); //Se dispara la función get de extracción
    } else
      taskCallback(true, 'Pool is busy', true);

    function trigger() {
      const item = that.iterators.idSongsForFeatures.next();
      if (item.done)
        return checkPool(item);
      that.http.get(`download/tsfeatures?value=${item.value}`).subscribe({
        next: (res: any) => taskCallback(
          false, res, //Características planas extraidas
          false, item.value, //Valor actual: id de la canción
          () => checkPool(item) //Callback de activación: Se activa en la función "listener" que maneja el componente
        ),
        error: (error: any) => taskCallback(
          true, { message: 'Error al extraer características', error },
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
        taskCallback(false, 'Pool finalizado', true);
      }
    }
  }

  customizeSpectrogram(
    mel_spectrogram: Array<Array<number>>,
    tempo: number,
    extendTempo: boolean
  ): Promise<SpectrogramSpecs> {
    return new Promise((resolve, reject) => {
      let control: { firstIndex: number, lastIndex: number, maxValue: number } = {
        firstIndex: -1, lastIndex: 20000, maxValue: 0
      };
      try {
        mel_spectrogram.forEach((row: any[]) => {
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

        const interval = Math.trunc((control.lastIndex - control.firstIndex) / tempo);
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
      } catch (error) {
        reject({ message: 'Error al personalizar espectrograma', error });
      }
    });
  }

  addToPoolSongsForUpload(song: Song) {
    this.pools.songsForUpload.push(song);
  }

  uploadSongsToServer(fullList: Array<Song>, idPlaylist: number, idPlaylistGlobal: number, taskCallback: Function): void {
    this.indexes.songsForUpload = fullList.length - this.pools.songsForUpload.length - 1;
    const that = this;
    if (!this.busyFlags.songsForUpload) {
      this.iterators.songsForUpload = this.pools.songsForUpload[Symbol.iterator]();
      this.busyFlags.songsForUpload = true;
      trigger();
    } else if (this.pools.songsForUpload.length == 0)
      return taskCallback(true, 'Pool is empty', null);
    else
      return taskCallback(true, 'Pool is busy', null);

    function trigger() {
      let item = that.iterators.songsForUpload.next();
      that.indexes.songsForUpload++;
      if (item.done)
        return checkPool(item);
      item.value.userScore = 0;
      item.value.tsPrediction = null;
      that.http.post('upload/song', { ...item.value, idPlaylist, idPlaylistGlobal }).subscribe({
        next: (res: any) => {
          taskCallback(false, { completed: false, storageStatus: 'uploaded', id: res.data.sRow.id }, that.indexes.songsForUpload);
          checkPool(item);
        },
        error: (error: { status: number; }) => {
          taskCallback(true, { completed: false, storageStatus: 'error', storageStatusErrReason: error.status == 403 ? 'duplicated' : 'other' }, that.indexes.songsForUpload);
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
        that.indexes.songsForUpload = -1;
        taskCallback(false, { completed: true }, null);
      }
    }

  }

  stopUploadSongsToServer() {
    this.pools.songsForUpload = [];
    this.iterators.songsForUpload = this.pools.songsForUpload[Symbol.iterator]();
    this.busyFlags.songsForUpload = false;
  }

  getIndexFromList(list: Array<Song>, idSong: number): number {
    return list.findIndex((obj) => obj.id == idSong);
  }
}
