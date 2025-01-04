import { Body, Controller, Post, UploadedFiles, UseInterceptors } from '@nestjs/common';
import { AnyFilesInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { writeFile } from 'fs/promises';
import { diskStorage } from 'multer';
import * as path from 'path';
import * as zlib from 'zlib';
import { SongEntity } from 'src/_entities/song.entity';
import { TsFeatureExtractorService } from 'src/_services/ts-feature-extractor/ts-feature-extractor.service';
import { Repository } from 'typeorm';
import { GzipConverterService } from 'src/_services/gzip-converter/gzip-converter.service';

@Controller('upload')
export class UploadController {
  constructor(
    private readonly tsFeatureExtractor: TsFeatureExtractorService,
    private readonly gzipConverter: GzipConverterService,
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
    try {
      const features = await this.tsFeatureExtractor.extractFeature('../uploads/' + files[0].filename);
      const compressedFile = await this.gzipConverter.compressFile(features, files[0].filename);
      await writeFile(compressedFile.filePath, compressedFile.data);
      console.log('guardado exitoso');
      return {
        message: 'hold on...',
        features
      };
    } catch (error) {
      console.error('Error processing file:', error);
      throw new Error('Feature extraction failed');
    }
  }

}
