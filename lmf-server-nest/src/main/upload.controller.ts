import { Controller, Get } from '@nestjs/common';
import { AppService } from 'src/app.service';

@Controller('main')
export class UploadfController {
  constructor(private readonly appService: AppService) {}
  
  @Get()
  getHello(): string {
    return this.appService.getHello();
  }
}
