import { Injectable } from '@nestjs/common';
import { exec } from 'child_process';

@Injectable()
export class TsFeatureExtractorService {
  async extractFeature(filePath: string): Promise<any> {
    return new Promise((resolve, reject) => {
      exec(`python ../feature_extractor.py ${filePath}`, (error, stdout) => {
        if (error) {
          console.error('Error al extraer características:', error);
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
