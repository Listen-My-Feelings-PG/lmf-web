import { BadRequestException, CallHandler, ExecutionContext, Injectable, NestInterceptor, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class FormatInterceptor implements NestInterceptor {
  @UseInterceptors(FileInterceptor('file'))
  getFile(@UploadedFile() file: Express.Multer.File) {
    return file;
  }
  intercept( context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const body = request.body;
    const files = request.files;
    if (!body?.data || !files)
      throw new BadRequestException('Invalid request format: body or files missing.');

    let parsedData: Record<string, any>;

    try {
      parsedData = JSON.parse(body.data);
    } catch (error) {
      throw new BadRequestException('Invalid JSON format in body.data.');
    }

    const list = Object.keys(parsedData).map((key) => {
      const file = files[key];
      if (!file || parsedData[key].score === undefined)
        throw new BadRequestException(`File/score for key "${key}" is missing.`);
      return {
        file,
        link: '',
        score: parsedData[key].score
      }
    });

    request.formattedData = {
      mode: 'evaluated',
      list,
    };

    return next.handle().pipe(map((data) => ({ ...data, request: request.formattedData })));
  }
}
