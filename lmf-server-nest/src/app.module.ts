import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UploadController } from './main/upload.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SongEntity } from './_entities/song.entity';
import { TsFeatureExtractorService } from './_services/ts-feature-extractor.service';
import { GzipConverterService } from './_services/gzip-converter.service';
import { UploadExampleController } from './main/upload-example.controller';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cf: ConfigService) => {
        return {
          type: 'postgres',
          host: cf.get<string>('DB_HOST'),
          port: parseInt(cf.get<string>('DB_PORT') || '5432', 10),
          username: cf.get<string>('DB_USERNAME'),
          password: cf.get<string>('DB_PASSWORD'),
          database: cf.get<string>('DB_DATABASE'),
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true, // No usar en producción
        };
      }
    }),
    TypeOrmModule.forFeature([SongEntity])
  ],
  controllers: [
    AppController,
    UploadController,
    UploadExampleController
  ],
  providers: [
    AppService,
    TsFeatureExtractorService,
    GzipConverterService
  ],
})
export class AppModule { }
