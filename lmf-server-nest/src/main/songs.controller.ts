import { Controller, Get, HttpException, HttpStatus, Query, Res, UsePipes, ValidationPipe } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { IntegerDto } from 'src/_pipes/dtos.pipe';
import { Repository } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express';
import { SongsPlaylistsEntity } from 'src/_entities/songs-playlists.entity';
import { Song } from 'src/_models/all.model';

@Controller('songs')
export class SongsController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
    @InjectRepository(SongsPlaylistsEntity)
    private readonly songsPlaylistsTable: Repository<SongsPlaylistsEntity>,
    private readonly cf: ConfigService
  ) { }

  @Get('list-by-idPlaylist')
  @UsePipes(new ValidationPipe({ transform: true }))
  async getSongsList(@Query() idPlaylist: IntegerDto) {
    const list = await this.songsPlaylistsTable.find({
      select: {
        idSong: {
          id: true,
          name: true,
          tsStatus: true,
          tsInitStatus: true,
          userScore: true,
          tsPrediction: true,
          idDataType: true
        },
        idPlaylist: {
          name: true,
          isDefault: true,
          idModel: {
            id: true,
            trainCount: true,
            isGlobal: true
          }
        }
      },
      relations: ['idSong', 'idPlaylist', 'idPlaylist.idModel'],
      where: {
        idSong: { active: true },
        idPlaylist: {
          id: idPlaylist.value,
          active: true
        }
      }
    });

    const dataTypes = {
      'file': this.cf.get<string>('TS_DATAYPE_FILE'),
      'link': this.cf.get<string>('TS_DATAYPE_LINK')
    }

    return {
      message: 'Query successful',
      data: list.map((s) => new Song(s.idSong.name, dataTypes[s.idSong.idDataType], null, s.idSong.userScore, s.idSong.tsPrediction, 'downloaded', s.idSong.tsStatus as Song['tsStatus'], s.idSong.tsInitStatus as Song['tsInitStatus'], s.idSong.id))
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
        console.error('Archivo no encontrado');
        throw new HttpException('Cancion no encontrada en el servidor', HttpStatus.NOT_FOUND);
      }
    } else {
      console.error('Canción no encontrada');
      throw new HttpException('Cancion no encontrada en bd', HttpStatus.NOT_FOUND);
    }
  }
}
