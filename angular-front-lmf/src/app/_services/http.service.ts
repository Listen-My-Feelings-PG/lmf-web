import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Playlist, Song } from '../_types/generals.models';
import { HttpResponseSuccess } from '../_types/generals.interfaces';

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
        error: (error) => reject(error)
      });
    });
  }
}
