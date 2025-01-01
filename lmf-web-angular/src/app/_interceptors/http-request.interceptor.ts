import { HttpInterceptorFn } from '@angular/common/http';

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org'))
    return next(req);
  const body: any = req.body;
  const formData = new FormData();
  formData.set('mode', body.mode);
  body.list.forEach((item: any, index: any) => {
    formData.set(`file_${index}_file`, item.file);
    formData.set(`file_${index}_score`, item.score);
  });
  const content = { body: formData };
  const newReq = req.clone(content);
  console.log('newReq', newReq);
  return next(newReq);
};
