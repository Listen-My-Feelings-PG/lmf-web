import { HttpClient, HttpErrorResponse, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { BehaviorSubject, catchError, finalize, Observable, ObservableInput, tap, throwError, timeout } from 'rxjs';
import { ApiResponse } from '../_models/types';

export interface ToastProperties {
  key: 'default' | 'custom' | null;
  severity: 'success' | 'info' | 'warn' | 'error';
  summary: string;
  detail: string;
  life?: number;
  data?: any;
}

@Injectable({
  providedIn: 'root'
})
export class HttpService {
  private readonly busySubject = new BehaviorSubject<boolean>(false);
  private readonly baseUrl = 'http://localhost:3002/';
  private readonly defaultTimeout = 30000;
  private readonly toastSubject = new BehaviorSubject<ToastProperties>({
    key: null,
    severity: 'info',
    summary: '',
    detail: '',
    life: 4000
  });

  readonly busy$ = this.busySubject.asObservable();
  readonly toastEvent$ = this.toastSubject.asObservable();

  constructor(private http: HttpClient) { }

  get busy(): boolean {
    return this.busySubject.value;
  }

  /**
   * Realiza una petición GET HTTP con manejo de errores mejorado
   */
  get<T = any>(
    url: string,
    showErrorToast: boolean | ToastProperties = false,
    showSuccessToast?: ToastProperties,
    timeoutMs: number = this.defaultTimeout
  ): Observable<ApiResponse<T>> {
    this.setBusy(true);

    return this.http.get<ApiResponse<T>>(this.buildUrl(url))
      .pipe(
        timeout(timeoutMs),
        tap(() => {
          if (showSuccessToast) {
            this.showToast(showSuccessToast);
          }
        }),
        catchError(error => this.handleError(error, showErrorToast)),
        finalize(() => this.setBusy(false))
      );
  }

  /**
   * Realiza una petición POST HTTP con manejo de errores mejorado
   */
  post<T = any>(
    url: string,
    body: any,
    showErrorToast: boolean | ToastProperties = false,
    showSuccessToast?: ToastProperties,
    timeoutMs: number = this.defaultTimeout
  ): Observable<ApiResponse<T>> {
    this.setBusy(true);

    return this.http.post<ApiResponse<T>>(this.buildUrl(url), body)
      .pipe(
        timeout(timeoutMs),
        tap(() => {
          if (showSuccessToast) {
            this.showToast(showSuccessToast);
          }
        }),
        catchError(error => this.handleError(error, showErrorToast)),
        finalize(() => this.setBusy(false))
      );
  }

  /**
   * Realiza upload de archivos con soporte para progreso
   */
  upload<T = any>(
    url: string,
    formData: FormData,
    onProgress?: (progress: number) => void,
    showErrorToast: boolean | ToastProperties = true
  ): Observable<ApiResponse<T>> {
    this.setBusy(true);

    // TODO: Implementar seguimiento de progreso
    return this.http.post<ApiResponse<T>>(this.buildUrl(url), formData)
      .pipe(
        catchError(error => this.handleError(error, showErrorToast)),
        finalize(() => this.setBusy(false))
      );
  }

  /**
   * Muestra una notificación toast
   */
  setToast(
    severity: 'success' | 'info' | 'warn' | 'error',
    summary: string,
    detail: string,
    life: number = 5000
  ): void {
    this.showToast({
      key: 'default',
      severity,
      summary,
      detail,
      life
    });
  }

  /**
   * Obtiene el observable para eventos de toast
   */
  getToastEvent(): Observable<ToastProperties> {
    return this.toastEvent$;
  }

  private setBusy(busy: boolean): void {
    this.busySubject.next(busy);
  }

  private buildUrl(endpoint: string): string {
    return `${this.baseUrl}${endpoint}`;
  }

  private showToast(toast: ToastProperties): void {
    this.toastSubject.next(toast);
  }

  private handleError(
    error: HttpErrorResponse | any,
    showToast: boolean | ToastProperties
  ): ObservableInput<never> {
    console.error('HTTP Error:', error);

    // Manejo específico de errores HTTP
    if (error.status === 422) {
      sessionStorage.removeItem('currentUser');
      window.location.reload();
      return throwError(() => error);
    }

    // Mostrar toast de error si está configurado
    if (showToast) {
      if (typeof showToast === 'boolean') {
        this.setToast(
          'error',
          'Error de conexión',
          this.getErrorMessage(error)
        );
      } else {
        this.showToast(showToast);
      }
    }

    return throwError(() => error);
  }

  private getErrorMessage(error: HttpErrorResponse | any): string {
    if (error.error?.message) {
      return error.error.message;
    }

    switch (error.status) {
      case 0:
        return 'No se pudo conectar con el servidor. Verifica tu conexión a internet.';
      case 400:
        return 'Solicitud incorrecta. Verifica los datos enviados.';
      case 401:
        return 'No autorizado. Inicia sesión nuevamente.';
      case 403:
        return 'Acceso denegado.';
      case 404:
        return 'Recurso no encontrado.';
      case 500:
        return 'Error interno del servidor. Intenta nuevamente.';
      case 503:
        return 'Servicio no disponible. Intenta más tarde.';
      default:
        return error.message || 'Error desconocido en la conexión.';
    }
  }
}
