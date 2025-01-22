import { Injectable } from '@angular/core';

export interface SpectrogramSpecs {
  maxValue: number,
  firstIndex: number,
  lastIndex: number
  resized: Array<Array<number>>,
  interval: number
}

@Injectable({
  providedIn: 'root'
})
export class SongFeaturesService {
  constructor() { }
  customizeSpectrogram(mel_spectrogram: Array<Array<number>>, tempo: number, extendTempo: boolean): Promise<SpectrogramSpecs> {
    return new Promise((resolve) => {
      let control: { firstIndex: number, lastIndex: number, maxValue: number } = {
        firstIndex: -1, lastIndex: 20000, maxValue: 0
      };
      mel_spectrogram.forEach((row: any[], y: any) => {
        row.forEach((column, x) => {
          if (column > 0 && control.firstIndex == -1)
            control.firstIndex = x;
          else if (column > 0 && control.firstIndex > x)
            control.firstIndex = x;

          if (row[19999 - x] > 0 && control.lastIndex == 20000)
            control.lastIndex = 19999 - x;
          else if (row[19999 - x] > 0 && control.lastIndex < (19999 - x))
            control.lastIndex = 19999 - x;

          if (column > control.maxValue)
            control.maxValue = column;
        })
      });

      let interval = Math.trunc((control.lastIndex - control.firstIndex) / tempo);
      let resized = mel_spectrogram.map((obj) => {
        let row: Array<any> = [];

        for (let i = 0; i < 20000; i++) {
          row.push(obj[i]);
        }
        return row;
      });
      resized.push([]);
      for (let i = 0; i < 20000; i++) {
        if ((!extendTempo && i < control.lastIndex) || extendTempo)
          resized[128].push(i % interval == 0 ? 1 : 0);
        else
          resized[128].push(0);

      }

      resolve({
        resized,
        maxValue: control.maxValue,
        firstIndex: control.firstIndex,
        lastIndex: control.lastIndex,
        interval
      });
    });
  }

}
