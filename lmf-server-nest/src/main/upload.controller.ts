import { Body, Controller, HttpException, HttpStatus, Post, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { diskStorage } from 'multer';
import { SongEntity } from 'src/_entities/song.entity';
import { TsFeatureExtractorService } from 'src/_services/ts-feature-extractor.service';
import { Repository } from 'typeorm';
import { GzipConverterService } from 'src/_services/gzip-converter.service';
import { Mp3ValidationPipe } from 'src/_pipes/mp3-validation.pipe';
import * as fs from 'fs';
import * as path from 'path';


@Controller('upload')
export class UploadController {
  constructor(
    private readonly tsFeatureExtractor: TsFeatureExtractorService,
    private readonly gzipConverter: GzipConverterService,
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>
  ) { }

  @Post('file')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: '../uploads',
        filename: ((req, file, cb) => {
          const uniqueSuffix = new Date().getTime();
          cb(null, `${uniqueSuffix}_${file.originalname}`);
        })
      })
    })
  )
  async uploadHandler(
    @UploadedFile(new Mp3ValidationPipe()) file: Express.Multer.File,
    @Body() body: any
  ) {
    //console.log('body', body);
    console.log('file', file.originalname);

    const existingSong = await this.songRepository.findOne({
      where: {
        name: file.originalname,
        fileSize: file.size
      }
    });
    if (existingSong) {
      const filePath = path.resolve('../uploads', file.filename);
      if (fs.existsSync(filePath))
        await fs.unlinkSync(filePath);
      console.error('Canción duplicada:', file.filename);
      throw new HttpException('Duplicated song', HttpStatus.FORBIDDEN)
    } else {
      const name = body.name;
      const row = await this.songRepository.save(this.songRepository.create({
        name: name,
        fileSize: file.size,
        fileName: file.filename
      }));
      return {
        message: 'uploaded successful',
        row
      }
    }
  }

}
