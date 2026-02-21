import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { HttpService } from './_services/http.service';
import { TensorflowService } from './_services/tensorflow-v2.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, CommonModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss'
})
export class AppComponent implements OnInit {
  title = 'lmf-web-angular';
  constructor(
    private http: HttpService,
    private tsService: TensorflowService
  ) { }
  ngOnInit(): void {
    this.tsService.initializeTensorflow();
    // Toast functionality can be implemented later with custom component
  }
}
