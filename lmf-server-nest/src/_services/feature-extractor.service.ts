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
    private readonly tableSongs: Repository<SongEntity>,
    private readonly cf: ConfigService
  ) {
    this.pool = [];
    this.poolBusy = false;
    this.poolCounter = 0;
    this.iterator = null;
  }

  async runExtraction() {
    if (!this.poolBusy) {
      const songs = await this.tableSongs.find({ where: { tsFeatures: IsNull() } });
      if (songs.length > 0)
        console.info('Songs features extraction queried:', songs.length, 'Loading pool...', new Date().toLocaleString());
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
    const item = this.iterator.next();
    if (item.done)
      return this.checkPool(item);
    this.poolCounter++;
    const filename = item.value.filename;
    const process = spawn('python', ['../feature_extractor.py', this.cf.get<string>('TS_PATH_UPLOADS') + '/' + filename]);
    let stdout = '';
    let stderr = '';
    process.stdout.on('data', (data) => stdout += data.toString());
    process.stderr.on('data', (data) => stderr += data.toString());
    process.on('close', async (code) => {
      if (code === 0) {
        try {
          const parsedFeatures = JSON.parse(stdout);
          try {
            const destPath = this.cf.get<string>('TS_PATH_FEATURES');
            const gzipData = zlib.gzipSync(JSON.stringify(parsedFeatures));
            const gzipFilename = filename + '.json.gz';
            await writeFile(destPath + '/' + gzipFilename, gzipData);
            const row = await this.tableSongs.findOneBy({ id: item.value.idSong });
            if (row) {
              row.tsFeatures = gzipFilename;
              await this.tableSongs.save(row);
              console.info('File compressed:', gzipFilename, new Date().toLocaleString());
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
        console.info('The songs features extraction pool is finished and ready for next extraction', new Date().toLocaleString());
    }
  }

  async decompressGzipFile(file: File): Promise<any> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const buffer = Buffer.from(new Uint8Array(reader.result as ArrayBuffer));
        zlib.gunzip(buffer, (err, decompressedBuffer) => {
          if (err) {
            console.error('Error descomprimiendo el archivo gzip:', err);
            return reject(err);
          } else {
            try {
              const json = JSON.parse(decompressedBuffer.toString());
              return resolve(json);
            } catch (parseError) {
              console.error('Error parseando el JSON:', parseError);
              return reject(parseError);
            }
          }
        });
      };
      reader.onerror = () => {
        console.error('Error leyendo el archivo:', reader.error);
        reject(reader.error);
      };
      reader.readAsArrayBuffer(file);
    });
  }
}


