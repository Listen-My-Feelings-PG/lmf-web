import { Injectable } from '@nestjs/common';
import * as zlib from 'zlib';
import * as path from 'path';

@Injectable()
export class GzipConverterService {
  async compressFile(features: any, filename: string): Promise<{ data: Buffer; filePath: string }> {
    try {
      const data = zlib.gzipSync(JSON.stringify(features));
      const filePath = path.resolve('features', `${filename}.json.gz`);
      return {
        data,
        filePath
      };
    } catch (error) {
      console.error('Error compressing features:', error)
      throw new Error('Failed to compress features');
    }
  }

  async decompressFile(file: Buffer): Promise<any> {
    try {
      const decompressed = zlib.gunzipSync(file);
      return JSON.parse(decompressed.toString('utf-8'))
    } catch (error) {
      console.error('Error decompressing file:', error);
    }
  }


}
