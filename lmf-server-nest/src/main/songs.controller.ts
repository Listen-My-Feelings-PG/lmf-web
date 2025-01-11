import { Controller, Get } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { Song } from 'src/_models/all.model';
import { Repository } from 'typeorm';

@Controller('songs')
export class SongsController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>
  ) { }

  @Get('list')
  async getSongsList() {
    const list = await this.songsTable.find({ select: ['id', 'name', 'trainlevel', 'userScore', 'tsScore'] });
    return {
      message: 'Query successful',
      data: list.map((o) => new Song(o.name, 'file', null, '', o.userScore, o.tsScore, 'uploaded', 0, 'other', o.id))
    }
  }
}
