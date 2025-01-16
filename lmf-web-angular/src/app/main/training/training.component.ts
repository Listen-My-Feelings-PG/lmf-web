import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { Song } from '../../_models/all.model';
import { HttpService } from '../../_services/http.service';
import { PlayerComponent } from "../../player/player.component";

@Component({
  selector: 'app-training',
  standalone: true,
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule,
    PlayerComponent
  ],
  templateUrl: './training.component.html',
  styleUrl: './training.component.scss'
})
export class TrainingComponent implements OnInit {
  urlSongPlaying: string;
  songs: {
    list: Array<Song>,
    pool: Array<Song>,
    poolBusy: boolean,
    iterator: any
  }

  tsFeatures: {
    poolSongIds: Array<number>,
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
    this.tsFeatures = {
      poolSongIds: [],
      poolBusy: false,
      iterator: null
    }

    this.urlSongPlaying = '';
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

  private triggerUploadRequest() {
    let item = this.songs.iterator.next();
    if (item.done)
      return this.checkUploadPool(item);
    this.http.post('upload/file', item.value, true).subscribe({
      next: (data: any) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'uploaded';
        listSong.id = data.row.id;
        this.checkUploadPool(item);
      },
      error: (error) => {
        let listSong = this.songs.list[item.value.listIndex];
        listSong.status = 'error';
        listSong.errReason = error.status == 403 ? 'duplicated' : 'other';
        this.checkUploadPool(item);
      }
    });
  }

  private checkUploadPool(item: any) {
    if (!item.done)
      this.triggerUploadRequest();
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
      this.triggerUploadRequest();
    }
  }

  rate(indexSong: number, rate: number): void {
    let song = this.songs.list[indexSong];
    if (!this.rating.blocked || song.userScore != rate) {
      this.http.post('rate/song', { id: song.id, score: rate }, false, this.rating.blocked).subscribe({
        next: (res) => {
          song.userScore = res.score;
        }
      });
    }
  }

  play(listIndex: number) {
    const s = this.songs.list[listIndex];
    this.urlSongPlaying = `http://localhost:3000/songs/song/mp3?value=${s.id}`;
  }

  getSongTsFeatures() {
    const idsSongsRated = this.songs.list.filter((obj) => obj.userScore !== null && obj.userScore > 0 && !obj.tsFeatures).map((obj) => obj.id);
    this.tsFeatures.poolSongIds = idsSongsRated as Array<number>;
    if (!this.tsFeatures.poolBusy) {
      this.tsFeatures.iterator = this.tsFeatures.poolSongIds[Symbol.iterator]();
      this.tsFeatures.poolBusy = true;
      this.triggerTsfeaturesRequest();
      console.log('triggerTsfeaturesRequest disparado...');
    }
  }

  private triggerTsfeaturesRequest() {
    let item = this.tsFeatures.iterator.next();
    if (item.done)
      return this.checkTsFeaturesPool(item);
    let songIndex = this.songs.list.findIndex((obj) => obj.id == item.value);
    this.http.get(`download/tsfeatures?value=${item.value}`, true).subscribe({
      next: (data) => {
        this.songs.list[songIndex].tsFeatures = data;
        this.checkTsFeaturesPool(item);
      },
      error: (error) => {
        console.log('error', error);
        this.songs.list[songIndex].tsFeatures = 'error';
        this.songs.list[songIndex].tsFeaturesErrReason = 'other';
        this.checkTsFeaturesPool(item);
      }
    });
  }

  private checkTsFeaturesPool(item: any) {
    if (!item.done)
      this.triggerTsfeaturesRequest();
    else {
      this.tsFeatures.poolSongIds = [];
      this.tsFeatures.poolBusy = false
      console.log('Pool finalizado');
    }
  }

  stopTsFeaturesPool() {
    this.tsFeatures.poolSongIds = [];
    this.tsFeatures.iterator = this.tsFeatures.poolSongIds[Symbol.iterator]();
    //this.checkTsFeaturesPool({ done: true });
  }

  getTsFeaturesDimensions(song: Song) {
    let validColumns = 0;
    if (song.tsFeatures !== undefined && song.tsFeatures !== 'error') {
      song.tsFeatures?.mel_spectrogram.forEach((item) => {
        item.forEach((value) => {
          if (value > 0)
            validColumns++;
        });
      });
      return validColumns;
    } else
      return '--';
  }


}
