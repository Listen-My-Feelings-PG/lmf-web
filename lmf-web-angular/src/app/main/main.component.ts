import { Component, OnInit } from '@angular/core';
import { HttpService } from '../_services/http.service';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { CommonModule } from '@angular/common';
import { Song } from '../_models/song.model';

@Component({
  selector: 'app-main',
  standalone: true,
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent {
  songs: {
    list: Array<Song>,
    pool: Array<Song>,
    poolBusy: boolean,
    poolCounter: number,
    iterator: any
  }

  rating: {
    stars: Array<number>,
    blocked: boolean
  }

  constructor(
    private http: HttpService,
  ) {
    this.songs = {
      list: [],
      pool: [],
      poolBusy: false,
      poolCounter: 0,
      iterator: null
    }

    this.rating = {
      stars: [0, 1, 2],
      blocked: false
    }

    this.songs.iterator = this.songs.pool[Symbol.iterator]();
  }

  private triggerRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkPool(item);
    this.songs.poolCounter++;
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.uploadSuccess = true;
        listSong.id = data.row.id;
        this.checkPool(item);
      },
      error: (error) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.uploadSuccess = false;
        listSong.errReason = 'duplicated';
        this.checkPool(item);
      }
    });
  }

  private checkPool(item: any) {
    if (!item.done)
      this.triggerRequest();
    else {
      this.songs.pool = [];
      this.songs.poolCounter = 0;
      this.songs.poolBusy = false;
    }
  }

  onFilesSelected(evt: any) {
    evt.currentFiles.forEach((item: any) => {
      const song: Song = {
        name: item.name,
        type: 'file',
        file: item,
        link: '',
        userScore: 0,
        status: 'evaluated'
      }
      this.songs.list.push(song);
      this.songs.pool.push({ ...song, listIndex: this.songs.list.length - 1 });
    });

    if (!this.songs.poolBusy) {
      this.songs.iterator = this.songs.pool[Symbol.iterator]();
      this.songs.poolBusy = true;
      this.triggerRequest();
    }
  }

  rate(indexSong: number, rate: number): void {
    let song = this.songs.list[indexSong];
    if (!this.rating.blocked || song.userScore != rate) {
      this.http.post('rate/song', { id: song.id, score: rate }, false, this.rating.blocked).subscribe({
        next: (data) => {
          song.userScore = data.score;
        }
      });
    }
  }
}
