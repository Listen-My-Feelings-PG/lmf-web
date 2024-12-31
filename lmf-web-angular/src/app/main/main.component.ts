import { Component, OnInit } from '@angular/core';
import { HttpService } from '../_services/http.service';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { CommonModule } from '@angular/common';
@Component({
  selector: 'app-main',
  imports: [
    ReactiveFormsModule,
    FileUploadModule,
    ButtonModule,
    CommonModule
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  song: FormGroup;
  stars = [0, 1, 2]; // Arreglo para las 3 estrellas
  currentRating = 0; // Inicialmente sin calificación
  constructor(private http: HttpService, private fb: FormBuilder) {
    this.song = fb.group({
      file: ['', Validators.required],
      score: [0, Validators.required]
    });
  }

  ngOnInit() {
    //this.http.setToast('success', 'Funciona!!!', 'La prueba del despliegue del toast funciona!!')
  }

  catchFile(evt: any): void {
    console.log('evt', evt);
    this.song.patchValue({ file: evt.files[0] });
  }

  rate(rating: number): void {
    this.currentRating = rating;
    this.song.patchValue({ score: this.currentRating })
    // Aquí puedes agregar la lógica adicional, como emitir eventos o guardar la puntuación
  }

  onSubmit() {
    console.log('this.song', this.song.value);
  }

}
