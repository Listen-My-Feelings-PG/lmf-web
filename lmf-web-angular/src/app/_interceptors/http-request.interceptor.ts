import { HttpInterceptorFn } from '@angular/common/http';

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org') || req.method == 'GET') return next(req);
  else {
    console.log('Interceptando request...', req.body);
    const body: any = req.body;
    const formData: FormData = new FormData();

    for (let key in body) {
      if (body[key] !== null)
        formData.set(key, (body as any)[key]);
    }/*NOTA: Si el valor es null o undefined, no se escribe en el FormData. (Se debe validar si el campo no es obligatorio (nullable), 
    o si tiene valor por default)*/
    return next(req.clone({ body: formData }));
  }
};

