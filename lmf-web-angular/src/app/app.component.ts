import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MessageService, PrimeNGConfig } from 'primeng/api';
import { ToastModule } from 'primeng/toast';
import { HttpService } from './_services/http.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, ToastModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
  providers: [MessageService]
})
export class AppComponent implements OnInit {
  title = 'lmf-web-angular';

  constructor(
    private toast: MessageService,
    private http: HttpService,
    private config: PrimeNGConfig
  ) { }

  ngOnInit(): void {
    this.http.getToastEvent().subscribe((props) => {
      if (props.key)
        this.toast.add(props as any)
    });
  }
}
