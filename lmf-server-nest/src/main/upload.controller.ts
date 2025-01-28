import {
  Body,
  Controller,
  HttpException,
  HttpStatus,
  Post,
  Query,
  UploadedFile,
  UseInterceptors,
  UsePipes,
  ValidationPipe
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { diskStorage } from 'multer';
import { SongEntity } from 'src/_entities/song.entity';
import { Repository } from 'typeorm';
import { Mp3ValidationPipe } from 'src/_pipes/mp3-validation.pipe';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { Song } from 'src/_models/all.model';
import { BooleanDto } from 'src/_pipes/dtos.pipe';


@Controller('upload')
export class UploadController {
  constructor(
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
          cb(null, cf.get<string>('TS_PATH_UPLOADS'))
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
    @Body() body: Song
  ) {
    const existingSong = await this.songsTable.findOne({
      where: {
        name: file.originalname,
        fileSize: file.size,
        active: true
      }
    });
    const filePath = path.resolve(this.cf.get<string>('TS_PATH_UPLOADS'), file.filename);
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
          idDataType: 1,
          tsStatus: null,
          tsInitStatus: body.tsInitStatus,
          fileSize: file.size,
          fileName: file.filename,
          userScore: body.userScore !== undefined ? body.userScore : null,
          tsPrediction: body.tsPrediction !== undefined ? body.tsPrediction : null
        }));/*Regla: Todo lo que sea 'undefined' es porque en el front es NULL (un valor 0 es válido). 
       Cuando sea necesario en la operación, este debe permitir nulos, o tener un valor por default*/
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

  @Post('prediction')
  @UseInterceptors(FileInterceptor(''))
  async setPrediction(@Body() body: any) {
    const song = await this.songsTable.findOne({ where: { id: body.id, active: true } });
    if (song) {
      song.tsPrediction = body.prediction;
      await this.songsTable.save(song);
      return {
        message: 'prediction set',
        id: body.id,
        prediction: body.prediction
      };
    } else {
      console.error('Cancion no encontrada:', body.id);
      throw new HttpException('Song not found', HttpStatus.NOT_FOUND)
    }
  }

  @Post('model')
  @UsePipes(new ValidationPipe({ transform: true }))
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (req, file, cb) => {
          const cf: ConfigService = new ConfigService();
          cb(null, cf.get<string>('TS_PATH_MODELS'))
        },
        filename: ((req, file, cb) => {
          const uniqueSuffix = new Date().getTime();
          const sanitizedFilename = Buffer.from(file.originalname, 'latin1').toString('utf8');
          cb(null, `${uniqueSuffix}_${sanitizedFilename}`);
        })
      })
    })
  )
  uploadModel(
    @UploadedFile() file: Express.Multer.File,
    @Body() body: any,
    @Query() isGlobal: BooleanDto
  ) {
    console.log('file:', file);
    console.log('isGlobal:', isGlobal);
    console.log('body:', body);
    return {
      message: 'model uploaded'
    }
  }

}
