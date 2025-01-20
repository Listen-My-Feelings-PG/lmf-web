import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { spawn } from 'child_process';
import { SongEntity } from 'src/_entities/song.entity';
import { IsNull, Repository } from 'typeorm';
import { writeFile } from 'fs/promises';
import * as zlib from 'zlib';
import { ConfigService } from '@nestjs/config';

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
    private readonly songRepository: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) {
    this.pool = [];
    this.poolBusy = false;
    this.poolCounter = 0;
    this.iterator = null;
  }

  async runExtraction() {
    if (!this.poolBusy) {
      const songs = await this.songRepository.find({ where: { tsFeatures: IsNull() } });
      if (songs.length > 0)
        console.info('Songs queried:', songs.length, 'Loading pool...', new Date().toLocaleString());
      songs.forEach(async (item, index) => {
        this.pool.push({ idSong: item.id, filename: item.fileName });
      });
      this.iterator = this.pool[Symbol.iterator]();
      this.poolBusy = true;
      this.triggerExtraction();
      return {
        message: 'Running extraction',
      }
    } else {
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
    const process = spawn('python', ['../feature_extractor.py', this.cf.get<string>('PATH_UPLOADS') + '/' + filename]);
    let stdout = '';
    let stderr = '';
    process.stdout.on('data', (data) => stdout += data.toString());
    process.stderr.on('data', (data) => stderr += data.toString());

    process.on('close', async (code) => {
      if (code === 0) {
        try {
          const parsedFeatures = JSON.parse(stdout);
          let { mel_spectrogram, tempo } = parsedFeatures;
          let maxValue = 0;
          let first10Columns = [];
          let last10Columns = [];
          mel_spectrogram.forEach((itemY, indexY) => {
            let first10Rows = [];
            let last10Rows = [];
            itemY.forEach((itemX, indexX) => {
              if (itemX > maxValue)
                maxValue = itemX;
              if (indexX < 10)
                first10Rows.push(itemX);
              if (indexX >= itemY.length - 10)
                last10Rows.push(itemX);
            });
            first10Columns.push(first10Rows);
            last10Columns.push(last10Rows);
          });
          console.log('maxValue', maxValue);
          console.log('first10Columns', first10Columns);
          console.log('last10Columns', last10Columns);
          try {
            const destPath = this.cf.get<string>('PATH_FEATURES');
            const gzipData = zlib.gzipSync(JSON.stringify(parsedFeatures));
            const gzipFilename = filename + '.json.gz';
            await writeFile(destPath + '/' + gzipFilename, gzipData);
            const row = await this.songRepository.findOneBy({ id: item.value.idSong });
            if (row) {
              row.tsFeatures = gzipFilename;
              await this.songRepository.save(row);
              console.info('File compressed:', gzipFilename);
              this.checkPool(item);
            } else {
              console.error('Error al modificar registro: La canción no existe en la base de datos', new Date().toLocaleString())
              this.checkPool(item);
            }
          } catch (error) {
            console.error('Error compressing features:', error, new Date().toLocaleString());
            this.checkPool(item);
          }
        } catch (parseError) {
          console.error('Error al parsear las características extraidas:', parseError, new Date().toLocaleString());
          this.checkPool(item);
        }
      } else {
        console.error('Error al extraer características:', stderr, new Date().toLocaleString());
        this.checkPool(item);
      }
    });
  }

  private checkPool(item: any) {
    let hideMessage = false;
    if (!item.done)
      this.triggerExtraction();
    else {
      if (this.pool.length === 0)
        hideMessage = true;
      this.pool = [];
      this.poolCounter = 0;
      this.poolBusy = false;
      if (!hideMessage)
        console.info('The pool is finished and ready for next extraction');
    }
  }

  async decompressGzipFile(file: File): Promise<any> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const buffer = Buffer.from(new Uint8Array(reader.result as ArrayBuffer));
        zlib.gunzip(buffer, (err, decompressedBuffer) => {
          if (err) {
            reject(new Error('Error descomprimiendo el archivo gzip: ' + err.message,));
          } else {
            try {
              const json = JSON.parse(decompressedBuffer.toString());
              resolve(json);
            } catch (parseError) {
              reject(new Error('Error parseando el JSON: ' + parseError.message));
            }
          }
        });
      };
      reader.onerror = () => {
        reject(new Error('Error leyendo el archivo: ' + reader.error?.message));
      };
      reader.readAsArrayBuffer(file);
    });
  }
}


