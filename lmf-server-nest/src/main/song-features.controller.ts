import { Controller, Get, Query } from '@nestjs/common';

@Controller('song-features')
export class SongFeaturesController {
  @Get('songFeature')
  async getSongFeatures(@Query('id') idSong: string) {
    return {
      message: 'hold on...',
    }
  }
}
