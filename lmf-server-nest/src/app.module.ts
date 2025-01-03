import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UploadController } from './main/upload.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SongEntity } from './_entities/song.entity';
import { TsFeatureExtractorService } from './_services/ts-feature-extractor/ts-feature-extractor.service';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: 'localhost',
      port: 5432,
      username: 'postgres',
      password: 'root',
      database: 'lmf_db',
      entities: [__dirname + '/**/*.entity{.ts,.js}'],
      synchronize: true, // No usar en producción
    }),
    TypeOrmModule.forFeature([SongEntity])
  ],
  controllers: [
    AppController,
    UploadController
  ],
  providers: [AppService, TsFeatureExtractorService],
})
export class AppModule { }
