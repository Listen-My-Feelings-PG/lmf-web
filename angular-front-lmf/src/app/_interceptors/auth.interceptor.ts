import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { catchError } from 'rxjs/operators';
import { throwError } from 'rxjs';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const router = inject(Router);
  
  // Ignorar la ruta de login para no inyectar token si no es necesario
  if (req.url.includes('/api/v1/auth/login')) {
    return next(req);
  }

  const token = sessionStorage.getItem('lmf_token');
  
  let authReq = req;
  if (token) {
    authReq = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
  }
  
  return next(authReq).pipe(
    catchError((error: HttpErrorResponse) => {
      // Si el backend devuelve 401 (ej. token expirado o inválido)
      if (error.status === 401) {
        sessionStorage.removeItem('lmf_token');
        router.navigate(['/login']);
      }
      return throwError(() => error);
    })
  );
};
