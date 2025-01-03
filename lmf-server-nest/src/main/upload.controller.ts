import { Controller, Get, Post, Req, UploadedFile, UploadedFiles, UseInterceptors } from '@nestjs/common';
import { AnyFilesInterceptor, FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { FormatInterceptor } from 'src/_interceptors/http/format.interceptor';
import { TsFeatureExtractorService } from 'src/_services/ts-feature-extractor/ts-feature-extractor.service';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import { diskStorage } from 'multer';

@Controller('upload')
export class UploadController {
  constructor(
    /*private readonly tsFeatureExtractor: TsFeatureExtractorService,
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>*/
  ) { }

  @Post()
  @UseInterceptors(AnyFilesInterceptor({
    storage: diskStorage({
      destination: './uploads',
      filename: ((req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}-${file.originalname}`);
      })
    })
  }))
  async uploadHandler(@UploadedFiles() files: any) {
    console.log('request', files);
    /*if (mode !== 'evaluated')
      return { message: 'Modo no soportado' };

    const results = [];
    for (const item of list) {
      let uploaded = true;
      let row = null;
      try {
        let storageName = new Date().getTime();
        fs.writeFile('./uploads/'+storageName+'mp3',item.file.)
      } catch (error) {
        uploaded = false;
        console.log('error', error);
      }
      if (uploaded) {
        const features = await this.tsFeatureExtractor.extractFeature('C:/Users/Administrador/Documents/Angular/listen-my-feelings/lmf-server-nest/uploads/' + item.file.name);
        row = await this.songRepository.save(this.songRepository.create({
          name: item.file.name,
          tsFeatures: JSON.stringify(features),
          score: item.score,
          trainstatus: 1,
        }));
      }

      results.push({ uploaded, row });
    }*/

    return {
      message: 'hold on...'
    };
  }

}
