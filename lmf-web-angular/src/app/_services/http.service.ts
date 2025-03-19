import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, catchError, finalize, Observable, ObservableInput, tap, throwError } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class HttpService {
  busy: boolean;
  baseUrl: string;
  private toastEvent: BehaviorSubject<ToastProperties>;
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
   * Envía una solicitud GET a la URL especificada y opcionalmente muestra notificaciones toast.
   *
   * @param {string} url - La URL a la que se envía la solicitud GET.
   * @param {ToastProperties} [toastError] - Propiedades opcionales para mostrar una notificación toast de error.
   * @param {ToastProperties} [toastSuccess] - Propiedades opcionales para mostrar una notificación toast de éxito.
   * @returns {Observable<any>} - Un observable de la respuesta HTTP.
   */
  get(url: string, toastError?: ToastProperties | true, toastSuccess?: ToastProperties): Observable<any> {
    this.busy = true;
    return this.http.get(this.baseUrl + url)
      .pipe(
        //tap(() => console.info('url:', url)),
        finalize(() => {
          this.busy = false;
          if (toastSuccess !== undefined)
            this.setToast(
              toastSuccess.severity,
              toastSuccess.summary,
              toastSuccess.detail,
              toastSuccess.life
            );
        }),
        catchError((err) => this.handleError(err, toastError))
      );
  }

  /**
   * Envía una solicitud POST a la URL especificada con el cuerpo proporcionado y opcionalmente muestra notificaciones toast.
   *
   * @param {string} url - La URL a la que se envía la solicitud POST.
   * @param {Object} body - El cuerpo de la solicitud POST.
   * @param {ToastProperties} [toastError] - Propiedades opcionales para mostrar una notificación toast de error.
   * @param {ToastProperties} [toastSuccess] - Propiedades opcionales para mostrar una notificación toast de éxito.
   * @returns {Observable<any>} - Un observable de la respuesta HTTP.
   */
  post(url: string, body: Object, toastError?: ToastProperties | true, toastSuccess?: ToastProperties): Observable<any> {
    this.busy = true;
    return this.http.post(this.baseUrl + url, body)
      .pipe(
        //tap(() => console.info('url:', url, 'body:', body)),
        finalize(() => {
          this.busy = false;
          if (toastSuccess !== undefined)
            this.setToast(
              toastSuccess.severity,
              toastSuccess.summary,
              toastSuccess.detail,
              toastSuccess.life
            );
        }),
        catchError((err) => this.handleError(err, toastError))
      );
  }

  /**
   * Muestra una notificación toast con los parámetros especificados.
   * 
   * @param severity - El nivel de severidad del toast. Puede ser 'success', 'info', 'warn' o 'error'.
   * @param summary - Un breve resumen del mensaje del toast.
   * @param detail - Una descripción detallada del mensaje del toast.
   * @param life - (Opcional) La duración en milisegundos durante la cual se debe mostrar el toast. Por defecto es 5000 milisegundos si no se proporciona.
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
   * Maneja los errores HTTP y opcionalmente muestra una notificación tipo toast.
   * 
   * @param error - El objeto de error o cualquier otra información de error.
   * @param toastError - Parámetro opcional para especificar propiedades del toast o un booleano para mostrar un toast de error predeterminado.
   * @returns Un observable input del error.
   * 
   * Si el estado del error es 422, elimina el 'currentUser' del almacenamiento de sesión y recarga la ventana.
   * Si `toastError` se proporciona y no es un booleano, establece un toast con las propiedades proporcionadas.
   * Si `toastError` es verdadero, establece un toast de error predeterminado indicando un error de conexión.
   */
  handleError(error: Error | any, toastError?: ToastProperties | true): ObservableInput<Error> {
    if (error.status == 422) {
      sessionStorage.removeItem('currentUser');
      window.location.reload();
    } else if (toastError !== undefined) {
      if (typeof toastError !== 'boolean')
        this.setToast(
          toastError.severity,
          toastError.summary,
          toastError.detail,
          toastError.life
        );
      else
        this.setToast('error', 'Error de conexión', 'No se pudo establecer conexión con el servidor');
    }
    return throwError(error);
  }

  /**
   * Recupera el observable del evento toast actual.
   *
   * @returns {Observable<any>} El observable para el evento toast.
   */
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
