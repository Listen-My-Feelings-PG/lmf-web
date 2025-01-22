import { AfterViewInit, Component, ElementRef, ViewChild } from '@angular/core';
import { HttpService } from '../../_services/http.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-spectrogram-viewer',
  standalone: true,
  imports: [
    CommonModule,

    FormsModule
  ],
  templateUrl: './spectrogram-viewer.component.html',
  styleUrl: './spectrogram-viewer.component.scss'
})
export class SpectrogramViewerComponent implements AfterViewInit {
  @ViewChild('canvas', { static: false }) canvas!: ElementRef<HTMLCanvasElement>;
  idSong: number;
  loader: {
    pool: Array<Array<number>>
    busy: boolean,
    indexX: number,
    indexY: number,
    iterator: any
  }

  spec: {
    maxValue: number,
    firstIndex: number,
    lastIndex: number
  }

  ctx!: CanvasRenderingContext2D;

  constructor(public http: HttpService) {
    this.idSong = 600;
    this.loader = {
      pool: [],
      busy: false,
      iterator: null,
      indexX: -1,
      indexY: -1
    }
    this.spec = {
      maxValue: 0,
      firstIndex: 0,
      lastIndex: 0
    }
  }

  ngAfterViewInit(): void {
    const canvas = this.canvas.nativeElement;
    canvas.width = 20000;
    canvas.height = 129;
    this.ctx = canvas.getContext('2d')!;
  }

  draw(x: number, y: number, v: number) {
    return new Promise((resolve, reject) => {
      const size = 2;
      const clampedIntensity = Math.max(0, Math.min(1, v));
      const colorValue = Math.floor(clampedIntensity * 255);
      const color = v > 1 ? 'red' : `rgb(${colorValue}, ${colorValue}, ${colorValue})`;
      this.ctx.fillStyle = color;
      this.ctx.fillRect(x, y, size, size);
      resolve(v);
    });
  }

  customizeSpectrogram(mel_spectrogram: Array<Array<number>>, tempo: number): Promise<{
    maxValue: number,
    firstIndex: number,
    lastIndex: number
    resized: Array<Array<number>>,
    interval: number
  }> {
    return new Promise((resolve, reject) => {
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
      resolve({
        resized: mel_spectrogram.map((obj, index) => {
          let row: Array<any> = [];
          if (index == 127)
            for (let i = control.firstIndex; i < control.lastIndex + 1; i++) {
              row.push(interval % tempo === 0 ? 1 : 0);
            }
          else
            for (let i = control.firstIndex; i < control.lastIndex + 1; i++) {
              row.push(obj[i]);
            }
          return row;
        }),
        maxValue: control.maxValue,
        firstIndex: control.firstIndex,
        lastIndex: control.lastIndex,
        interval
      });
    })

  }

  stopLoading() {
    this.loader.pool = [];
    this.loader.iterator = this.loader.pool[Symbol.iterator]();
  }

  loadSpectrogram(): void {
    const that = this;
    console.log('idSong', this.idSong);
    this.canvas.nativeElement
    this.http.get(`download/tsfeatures?value=${this.idSong}`, true).subscribe({
      next: async (data) => {
        this.customizeSpectrogram(data.mel_spectrogram, data.tempo).then((res) => {
          console.log('res.interval', res.interval, res.resized.length);
          res.resized.push([]);
          
          for (let i = res.firstIndex; i <= res.lastIndex; i++) {
            res.resized[128].push(i % res.interval == 0 ? 1 : 0);
          }

          this.loader.pool = res.resized;
          this.spec = {
            firstIndex: res.firstIndex,
            lastIndex: res.lastIndex,
            maxValue: res.maxValue
          }
          if (!this.loader.busy) {
            this.loader.iterator = this.loader.pool[Symbol.iterator]();
            this.loader.busy = true;
            triggerRow();
          }

          function triggerRow() {
            let row = that.loader.iterator.next();
            that.loader.indexY++;
            if (row.done)
              return checkPoolRow(row);
            let columns: {
              pool: Array<number>,
              busy: boolean,
              iterator: any
            } = {
              pool: row.value,
              busy: false,
              iterator: null
            };
            if (!columns.busy) {
              columns.iterator = columns.pool[Symbol.iterator]();
              columns.busy = true;
              triggerColumn();
            }

            function triggerColumn() {
              let column = columns.iterator.next();
              that.loader.indexX++;
              if (column.done)
                return checkPoolColumn(column);
              that.draw(that.loader.indexX, that.loader.indexY, column.value).then(() => {
                checkPoolColumn(column)
              });
            }

            function checkPoolColumn(column: any) {
              if (!column.done)
                triggerColumn();
              else {
                columns.pool = [];
                columns.busy = false;
                that.loader.indexX = -1;
                setTimeout(() => triggerRow());
              }
            }

          }

          function checkPoolRow(item: any) {
            if (!item.done)
              triggerRow();
            else {
              that.loader.pool = [];
              that.loader.busy = false;
              that.loader.indexY = -1;
            }
          }
        });
      },
      error: (error) => {
        console.error('Error al obtener características:', error);
      }
    });
  }

}
