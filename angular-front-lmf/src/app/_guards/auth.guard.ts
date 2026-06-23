import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';

export const AuthGuard: CanActivateFn = (route, state) => {
  const router = inject(Router);
  const token = sessionStorage.getItem('lmf_token');

  if (token) {
    return true;
  }

  // Si no hay token, redirigimos al login
  router.navigate(['/login']);
  return false;
};
