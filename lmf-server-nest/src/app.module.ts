import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UploadController } from './main/upload.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SongEntity } from './_entities/song.entity';
import { GzipConverterService } from './_services/gzip-converter.service';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { RateController } from './main/rate.controller';
import { FeatureExtractorService } from './_services/feature-extractor.service';
import { SongsController } from './main/songs.controller';
import { DownloadController } from './main/download.controller';
import { PlaylistController } from './main/playlist.controller';
import { PlaylistEntity } from './_entities/playlist.entity';
import { SongsPlaylistsEntity } from './_entities/songs-playlists.entity';
import { ModelEntity } from './_entities/model.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env'
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (cf: ConfigService) => {
        return {
          type: 'postgres',
          host: cf.get<string>('TS_DB_HOST'),
          port: parseInt(cf.get<string>('TS_DB_PORT') || '5432', 10),
          username: cf.get<string>('TS_DB_USERNAME'),
          password: cf.get<string>('TS_DB_PASSWORD'),
          database: cf.get<string>('TS_DB_DATABASE'),
          entities: [__dirname + '/**/*.entity{.ts,.js}'],
          synchronize: true, // No usar en producción
        };
      }
    }),
    TypeOrmModule.forFeature([
      SongEntity,
      PlaylistEntity,
      SongsPlaylistsEntity,
      PlaylistEntity,
      ModelEntity
    ]),
  ],
  controllers: [
    AppController,
    UploadController,
    RateController,
    SongsController,
    DownloadController,
    PlaylistController
  ],
  providers: [
    AppService,
    GzipConverterService,
    FeatureExtractorService
  ],
})
export class AppModule { }
