import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Song } from '../_types/generals.models';
import { Calibration, HttpResponseSuccess, Playlist, TrainingModality, UserScore } from '../_types/generals.interfaces';

@Injectable({
  providedIn: 'root'
})
export class HttpService {
  constructor(private http: HttpClient) { }
  private apiUrl = 'http://localhost:3000/api/v1';
  getPlaylistContentByIdPlaylist(idPlaylist: number): Promise<Array<Song>> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/playlists/content/${idPlaylist}`).subscribe({
        next: (response: HttpResponseSuccess) => resolve(response.data as Array<Song>),
        error: (error) => reject({ error, at: 'getPlaylistContentByIdPlaylist' })
      });
    });
  }

  getAllPlaylists(): Promise<Playlist[]> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/playlists/all`).subscribe({
        next: (response) => resolve(response.data as Playlist[]),
        error: (error) => reject({ error, at: 'getAllPlaylists' })
      });
    });
  }

  downloadSongByIdSong(idSong: number): Promise<Blob> {
    return new Promise((resolve, reject) => {
      this.http.get(this.apiUrl + `/songs/song-by-id/${idSong}`, { responseType: 'blob' }).subscribe({
        next: (response) => resolve(response),
        error: (error) => reject({ error, at: 'downloadSongByIdSong' })
      });
    });
  }

  rateSongByIdSong(idSong: number, score: UserScore): Promise<Song> {
    return new Promise((resolve, reject) => {
      this.http.post<HttpResponseSuccess>(this.apiUrl + `/songs/rate/${idSong}`, { score }).subscribe({
        next: (response) => resolve(response.data as Song),
        error: (error) => reject({ error, at: 'rateSongByIdSong' })
      });
    });
  }

  getAllSongsByPlaylistId(idPlaylist: number): Promise<Array<Song>> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/playlists/content/${idPlaylist}`).subscribe({
        next: (response) => resolve(response.data as Array<Song>),
        error: (error) => reject({ error, at: 'getAllSongsByPlaylistId' })
      });
    });
  }

  tuneSongByIdSong(idSong: number): Promise<Song> {
    return new Promise((resolve, reject) => {
      this.http.post<HttpResponseSuccess>(this.apiUrl + `/songs/tune/${idSong}`, {}).subscribe({
        next: (response) => resolve(response.data as Song),
        error: (error) => reject({ error, at: 'tuneSongByIdSong' })
      });
    });
  }

  trainSongsByIds(songIds: number[], mode: TrainingModality, includeLocalTraining: boolean): Promise<{ success: boolean, message: string }> {
    return new Promise((resolve, reject) => {
      this.http.post<{ success: boolean, message: string }>(this.apiUrl + `/songs/train-songs-by-ids`, { songIds: JSON.stringify(songIds), mode, includeLocalTraining }).subscribe({
        next: (response) => resolve(response),
        error: (error) => reject({ error, at: 'trainSongsByIds' })
      });
    });
  }

  getSongsForPrediction(playlistsIds?: Array<number>): Promise<Array<Song>> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/songs/songs-for-prediction/${playlistsIds !== undefined ? JSON.stringify(playlistsIds) : null}`).subscribe({
        next: (response) => resolve(response.data as Array<Song>),
        error: (error) => reject({ error, at: 'getSongsForPrediction' })
      });
    });
  }

  predictSongsByIds(songIds: number[]): Promise<Array<{ success: boolean, message: string }>> {
    return new Promise((resolve, reject) => {
      this.http.post<Array<{ success: boolean, message: string }>>(this.apiUrl + `/songs/predict-songs-by-ids`, { songIds: JSON.stringify(songIds) }).subscribe({
        next: (response) => resolve(response),
        error: (error) => reject({ error, at: 'predictSongsByIds' })
      });
    });
  }

  getAllSongsCalibrationByIdPlaylist(idPlaylist: number): Promise<Array<Calibration>> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/stats/songs-in-playlist/${idPlaylist}`).subscribe({
        next: (response) => resolve(response.data as Array<Calibration>),
        error: (error) => reject({ error, at: 'getAllSongsCalibrationByIdPlaylist' })
      });
    });
  }
}
