import { CommonModule } from '@angular/common';
import { Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { ButtonGroupModule } from 'primeng/buttongroup';
import { Song } from '../_models/all.model';
import { PlayerService } from '../_services/player.service';
import { SongService } from '../_services/song.service';

@Component({
  selector: 'app-player',
  standalone: true,
  imports: [CommonModule, ButtonModule, ButtonGroupModule],
  templateUrl: './player.component.html',
  styleUrl: './player.component.scss'
})
export class PlayerComponent implements OnInit {
  @ViewChild('audioPlayer', { static: true }) audioPlayer!: ElementRef;
  urlSong: string;
  baseUrl: string;
  isPlaying: boolean;
  currentTime: number;
  pauseTime: number;
  duration: number;
  caption: string;

  constructor(private playerService: PlayerService, private songService: SongService) {
    this.urlSong = '';
    this.baseUrl = 'http://localhost:3002/songs/song/mp3?value=';
    this.caption = 'Proident incididunt nisi eiusmod qui occaecat. Voluptate irure eiusmod cillum ut. Incididunt ullamco aliqua nulla laboris eiusmod in velit tempor esse amet mollit excepteur deserunt. Non ad veniam duis aute ut. Minim officia anim consequat laborum aliquip Lorem quis proident voluptate excepteur duis incididunt.';
    this.isPlaying = false;
    this.currentTime = 0;
    this.pauseTime = 0;
    this.duration = 0;
  }

  ngOnInit(): void {
    this.playerService.getPlayerEvent().subscribe({
      next: (event) => {
        switch (event.action) {
          case 'play':
            this.play(event.song ? event.song : undefined);
            break;
          case 'pause':
            this.pause();
            break;
          case 'stop':
            if (this.isPlaying)
              this.stop();
            break;
          case 'next':
            this.next();
            break;
          case 'previous':
            this.previous();
            break;
          case 'rate':
            this.rate(event.song?.userScore || 0);
            break;
        }
      }
    });
  }

  play(song?: Song): void {
    const audio = this.audioPlayer.nativeElement;
    const actualSong = this.playerService.getActualSong();
    let canPlay = false;
    if (this.isPlaying)
      audio.pause();
    this.urlSong = '';
    if (song) {
      this.urlSong = this.baseUrl + song.id;
      this.playerService.setPlayerEmmitterIdSong(song.id as number);
      this.setCaption(song);
      canPlay = true;
    } else if (actualSong && actualSong.id) {
      this.urlSong = this.baseUrl + actualSong.id.toString();
      this.playerService.setPlayerEmmitterIdSong(actualSong.id);
      this.setCaption(actualSong);
      canPlay = true;
    }

    if (canPlay) {
      audio.src = this.urlSong;
      if (this.pauseTime) {
        audio.currentTime = this.pauseTime;
        audio.play().then(() => this.isPlaying = true).catch((error: any) => {
          console.error('Error al reproducir la canción:', error);
          this.isPlaying = false;
        });
      } else {
        audio.load();
        audio.play().then(() => {
          if (song)
            this.playerService.setActualSong(song); //Aquí es el único lugar donde se debe escribir la canción actual, ya que aquí se está reproduciendo
          this.isPlaying = true;
        }).catch((error: any) => {
          console.error('Error al reproducir la canción:', error);
          this.isPlaying = false;
        });
      }
    }
  }

  setCaption(song: Song): void {
    this.caption = song.name;
  }

  pause(): void {
    const audio = this.audioPlayer.nativeElement;
    this.pauseTime = audio.currentTime;
    audio.pause();
    this.isPlaying = false;
  }

  stop(): void {
    const audio = this.audioPlayer.nativeElement;
    if (audio)
      audio.pause();
    audio.currentTime = 0;
    this.isPlaying = false;
  }

  next(): void {
    const listQueue = this.playerService.getListQueue();
    const actualSongId = this.playerService.getActualSong()?.id;
    let actualSongIdx = actualSongId !== undefined ? this.songService.getIndexFromList(listQueue, actualSongId) : -1;
    if (actualSongIdx !== undefined && actualSongIdx !== null) {
      actualSongIdx++;
      if (actualSongIdx >= listQueue.length) {
        actualSongIdx = 0;
      }
      this.play(listQueue[actualSongIdx]);
    }
  }

  previous(): void {
    const listQueue = this.playerService.getListQueue();
    const actualSongId = this.playerService.getActualSong()?.id;
    let actualSongIdx = actualSongId !== undefined ? this.songService.getIndexFromList(listQueue, actualSongId) : -1;
    if (actualSongIdx !== undefined && actualSongIdx !== null) {
      actualSongIdx--;
      if (actualSongIdx < 0) {
        actualSongIdx = listQueue.length - 1;
      }
      this.playerService.setActualSong(listQueue[actualSongIdx]);
      this.play(listQueue[actualSongIdx]);
    }
  }

  rate(rate: number): void {
    const song = this.playerService.getActualSong();
    if (song) {
      // this.http.post('rate/song', { id: song.id, score: rate }, true).subscribe({
      //   next: (res) => song.userScore = res.score
      // });
    }
  }

  updateProgress(): void {
    const audio = this.audioPlayer.nativeElement;
    this.currentTime = audio.currentTime;
  }

  updateMetadata(): void {
    const audio = this.audioPlayer.nativeElement;
    this.duration = audio.duration;
  }

  onSeek(event: Event): void {
    const input = event.target as HTMLInputElement;
    const audio = this.audioPlayer.nativeElement;
    audio.currentTime = parseFloat(input.value);
    this.currentTime = audio.currentTime;
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
  }
}
