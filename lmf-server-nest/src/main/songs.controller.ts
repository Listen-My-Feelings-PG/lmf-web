import { Body, Controller, Get, HttpException, HttpStatus, Post, Query, Res, UseInterceptors, UsePipes, ValidationPipe } from '@nestjs/common';
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
import { FileInterceptor } from '@nestjs/platform-express';
import { FeatureExtractorService } from 'src/_services/feature-extractor.service';

@Controller('songs')
export class SongsController {
  constructor(
    @InjectRepository(SongEntity) private readonly songsTable: Repository<SongEntity>,
    @InjectRepository(SongsPlaylistsEntity) private readonly songsPlaylistsTable: Repository<SongsPlaylistsEntity>,
    @InjectRepository(SongEntity) private readonly songRepository: Repository<SongEntity>,
    private readonly featureExtractor: FeatureExtractorService,
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

  @Post('update-status')
  @UseInterceptors(FileInterceptor(''))
  async updateSongStatus(@Body() body: any) {
    const song = await this.songRepository.findOneBy({ id: body.idSong, active: true });
    if (song) {
      song.tsStatus = body.tsStatus;
      song.tsInitStatus = body.tsInitStatus;
      song.userScore = body.score;
      const result = await this.songRepository.save(song);
      await this.featureExtractor.runExtraction();
      return {
        message: 'Query successful',
        data: result
      };
    } else {
      console.error('Cancion no encontrada:', body.id);
      throw new HttpException('Song not found', HttpStatus.NOT_FOUND)
    }
  }
}
