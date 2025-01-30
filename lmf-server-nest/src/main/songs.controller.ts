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
import { PlaylistEntity } from 'src/_entities/playlist.entity';
import { SongsPlaylistsEntity } from 'src/_entities/songs-playlists.entity';

@Controller('songs')
export class SongsController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
    @InjectRepository(PlaylistEntity)
    private readonly playlistTable: Repository<PlaylistEntity>,
    @InjectRepository(SongsPlaylistsEntity)
    private readonly songsPlaylistsTable: Repository<SongsPlaylistsEntity>,
    private readonly cf: ConfigService
  ) { }

  @Get('list')
  @UsePipes(new ValidationPipe({ transform: true }))
  async getSongsList(@Query() idPlaylist: IntegerDto) {
    const playlistId = idPlaylist.value;

    const query = this.playlistTable.createQueryBuilder('playlist')
      .leftJoinAndSelect('playlist.songsPlaylists', 'songsPlaylists')
      .leftJoinAndSelect('songsPlaylists.song', 'song', 'song.active = :active', { active: true })
      .select([
        'playlist.id',
        'playlist.name',
        'playlist.idModel',
        'playlist.isDefault',
        'song.id',
        'song.name',
        'song.idDataType',
        'song.tsStatus',
        'song.tsInitStatus',
        'song.userScore',
        'song.tsPrediction'
      ])
      .where('playlist.id = :playlistId', { playlistId })
      .andWhere('playlist.active = :active', { active: true });
    const result = await query.getRawMany();

    const playlist = result.length ? new Playlist(
      result[0].playlist_pl_nombre,
      result.map((s: any) => new Song(
        s.song_ca_nombre,
        'file', null,
        s.song_ca_calif_usuario,
        s.song_ca_ts_prediccion,
        'uploaded', s.song_ca_ts_status,
        s.song_ca_ts_init_status,
        null, s.song_ca_id
      )),
      result[0].pl_id_modelo,
      result[0].playlist_pl_default,
      result[0].playlist_pl_id
    ) : null;

    return {
      message: 'Query successful',
      data: playlist
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
