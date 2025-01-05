import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { spawn } from 'child_process';
import { SongEntity } from 'src/_entities/song.entity';
import { Repository } from 'typeorm';
import { writeFile } from 'fs/promises';
import * as zlib from 'zlib';

@Injectable()
export class FeatureExtractorService {
  private pool: Array<{
    idSong: number,
    filename: string
  }>;
  private poolBusy: boolean;
  private poolCounter: any;
  private iterator: any

  constructor(
    @InjectRepository(SongEntity)
    private readonly songRepository: Repository<SongEntity>
  ) {
    this.pool = [];
    this.poolBusy = false;
    this.poolCounter = 0;
    this.iterator = null;
  }

  async runExtraction() {
    console.log('runExtraction() executed...');
    if (!this.poolBusy) {
      const songs = await this.songRepository.find({ where: { tsFeatures: null } });
      console.log('Songs queried:', songs.length, 'Loading pool...');
      songs.forEach(async (item, index) => {
        this.pool.push({ idSong: item.id, filename: item.fileName });
      });
      this.iterator = this.pool[Symbol.iterator]();
      this.poolBusy = true;
      console.log('triggering extraction...');
      this.triggerExtraction();
      return {
        message: 'Running extraction',
      }
    } else {
      console.log('The pool is busy. Ended');
      return {
        message: 'pool busy'
      }
    }

  }

  private triggerExtraction() {
    let item = this.iterator.next();
    if (item.done)
      return this.checkPool(item);
    this.poolCounter++;
    const filename = item.value.filename;
    const process = spawn('python', ['../feature_extractor.py', '../uploads/' + filename]);
    let stdout = '';
    let stderr = '';
    process.stdout.on('data', (data) => stdout += data.toString());
    process.stderr.on('data', (data) => stderr += data.toString());

    process.on('close', async (code) => {
      if (code === 0) {
        try {
          const parsedFeatures = JSON.parse(stdout);
          console.log('Features parsed');
          try {
            console.log('Compressing file...')
            const gzipData = zlib.gzipSync(JSON.stringify(parsedFeatures));
            const gzipFilename = filename + '.json.gz';
            console.log('File compressed. Saving on ../features');
            await writeFile('../features/' + gzipFilename, gzipData);
            const row = await this.songRepository.findOneBy({ id: item.value.idSong });
            if (row) {
              row.tsFeatures = gzipFilename;
              await this.songRepository.save(row);
              this.checkPool(item);
            } else {
              console.error('Error al modificar registro: La canción no existe en la base de datos')
              this.checkPool(item);
            }
          } catch (error) {
            console.error('Error compressing features:', error);
            this.checkPool(item);
          }
        } catch (parseError) {
          console.error('Error al parsear las características extraidas:', parseError);
          this.checkPool(item);
        }
      } else {
        console.error('Error al extraer características:', stderr);
        this.checkPool(item);
      }
    });
  }

  private checkPool(item: any) {
    console.log('checking pool...');
    if (!item.done) {
      console.log('triggering extraction again...');
      this.triggerExtraction();
    } else {
      this.pool = [];
      this.poolCounter = 0;
      this.poolBusy = false;
      console.log('The pool is finished and ready for next extraction.')
    }
  }
}


