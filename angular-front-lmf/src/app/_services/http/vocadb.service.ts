import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { HttpResponseSuccess } from '../../_models/generals.interfaces';
import { VocaDbYoutubeExtractionResult } from '../../_models/vocadb.interfaces';

@Injectable({
  providedIn: 'root'
})
export class VocadbService {
  private apiUrl = 'http://localhost:3000/api/v1';

  constructor(private http: HttpClient) { }

  createVocadbYoutubeLinksReport(year: number, rangeDays: number): Observable<VocaDbYoutubeExtractionResult> {
    return this.http.post<HttpResponseSuccess>(`${this.apiUrl}/vocadb/youtube-links-report`, { year, rangeDays }).pipe(
      map(response => response.data as VocaDbYoutubeExtractionResult)
    );
  }
}
