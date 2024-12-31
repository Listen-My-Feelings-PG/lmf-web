import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UploadfController } from './main/upload.controller';

@Module({
  imports: [],
  controllers: [
    AppController,
    UploadfController
  ],
  providers: [AppService],
})
export class AppModule { }
