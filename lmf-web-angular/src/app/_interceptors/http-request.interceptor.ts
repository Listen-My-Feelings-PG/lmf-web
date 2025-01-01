import { HttpInterceptorFn } from '@angular/common/http';
export interface RequestBodyModel {
  mode: 'evaluated',
  form: FormData,
  [key: string]: File | 'evaluated' | FormData;
}

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org'))
    return next(req);
  const body: any = req.body;
  const reqBody: FormData = new FormData();
  const data: any = {};
  body.list.forEach((item: any, index: any) => {
    if (item.type == 'file') {
      data['song_' + index] = { score: item.score };
      reqBody.set('song_' + index, item.file);
    }
  });
  reqBody.set('data', JSON.stringify(data));
  const content = { body: reqBody };
  const newReq = req.clone(content)
  return next(newReq);
};
