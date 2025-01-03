import { Body, Controller, Post, UploadedFiles, UseInterceptors } from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';

@Controller('upload')
export class UploadController {
  constructor() { }

  @Post()
  @UseInterceptors(AnyFilesInterceptor({
    storage: diskStorage({
      destination: '../uploads',
      filename: ((req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}-${file.originalname}`);
      })
    })
  }))
  async uploadHandler(
    @UploadedFiles() files: Express.Multer.File[], 
    @Body('data') data: string
  ) {
    console.log('request', files);
    return {
      message: 'hold on...'
    };
  }

}
