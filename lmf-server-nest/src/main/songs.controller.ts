import { Controller, Get, HttpException, HttpStatus, Query, Res, UsePipes, ValidationPipe } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { Song } from '../_models/all.model';
import { IntegerDto } from 'src/_pipes/integer-dto.pipe';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express'

@Controller('songs')
export class SongsController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) { }

  @Get('list')
  async getSongsList() {
    const list = await this.songsTable.find({
      select: ['id', 'name', 'tsStatus', 'tsInitStatus', 'trainLevelGlobal', 'userScore', 'tsPrediction'],
      where: { active: true },
      order: { id: 'ASC' }
    });
    return {
      message: 'Query successful',
      data: list.map((obj) => new Song(
        obj.name, 'file', null, obj.userScore, obj.tsPrediction, 'uploaded',
        (obj.tsStatus as 'trained' | 'predicted' | 'retrained'),
        (obj.tsInitStatus as 'train' | 'predict' | 'retrain'), null, obj.id
      ))
    }
  }

  @Get('song/mp3')
  @UsePipes(new ValidationPipe({ transform: true }))
  async getMp3Song(@Query() idSong: IntegerDto, @Res() res: Response) {
    const song = await this.songsTable.findOne({ where: { id: idSong.value, active: true } });
    if (song) {
      const filePath = path.resolve(this.cf.get<string>('TS_PATH_UPLOADS'), song.fileName);
      if (fs.existsSync(filePath)) {
        res.set({
          'Content-Type': 'audio/mpeg',
          'Content-Disposition': `attachment; filename="file.mp3"`
        });
        return res.sendFile(filePath);
      } else {
        console.error('La cancion no existe en el servidor');
        throw new HttpException('Cancion no encontrada en el servidor', HttpStatus.NOT_FOUND);
      }
    } else {
      console.error('Canción no encontrada');
      throw new HttpException('Cancion no encontrada en bd', HttpStatus.NOT_FOUND);
    }
  }
}
