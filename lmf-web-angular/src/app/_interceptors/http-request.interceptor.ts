import { HttpInterceptorFn } from '@angular/common/http';

export const httpRequestInterceptor: HttpInterceptorFn = (req, next) => {
  if (req.url.includes('www.primefaces.org') || req.method == 'GET') return next(req);
  else {
    /**El formato predeterminado para un body es un objeto de una sola dimensión con las definiciones de los campos en formato JSON:
     * {
     *  key1: string,
     *  key2: string,
     *  ...
     * }
     *  
     * Si existe más de un archivo, se especifican las definiciones(campos) del archivo en camnpos con la siguiente nomenclatura: 
     * file_[índice]_[key1], file_[índice]_[key2],... seguido del archivo con el nombre "file_[índice]":
     * { 
     *  ...
     *  file_0: File,
     *  file_1: File
     *  ...
     *  file_0_key1: string,
     *  file_1_key1: string,
     *  ...
     * } 
    */
    const body: any = req.body;
    const formData: FormData = new FormData();

    for (let key in body) {
      if (body[key] !== null)
        formData.set(key, (body as any)[key]);
    }/*NOTA: Si el valor es null o undefined, no se escribe en el FormData. (Se debe validar en el backend si el campo no es obligatorio (nullable) o si tiene valor por default)*/

    return next(req.clone({ body: formData }));
  }
};

