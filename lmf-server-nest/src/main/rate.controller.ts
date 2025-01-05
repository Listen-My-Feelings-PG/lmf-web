import { Body, Controller, HttpException, HttpStatus, Post, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from 'src/_entities/song.entity';
import { FeatureExtractorService } from 'src/_services/feature-extractor.service';
import { Repository } from 'typeorm';

@Controller('rate')
export class RateController {
  constructor(
    @InjectRepository(SongEntity) private readonly songRepository: Repository<SongEntity>,
    private readonly featureExtractor: FeatureExtractorService
  ) { }

  @Post('song')
  @UseInterceptors(FileInterceptor(''))
  async rateSong(@Body() body: any) {
    const song = await this.songRepository.findOneBy({ id: body.id });
    if (song) {
      song.userScore = body.score;
      await this.songRepository.save(song);
      const feProcess = await this.featureExtractor.runExtraction();
      //console.log('feProcess', feProcess);
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