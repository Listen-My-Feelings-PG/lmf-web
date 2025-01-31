import { Controller, Get, HttpException, HttpStatus, Query, Res, UsePipes, ValidationPipe } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { Playlist, Song } from '../_models/all.model';
import { IntegerDto } from 'src/_pipes/dtos.pipe';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express';

@Controller('songs')
export class SongsController {
  constructor(

    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) { }

  @Get('list-by-idPlaylist')
  @UsePipes(new ValidationPipe({ transform: true }))
  async getSongsList(@Query() idPlaylist: IntegerDto) {
    const list = await this.songsTable.find({
      select: {
        id: true,
        name: true,
        tsStatus: true,
        tsInitStatus: true,
        userScore: true,
        tsPrediction: true,
        idDataType: true,
        songsPlaylists: {
          idPlaylist: {
            id: true,
            name: true,
            isDefault: true,
            idModel: {
              id: true,
              trainCount: true,
              isGlobal: true
            }
          }
        }
      },
      relations: [
        'songsPlaylists',
        'songsPlaylists.idPlaylist',
        'songsPlaylists.idPlaylist.idModel'
      ],
      where: {
        active: true,
        songsPlaylists: {
          idPlaylist: {
            id: idPlaylist.value, active: true, idModel: { active: true }
          }
        }
      }
    });
    const dataTypes = {
      'file': this.cf.get<string>('TS_DATAYPE_FILE'),
      'link': this.cf.get<string>('TS_DATAYPE_LINK')
    }
    return {
      message: 'Query successful',
      data: list.map((s) => new Song(
        s.name,
        dataTypes[s.idDataType],
        null,
        s.userScore,
        s.tsPrediction,
        'downloaded',
        s.tsStatus as Song["tsStatus"],
        s.tsInitStatus as Song["tsInitStatus"],
        s.id
      ))
    };
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
