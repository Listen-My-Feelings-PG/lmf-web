import { Injectable } from '@angular/core';
import { Song } from '../_models/all.model';
import { HttpService } from './http.service';

@Injectable({
  providedIn: 'root'
})
export class SongService {
  private pool: Array<Song>;
  poolBusy: boolean;
  private iterator: any;
  constructor(
    private http: HttpService
  ) {
    this.pool = [];
    this.poolBusy = false;
    this.iterator = null;
  }

  addToPoolSongs(song: Song) {
    this.pool.push(song);
  }

  uploadSongsToServer(listForFill: Array<Song>) {
    let that = this;
    return new Promise((resolve, reject) => {
      if (!this.poolBusy) {
        this.iterator = this.pool[Symbol.iterator]();
        this.poolBusy = true;
        trigger();
      } else
        reject('Pool is busy');

      function trigger() {
        let item = that.iterator.next();
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
          that.pool = [];
          that.poolBusy = false;
          resolve(listForFill);
        }
      }

    })
  }

  stopUploadsToServer() {
    this.pool = [];
    this.iterator = this.pool[Symbol.iterator]();
    this.poolBusy = false;
  }
}
