import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, ObservableInput, throwError } from 'rxjs';
import { catchError, finalize } from 'rxjs/operators';

@Injectable({
  providedIn: 'root'
})
export class HttpService {
  busy: boolean;
  baseUrl: string;
  private toastEvent: BehaviorSubject<ToastProperties>

  constructor(private http: HttpClient) {
    this.busy = false;
    this.baseUrl = 'http://localhost:3000/';
    this.toastEvent = new BehaviorSubject<ToastProperties>({ //Evento en un servicio. La variable funcionará como puente entre el componente emisor (.next) y el receptor(.subscribe)
      key: null,
      severity: 'info',
      summary: '',
      detail: '',
      life: 4000
    });
  }

  get(url: string, toastBlocked?: boolean, blockedItem?: boolean): Observable<any> {
    this.busy = true;
    if (blockedItem !== undefined)
      blockedItem = true;
    return this.http.get(this.baseUrl + url)
      .pipe(
        finalize(() => {
          this.busy = false;
          if (blockedItem)
            blockedItem = false;
        }),
        catchError((err) => this.handleError(err, toastBlocked))
      );
  }

  setToast(
    severity: 'success' | 'info' | 'warn' | 'error',
    summary: string,
    detail: string,
    life?: number
  ) {
    this.toastEvent.next({  //El evento se dispara con next (disparado tambien en el componente emisor)
      key: 'default',
      severity,
      summary,
      detail,
      life: life ? life : 5000
    });
  }

  handleError(error: Error | any, toastBlocked?: boolean): ObservableInput<Error> {
    if (error.status == 422) {
      sessionStorage.removeItem('currentUser');
      window.location.reload();
    } else if (!toastBlocked)
      this.toastEvent.next({
        key: 'default',
        severity: 'error',
        summary: 'Error de conexión',
        detail: 'Ocurrió un error en el servidor. Inténtelo mas tarde',
        life: 5000
      });
    return throwError(error);
  }

  getToastEvent() {
    return this.toastEvent;
  }
}

export interface ToastProperties {
  key: 'default' | 'custom' | null,
  severity: 'success' | 'info' | 'warn' | 'error',
  summary: string,
  detail: string,
  life?: number,
  data?: any
}
