import { Body, Controller, Post, UseInterceptors } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { PlaylistEntity } from 'src/_entities/playlist.entity';
import { FindManyOptions, Repository } from 'typeorm';

@Controller('playlist')
@UseInterceptors(FileInterceptor(''))
export class PlaylistController {
  constructor(
    @InjectRepository(PlaylistEntity)
    private readonly playlistTable: Repository<PlaylistEntity>,
    private readonly cf: ConfigService,
  ) { }
  @Post('get-all')
  async getPlaylist() {
    const options: FindManyOptions<PlaylistEntity> = {
      select: {
        id: true,
        name: true,
        isGlobal: true,
        idModel: {
          id: true,
          description: true,
          trainCount: true,
          isGlobal: true
        }
      },
      relations: ['idModel'],
      where: {
        active: true
      }
    };

    const playlists = await this.playlistTable.find(options);
    return {
      message: 'Query successful',
      data: {
        list: playlists,
        tsConfig: {
          epochs: {
            score1: this.cf.get<number>('TS_EPOCHSNUM_SCORE1'),
            score2: this.cf.get<number>('TS_EPOCHSNUM_SCORE2'),
            score3: this.cf.get<number>('TS_EPOCHSNUM_SCORE3')
          }
        }
      }
    };
  }

  @Post('create')
  async createPlaylist(@Body() body: any) {
    const newPlaylist = this.playlistTable.create({ name: body.name });
    await this.playlistTable.save(newPlaylist);
    return {
      message: 'Query successful',
      data: { id: newPlaylist.id }
    };
  }
}
