import { Controller, Get, Post, Req, UseInterceptors } from '@nestjs/common';
import { FormatInterceptor } from 'src/_interceptors/http/format.interceptor';
import { AppService } from 'src/app.service';

@Controller('upload')
export class UploadController {
  constructor(private readonly appService: AppService) { }

  @Post()
  @UseInterceptors(FormatInterceptor)
  handleUpload(@Req() request: any) {
    const formattedData = request.formattedData;
    console.log('formattedData', formattedData);
    return {
      message: 'Upload processed successfully',
      data: formattedData,
    };
  }

}
