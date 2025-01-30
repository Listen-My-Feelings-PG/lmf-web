import { Body, Controller, Post, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { PlaylistEntity } from 'src/_entities/playlist.entity';
import { FindManyOptions, Repository } from 'typeorm';

@Controller('playlist')
@UseInterceptors(FileInterceptor(''))
export class PlaylistController {
  constructor(
    @InjectRepository(PlaylistEntity)
    private readonly playlistTable: Repository<PlaylistEntity>
  ) { }
  @Post('get-list')
  async getPlaylist(@Body() body: any) {
    const query: FindManyOptions<PlaylistEntity> = {
      select: ['id', 'name', 'isDefault'],
      where: { active: true }
    }

    if (body.all == true)
      query.where['id'] = body.id;

    const list = await this.playlistTable.find(query);
    return {
      message: 'Query successful',
      data: list
    }
  }
}
