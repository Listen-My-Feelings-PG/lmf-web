import { HttpInterceptorFn } from '@angular/common/http';

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org') || req.method == 'GET') return next(req);
  else {
    const body: any = req.body;
    console.log('body:', body);
    const formData: FormData = new FormData();
    for (let key in body) {
      formData.set(key, (body as any)[key]);
    }
    return next(req.clone({ body: formData }));
  }
};

