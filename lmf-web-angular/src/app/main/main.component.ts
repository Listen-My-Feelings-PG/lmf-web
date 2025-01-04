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
export class MainComponent implements OnInit {
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

  ngOnInit() { }

  private triggerRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkPool(item);
    this.songs.poolCounter++;
    this.http.post('upload/file', item.value).subscribe((data) => {
      console.log('data', data);
      item.value.uploadSuccess = true;
      this.songs.list.push(item.value);
      this.checkPool(item);
    }, (error) => {
      console.error('error en http request:', error);
      this.songs.list.push(item.value);
      this.checkPool(item);
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
    evt.currentFiles.forEach((item: any) => this.songs.pool.push({
      name: item.name,
      type: 'file',
      file: item,
      link: '',
      userScore: 0,
      status: 'evaluated',
      uploadSuccess: false
    }));

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
