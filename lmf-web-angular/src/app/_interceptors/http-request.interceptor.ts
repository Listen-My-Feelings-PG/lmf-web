import { HttpInterceptorFn } from '@angular/common/http';

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org')) return next(req);
  const body: any = req.body;
  const formData: FormData = new FormData();
  for (let key in body) {
    formData.set(key, (body as any)[key]);
  }

  return next(req.clone({ body: formData }));
};
