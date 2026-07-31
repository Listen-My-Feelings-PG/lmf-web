import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Song } from '../../_models/generals.models';
import { Playlist, HttpResponseSuccess } from '../../_models/generals.interfaces';

@Injectable({
  providedIn: 'root'
})
export class PlaylistsService {
  private apiUrl = 'http://localhost:3000/api/v1';

  constructor(private http: HttpClient) { }

  getAllPlaylists(): Observable<Playlist[]> {
    return this.http.get<HttpResponseSuccess>(`${this.apiUrl}/playlists/all`).pipe(
      map(response => response.data as Playlist[])
    );
  }

  getPlaylistContentByIdPlaylist(idPlaylist: number): Observable<Song[]> {
    return this.http.get<HttpResponseSuccess>(`${this.apiUrl}/playlists/content/${idPlaylist}`).pipe(
      map(response => response.data as Song[])
    );
  }

  getAllSongsByPlaylistId(idPlaylist: number): Observable<Song[]> {
    return this.getPlaylistContentByIdPlaylist(idPlaylist);
  }
}
