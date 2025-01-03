import { HttpInterceptorFn } from '@angular/common/http';
export interface RequestBodyModel {
  mode: 'evaluated',
  form: FormData,
  [key: string]: File | 'evaluated' | FormData;
}

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org')) return next(req);
  const body: any = req.body;
  const reqBody: any = new FormData();
  const data: any = {};
  body.list.forEach((item: any, index: any) => {
    if (item.type === 'file') {
      data['song_' + index] = { score: item.score };
      reqBody.append('song_' + index, item.file);
    }
  });
  //reqBody.append('data', JSON.stringify(data));
  for (let pair of reqBody as any) {
    console.log(pair[0], pair[1]);
  }
  const newReq = req.clone({ body: reqBody });
  return next(newReq);
};
