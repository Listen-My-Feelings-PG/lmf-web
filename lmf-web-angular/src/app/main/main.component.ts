import { Component, OnInit } from '@angular/core';
import { HttpService } from '../_services/http.service';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { CommonModule } from '@angular/common';
import { Song } from '../_models/song.model';

@Component({
  selector: 'app-main',
  imports: [
    FileUploadModule,
    ButtonModule,
    CommonModule
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  songs: {
    form: Song,
    list: Array<Song>
  }
  stars = [0, 1, 2]; // Arreglo para las 3 estrellas
  uploadProgress: number = 0;
  progressVisible: boolean = false;

  constructor(
    private http: HttpService,
  ) {
    this.songs = {
      form: new Song('', 'file', null, '', 0),
      list: []
    }
  }

  ngOnInit() { }

  onBeforeUpload(event: any): void {
    this.progressVisible = true;
    this.uploadProgress = 0; // Reinicia la barra de progreso antes de una nueva carga.
  }

  onProgress(event: any): void {
    const loaded = event.progress.loaded;
    const total = event.progress.total;
    this.uploadProgress = Math.round((loaded / total) * 100); // Calcula el porcentaje de progreso.
  }

  onUpload(evt: any): void {
    this.songs.list.push(...evt.files.map((obj: any) => { return new Song(obj.name, 'file', obj, '', 0) }));
    this.progressVisible = false;
  }

  rate(indexSong: number, rating: number): void {
    this.songs.list[indexSong].score = rating;
  }

  submitList() {
    console.log('this.songs', this.songs);
    this.http.post('upload', { mode: 'evaluated', list: this.songs.list }).subscribe((data) => {
      console.log('data', data);
    });
  }

}
