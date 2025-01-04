import { Body, Controller, HttpException, HttpStatus, Post, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { Repository } from 'typeorm';

@Controller('rate')
export class RateController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>
  ) { }
  @Post('song')
  @UseInterceptors(FileInterceptor(''))
  async rateSong(@Body() body: any) {
    const song = await this.songRepository.findOneBy({ id: body.id });
    if (song) {
      song.userScore = body.score;
      await this.songRepository.save(song);
      return {
        message: 'song rated',
        id: body.id,
        score: body.score
      };
    } else {
      console.error('Cancion no encontrada:', body.id);
      throw new HttpException('Song not found', HttpStatus.NOT_FOUND)
    }
  }
}