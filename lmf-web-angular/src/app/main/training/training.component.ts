import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';

@Component({
  selector: 'app-training',
  standalone: true,
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule,
  ],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  songs: {
    list: Array<Song>,
    pool: Array<Song>,
    poolBusy: boolean,
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
      iterator: null
    }

    this.rating = {
      stars: [0, 1, 2],
      blocked: false
    }

    this.songs.iterator = this.songs.pool[Symbol.iterator]();
  }

  ngOnInit(): void {
    this.http.get('songs/list').subscribe({
      next: (res) => {
        this.songs.list = res.data;
      }
    });
  }

  private triggerRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkPool(item);
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'uploaded';
        listSong.id = data.row.id;
        this.checkPool(item);
      },
      error: (error) => {
        console.log('error', error);
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'error';
        listSong.errReason = error.status == 403 ? 'duplicated' : 'other';
        this.checkPool(item);
      }
    });
  }

  private checkPool(item: any) {
    if (!item.done)
      this.triggerRequest();
    else {
      this.songs.pool = [];
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
        userScore: null,
        tsScore: null,
        status: 'local'
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
