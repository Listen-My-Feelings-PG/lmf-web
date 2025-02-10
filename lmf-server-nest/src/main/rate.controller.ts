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
    private readonly featureExtractor: FeatureExtractorService,
    @InjectRepository(SongEntity)
    private readonly songsTable: Repository<SongEntity>,
  ) { }

  @Post('song')
  @UseInterceptors(FileInterceptor(''))
  async rateSong(@Body() body: any) {
    const song = await this.songRepository.findOneBy({ id: body.id, active: true });
    if (song) {
      song.userScore = body.score;
      await this.songRepository.save(song);
      await this.featureExtractor.runExtraction();
      return {
        message: 'song rated',
        data: {
          id: body.id,
          score: body.score
        }

      };
    } else {
      console.error('Cancion no encontrada:', body.id);
      throw new HttpException('Song not found', HttpStatus.NOT_FOUND)
    }
  }

  @Post('prediction')
  @UseInterceptors(FileInterceptor(''))
  async setPrediction(@Body() body: any) {
    const song = await this.songsTable.findOne({ where: { id: body.id, active: true } });
    if (song) {
      song.tsPrediction = body.prediction;
      await this.songsTable.save(song);
      return {
        message: 'prediction set',
        data: {
          id: body.id,
          prediction: body.prediction
        }
      };
    } else {
      console.error('Cancion no encontrada:', body.id);
      throw new HttpException('Song not found', HttpStatus.NOT_FOUND)
    }
  }
}