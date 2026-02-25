import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Song } from '../_types/generals.models';
import { HttpResponseSuccess, Playlist } from '../_types/generals.interfaces';

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

  rateSongByIdSong(idSong: number, score: 0 | 1 | 2 | 3): Promise<void> {
    return new Promise((resolve, reject) => {
      this.http.post(this.apiUrl + `/songs/rate/${idSong}`, { score }).subscribe({
        next: () => resolve(),
        error: (error) => reject({ error, at: 'rateSongByIdSong' })
      });
    });
  }

  getSongsScoredByUser(): Promise<Array<Song>> {
    return new Promise((resolve, reject) => {
      this.http.get<HttpResponseSuccess>(this.apiUrl + `/songs/scored-by-user`).subscribe({
        next: (response) => resolve(response.data as Array<Song>),
        error: (error) => reject({ error, at: 'getSongsScoredByUser' })
      });
    });
  }
}
