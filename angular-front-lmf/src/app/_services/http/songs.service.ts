import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Song } from '../../_models/generals.models';
import { TrainingModality, UserScore, HttpResponseSuccess } from '../../_models/generals.interfaces';

@Injectable({
  providedIn: 'root'
})
export class SongsService {
  private apiUrl = 'http://localhost:3000/api/v1';

  constructor(private http: HttpClient) { }

  downloadSongByIdSong(idSong: number): Observable<Blob> {
    return this.http.get(`${this.apiUrl}/songs/song-by-id/${idSong}`, { responseType: 'blob' });
  }

  rateSongByIdSong(idSong: number, score: UserScore): Observable<Song> {
    return this.http.post<HttpResponseSuccess>(`${this.apiUrl}/songs/rate/${idSong}`, { score }).pipe(
      map(response => response.data as Song)
    );
  }

  tuneSongByIdSong(idSong: number): Observable<{ success: boolean, message: string }> {
    return this.http.post<{ success: boolean, message: string }>(`${this.apiUrl}/songs/tune/${idSong}`, {});
  }

  trainSongsByIds(songIds: number[], mode: TrainingModality, includeLocalTraining: boolean): Observable<{ success: boolean, message: string }> {
    return this.http.post<{ success: boolean, message: string }>(`${this.apiUrl}/songs/train-songs-by-ids`, { songIds: JSON.stringify(songIds), mode, includeLocalTraining });
  }

  getSongsForPrediction(playlistsIds?: Array<number>): Observable<Array<Song>> {
    const idsParam = playlistsIds !== undefined ? JSON.stringify(playlistsIds) : null;
    return this.http.get<HttpResponseSuccess>(`${this.apiUrl}/songs/songs-for-prediction/${idsParam}`).pipe(
      map(response => response.data as Array<Song>)
    );
  }

  predictSongsByIds(songIds: number[]): Observable<Array<{ success: boolean, message: string }>> {
    return this.http.post<Array<{ success: boolean, message: string }>>(`${this.apiUrl}/songs/predict-songs-by-ids`, { songIds: JSON.stringify(songIds) });
  }

  copySelectedSongsToOnboard(songIds: number[]): Observable<{ success: boolean, message: string }> {
    return this.http.post<{ success: boolean, message: string }>(`${this.apiUrl}/songs/copy-to-onboard`, { songIds: JSON.stringify(songIds) });
  }

  deleteSelectedSongsFromLibrary(songIds: number[]): Observable<{ success: boolean, message: string, deletedIds: number[] }> {
    return this.http.post<{ success: boolean, message: string, deletedIds: number[] }>(`${this.apiUrl}/songs/delete-from-library`, { songIds: JSON.stringify(songIds) });
  }
}
