import { Body, Controller, Post, UploadedFiles, UseInterceptors } from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { diskStorage } from 'multer';
import { SongEntity } from 'src/_entities/song.entity';
import { TsFeatureExtractorService } from 'src/_services/ts-feature-extractor/ts-feature-extractor.service';
import { Repository } from 'typeorm';

@Controller('upload')
export class UploadController {
  constructor(
    private readonly tsFeatureExtractor: TsFeatureExtractorService,
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>
  ) { }

  @Post()
  @UseInterceptors(AnyFilesInterceptor({
    storage: diskStorage({
      destination: '../uploads',
      filename: ((req, file, cb) => {
        const uniqueSuffix = new Date().getTime();
        cb(null, `${uniqueSuffix}-${file.originalname}`);
      })
    })
  }))
  async uploadHandler(
    @UploadedFiles() files: Express.Multer.File[],
    @Body() body: string
  ) {
    console.log('files', files);
    console.log('data', body);
    const features = await this.tsFeatureExtractor.extractFeature('../uploads/' + files[0].filename);
    console.log('features', features.length);
    return {
      message: 'hold on...',
      features
    };
  }

}
