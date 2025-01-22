import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, catchError, finalize, Observable, ObservableInput, throwError } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class HttpService {
  busy: boolean;
  baseUrl: string;
  private toastEvent: BehaviorSubject<ToastProperties>;
  /**
   * Crea una instancia de HttpService.
   * 
   * @param http - La instancia de HttpClient utilizada para realizar solicitudes HTTP.
   * 
   * @remarks
   * Inicializa la bandera `busy` a `false` y establece el `baseUrl` en 'http://localhost:3000/'.
   * También inicializa el BehaviorSubject `toastEvent` con `ToastProperties` predeterminadas.
   * 
   * El `toastEvent` sirve como un evento en el servicio, actuando como un puente entre el componente emisor (.next) y el componente receptor (.subscribe).
   */
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
  /**
   * Envía una solicitud GET a la URL especificada.
   *
   * @param url - La URL del endpoint al que se enviará la solicitud GET.
   * @param toastBlocked - Indicador opcional para indicar si se deben bloquear las notificaciones toast.
   * @param blockedItem - Indicador opcional para indicar si el elemento debe ser bloqueado durante la solicitud.
   * @returns Un Observable que emite la respuesta de la solicitud GET.
   */
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
  /**
   * Realiza una solicitud HTTP POST al servidor.
   *
   * @param {string} url - La URL a la que se enviará la solicitud POST.
   * @param {Object} body - El cuerpo de la solicitud que se enviará.
   * @param {boolean} [toastBlocked] - Indica si se debe bloquear la notificación de toast en caso de error.
   * @param {boolean} [blockedItem] - Indica si el elemento debe ser bloqueado durante la solicitud.
   * @returns {Observable<any>} Un observable que emite la respuesta del servidor.
   */
  post(url: string, body: Object, toastBlocked?: boolean, blockedItem?: boolean): Observable<any> {
    this.busy = true;
    if (blockedItem !== undefined)
      blockedItem = true;
    return this.http.post(this.baseUrl + url, body)
      .pipe(
        finalize(() => {
          this.busy = false;
          if (blockedItem)
            blockedItem = false;
        }),
        catchError((err) => this.handleError(err, toastBlocked))
      );
  }
  /**
   * Configura y dispara un evento de notificación tipo toast.
   *
   * @param {'success' | 'info' | 'warn' | 'error'} severity - El nivel de severidad del mensaje.
   * @param {string} summary - Un resumen breve del mensaje.
   * @param {string} detail - Detalles adicionales del mensaje.
   * @param {number} [life=5000] - La duración de la notificación en milisegundos. Por defecto es 5000 ms.
   */
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
  /**
   * Maneja los errores de las solicitudes HTTP.
   *
   * @param {Error | any} error - El error que se produjo en la solicitud.
   * @param {boolean} [toastBlocked] - Indicador opcional para indicar si se deben bloquear las notificaciones toast.
   * @returns {ObservableInput<Error>} Un observable que emite el error.
   */
  handleError(error: Error | any, toastBlocked?: boolean): ObservableInput<Error> {
    if (error.status == 422) {
      sessionStorage.removeItem('currentUser');
      window.location.reload();
    } else if (!toastBlocked) {

      this.toastEvent.next({
        key: 'default',
        severity: 'error',
        summary: 'Error de conexión',
        detail: 'Ocurrió un error en el servidor. Inténtelo mas tarde',
        life: 5000
      });
    }

    return throwError(error);
  }

  getToastEvent() {
    return this.toastEvent;
  }
}
/**
 * Interfaz que define las propiedades de una notificación tipo toast.
 */
export interface ToastProperties {
  key: 'default' | 'custom' | null,
  severity: 'success' | 'info' | 'warn' | 'error',
  summary: string,
  detail: string,
  life?: number,
  data?: any
}
