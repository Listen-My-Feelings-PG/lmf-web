import { Component, OnInit } from '@angular/core';
import { HttpService } from '../_services/http.service';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { CommonModule } from '@angular/common';
import { Song } from '../_models/song.model';

@Component({
  selector: 'app-main',
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule
  ],
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

  stars = [0, 1, 2]; // Arreglo para las 3 estrellas

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
    this.songs.iterator = this.songs.pool[Symbol.iterator]();
  }

  private triggerRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkPool(item);
    console.log('triggering request...');
    this.songs.poolCounter++;
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        console.log('data', data);
        let listSong = this.songs.list[item.value.listIndex];
        listSong.uploadSuccess = true;
        listSong.id = data.row.id;
        this.checkPool(item);
      },
      error: (error) => {
        let listSong = this.songs.list[item.value.listIndex];
        console.error('error en http request:', error);
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

  rate(indexSong: number, rating: number): void {
    this.songs.list[indexSong].userScore = rating;
  }



}
