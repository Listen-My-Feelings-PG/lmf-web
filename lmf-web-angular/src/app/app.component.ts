import { AfterViewInit, Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MessageService } from 'primeng/api';
import { HttpService } from './_services/http.service';
import { ToastModule } from 'primeng/toast';
import { TensorflowService } from './_services/tensorflow.service';

@Component({
  selector: 'app-root',
  standalone: true,
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
    private tsService: TensorflowService
  ) { }
  ngOnInit(): void {
    this.tsService.init();
    this.http.getToastEvent().subscribe((props) => {
      if (props.key)
        this.toast.add(props as any)
    });
  }
}
