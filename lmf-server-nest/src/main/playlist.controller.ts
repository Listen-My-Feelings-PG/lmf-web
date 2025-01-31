import { Body, Controller, Post, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { ModelEntity } from 'src/_entities/model.entity';
import { PlaylistEntity } from 'src/_entities/playlist.entity';
import { FindManyOptions, Repository } from 'typeorm';

@Controller('playlist')
@UseInterceptors(FileInterceptor(''))
export class PlaylistController {
  constructor(
    @InjectRepository(PlaylistEntity)
    private readonly playlistTable: Repository<PlaylistEntity>,
    @InjectRepository(ModelEntity)
    private readonly modelTable: Repository<ModelEntity>
  ) { }
  @Post('get-all')
  async getPlaylist(@Body() body: any) {
    const options: FindManyOptions<PlaylistEntity> = {
      select: {
        id: true,
        name: true,
        isDefault: true,
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
    };/**
     * SELECT pl_id,pl_nombre,pl_default,mo_id,mo_descripcion,mo_train_count,mo_globa FROM public.playlists LEFT JOIN public.modelos ON mo_id=pl_id_modelo AND mo_activo=TRUE WHERE pl_activo=TRUE
     */

    const playlists = await this.playlistTable.find(options);
    return {
      message: 'Query successful',
      data: playlists
    };
  }
}
