import { Injectable } from '@angular/core';
import { Song } from '../_models/all.model';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class PlayerService {
  private actualSong: Song | null;
  private listQueue: Array<Song>;
  private playerEvent: BehaviorSubject<PlayerEvent>;
  private playerEmmitteridSong: BehaviorSubject<number>;
  constructor() {
    this.actualSong = null;
    this.listQueue = [];
    this.playerEvent = new BehaviorSubject<PlayerEvent>({
      action: 'stop',
      song: null
    });
    this.playerEmmitteridSong = new BehaviorSubject<number>(0);
  }

  getListQueue() {
    return this.listQueue;
  }

  addToListQueue(songs: Array<Song>) {
    this.listQueue = [...this.listQueue, ...songs];
  }

  removeFromListQueue(idSong: number) {
    this.listQueue.splice(this.listQueue.findIndex(song => song.id === idSong), 1);
  }

  getActualSong() {
    return this.actualSong;
  }

  setActualSong(song: Song) {
    this.actualSong = song;
  }

  setPlayerEvent(action: PlayerActions, song: Song | null) {
    return new Promise<void>((resolve) => {
      this.playerEvent.next({
        action, song
      });
      resolve();
    })

  }

  getPlayerEvent() {
    return this.playerEvent.asObservable();
  }

  setPlayerEmmitteridSong(idSong: number) {
    this.playerEmmitteridSong.next(idSong);
  }

  getPlayerEmmitteridSong() {
    return this.playerEmmitteridSong.asObservable();
  }
}

export type PlayerActions = 'play' | 'pause' | 'stop' | 'next' | 'previous' | 'rate' | 'showListQueue';

export interface PlayerEvent {
  action: PlayerActions, song: Song | null
}
