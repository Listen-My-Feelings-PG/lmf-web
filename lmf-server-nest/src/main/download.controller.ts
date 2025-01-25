import { Controller, Get, Query, Res, HttpException, HttpStatus, UsePipes } from '@nestjs/common';
import { Response } from 'express';
import * as fs from 'fs';
import * as path from 'path';
import * as zlib from 'zlib';
import { IntegerDto } from '../_pipes/integer-dto.pipe';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { SongEntity } from '../_entities/song.entity';
import { ConfigService } from '@nestjs/config';

@Controller('download')
export class DownloadController {
  constructor(
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) { }

  @Get('tsfeatures')
  @UsePipes(IntegerDto)
  async getTsFeatures(@Query('value') value: number, @Res() res: Response): Promise<void> {
    try {
      const song = await this.songRepository.findOne({ where: { id: value, active: true } });
      if (!song)
        throw new HttpException('Song not found', HttpStatus.NOT_FOUND);

      const tsFeaturesPath = song.tsFeatures;
      const basePath = this.cf.get<string>('TS_PATH_FEATURES');

      if (!basePath)
        throw new HttpException('TS_PATH_FEATURES not configured in .env', HttpStatus.INTERNAL_SERVER_ERROR);

      const fullPath = path.join(basePath, tsFeaturesPath);

      // Validar existencia del archivo
      if (!fs.existsSync(fullPath))
        throw new HttpException('File not found', HttpStatus.NOT_FOUND);

      const compressedBuffer = fs.readFileSync(fullPath);
      const decompressedData = zlib.gunzipSync(compressedBuffer).toString('utf-8');

      res.setHeader('Content-Type', 'application/json');
      res.send(JSON.parse(decompressedData));
    } catch (error) {
      if (error instanceof HttpException)
        throw error;
      console.error(error);
      throw new HttpException('Internal Server Error', HttpStatus.INTERNAL_SERVER_ERROR);
    }
  }
}

