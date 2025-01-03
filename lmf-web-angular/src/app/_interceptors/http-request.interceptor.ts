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
  let reqBody: FormData = new FormData();
  let data: any = {};
  body.list.forEach((item: any, index: any) => {
    console.log('item', item);
    if (item.type == 'file') {
      data['song_' + index] = { score: item.score };
      reqBody.append('song_' + index, item.file);
    }
  });
  reqBody.append('data', JSON.stringify(data));
  const content = { body: reqBody };
  const newReq = req.clone(content)
  return next(newReq);
};
