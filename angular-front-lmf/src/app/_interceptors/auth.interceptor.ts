import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  // Ignorar la ruta de login para no inyectar token si no es necesario
  if (req.url.includes('/api/v1/auth/login')) {
    return next(req);
  }

  const token = localStorage.getItem('lmf_token');
  
  if (token) {
    const authReq = req.clone({
      headers: req.headers.set('Authorization', `Bearer ${token}`)
    });
    return next(authReq);
  }
  
  return next(req);
};
