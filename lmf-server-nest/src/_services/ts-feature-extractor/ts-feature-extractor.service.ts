import { Injectable } from '@nestjs/common';
import { exec, spawn } from 'child_process';

@Injectable()
export class TsFeatureExtractorService {
  async extractFeature(filePath: string): Promise<any> {
    return new Promise((resolve, reject) => {
      const process = spawn('python', ['../feature_extractor.py', filePath]);
      let stdout = '';
      let stderr = '';
      process.stdout.on('data', (data) => stdout += data.toString());
      process.stderr.on('data', (data) => stderr += data.toString());

      process.on('close', (code) => {
        if (code !== 0) {
          console.error('Error al extraer características:', stderr);
          return reject(new Error('Error al ejecutar el script de extracción de características.'));
        }
        try {
          const parsedFeatures = JSON.parse(stdout);
          resolve(parsedFeatures);
        } catch (parseError) {
          console.error('Error al parsear las características extraídas:', parseError);
          reject(new Error('Error al procesar los datos de extracción.'));
        }
      });
    });
  }
}
