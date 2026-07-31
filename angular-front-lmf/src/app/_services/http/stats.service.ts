import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { Calibration, HttpResponseSuccess } from '../../_models/generals.interfaces';

@Injectable({
  providedIn: 'root'
})
export class StatsService {
  private apiUrl = 'http://localhost:3000/api/v1';

  constructor(private http: HttpClient) { }

  getAllSongsCalibrationByIdPlaylist(idPlaylist: number): Observable<Array<Calibration>> {
    return this.http.get<HttpResponseSuccess>(`${this.apiUrl}/stats/songs-in-playlist/${idPlaylist}`).pipe(
      map(response => response.data as Array<Calibration>)
    );
  }
}
