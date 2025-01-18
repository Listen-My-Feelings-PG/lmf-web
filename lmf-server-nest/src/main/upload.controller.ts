import {
  Body,
  Controller,
  HttpException,
  HttpStatus,
  Post,
  UploadedFile,
  UseInterceptors
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { diskStorage } from 'multer';
import { SongEntity } from 'src/_entities/song.entity';
import { Repository } from 'typeorm';
import { GzipConverterService } from 'src/_services/gzip-converter.service';
import { Mp3ValidationPipe } from 'src/_pipes/mp3-validation.pipe';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';


@Controller('upload')
export class UploadController {
  constructor(
    private readonly gzipConverter: GzipConverterService,
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) { }

  @Post('file')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (req, file, cb) => {
          const cf: ConfigService = new ConfigService();
          cb(null, cf.get<string>('PATH_UPLOADS'))
        },
        filename: ((req, file, cb) => {
          const uniqueSuffix = new Date().getTime();
          const sanitizedFilename = Buffer.from(file.originalname, 'latin1').toString('utf8');
          cb(null, `${uniqueSuffix}_${sanitizedFilename}`);
        })
      })
    })
  )
  async uploadHandler(
    @UploadedFile(new Mp3ValidationPipe()) file: Express.Multer.File,
    @Body() body: any
  ) {
    const existingSong = await this.songsTable.findOne({
      where: {
        name: file.originalname,
        fileSize: file.size
      }
    });
    const filePath = path.resolve(this.cf.get<string>('PATH_UPLOADS'), file.filename);
    if (existingSong) {
      if (fs.existsSync(filePath))
        await fs.unlinkSync(filePath);
      console.error('Canción duplicada:', file.filename);
      throw new HttpException('Duplicated song', HttpStatus.FORBIDDEN);
    } else {
      const name = body.name;
      try {
        const row = await this.songsTable.save(this.songsTable.create({
          name: name,
          fileSize: file.size,
          fileName: file.filename,
          idDataType: 1 //hardcodeado!!
        }));
        return {
          message: 'uploaded successful',
          row
        }
      } catch (error) {
        await fs.unlinkSync(filePath);
        console.error('Error en inserción SQL:', error);
        throw new HttpException('Error in SQL insertion', HttpStatus.INTERNAL_SERVER_ERROR);
      }
    }
  }

}
