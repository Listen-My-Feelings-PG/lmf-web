import { AfterViewInit, Component, ElementRef, OnDestroy, ViewChild } from '@angular/core';
import { HttpService } from '../_services/http.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { SongService } from '../_services/song.service';

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
export class SpectrogramViewerComponent implements AfterViewInit, OnDestroy {
  @ViewChild('canvas', { static: false }) canvas!: ElementRef<HTMLCanvasElement>;
  @ViewChild('overlayCanvas', { static: false }) overlayCanvas!: ElementRef<HTMLCanvasElement>;
  @ViewChild('canvasWrapper', { static: false }) canvasWrapper!: ElementRef<HTMLDivElement>;
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
  overlayCtx!: CanvasRenderingContext2D;
  audio: HTMLAudioElement;
  currentTime: number = 0;
  intervalId: any;

  counter: number;

  constructor(public http: HttpService, public songService: SongService) {
    this.counter = 0;
    this.idSong = 182;
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
    this.audio = new Audio();
  }

  ngAfterViewInit(): void {
    const canvas = this.canvas.nativeElement;
    const overlayCanvas = this.overlayCanvas.nativeElement;
    canvas.width = 20000;
    canvas.height = 129;
    overlayCanvas.width = 20000;
    overlayCanvas.height = 129;
    this.ctx = canvas.getContext('2d')!;
    this.overlayCtx = overlayCanvas.getContext('2d')!;
    this.loadSpectrogram();
  }

  draw(x: number, y: number, v: number): Promise<number> {
    return new Promise((resolve, reject) => {
      try {
        const size = 2;
        const clampedIntensity = Math.max(0, Math.min(1, v));
        const colorValue = Math.floor(clampedIntensity * 255);
        const color = v > 1 ? 'red' : `rgb(${colorValue}, ${colorValue}, ${colorValue})`;
        this.ctx.fillStyle = color;
        this.ctx.fillRect(x, y, size, size);
        return resolve(v);
      } catch (e) {
        console.error('Error al dibujar espectrograma:', e);
        return reject(e);
      }

    });
  }

  playSong(): void {
    this.audio.src = `http://localhost:3000/songs/song/mp3?value=${this.idSong}`; // Cambia la ruta según sea necesario
    this.audio.play();
    this.currentTime = 0;
    this.intervalId = setInterval(() => {
      this.currentTime = this.audio.currentTime; // Actualiza el tiempo actual con el tiempo de la canción
      this.scrollCanvas(this.moveCursor(30, 'rgba(255, 255, 0, 1)', 5));
    }, 8); // Actualiza cada 100 ms
  }

  stopSong(): void {
    this.audio.pause();
    this.audio.currentTime = 0;
    clearInterval(this.intervalId);
    this.overlayCtx.clearRect(0, 0, this.overlayCanvas.nativeElement.width, this.overlayCanvas.nativeElement.height); // Limpia el canvas de la línea
  }

  moveCursor(lineWidth: number, colorFade: string, separation: number): number {
    const step = this.spec.lastIndex / this.audio.duration;
    const realX = Math.floor(this.currentTime * step);
    let x = Math.floor(this.currentTime * step);
    this.overlayCtx.clearRect(0, 0, this.overlayCanvas.nativeElement.width, this.overlayCanvas.nativeElement.height); // Limpia el canvas de la línea

    const gradient1 = this.overlayCtx.createLinearGradient(x, 0, x + lineWidth, 0);
    gradient1.addColorStop(1, colorFade);
    gradient1.addColorStop(0, 'rgba(0, 0, 0, 0)');

    this.overlayCtx.beginPath();

    this.overlayCtx.moveTo(x, 0);
    this.overlayCtx.lineTo(x, this.overlayCanvas.nativeElement.height);
    this.overlayCtx.strokeStyle = gradient1;
    this.overlayCtx.lineWidth = lineWidth * 2;
    this.overlayCtx.stroke();
    this.overlayCtx.closePath();

    x += lineWidth;

    const gradient2 = this.overlayCtx.createLinearGradient(x, 0, x + lineWidth, 0);
    gradient2.addColorStop(1, 'rgba(0, 0, 0, 0)');
    gradient2.addColorStop(0, colorFade);

    this.overlayCtx.beginPath();

    this.overlayCtx.moveTo(x + (separation * 4), 0);
    this.overlayCtx.lineTo(x + (separation * 4), this.overlayCanvas.nativeElement.height);
    this.overlayCtx.strokeStyle = gradient2;
    this.overlayCtx.lineWidth = lineWidth + separation;
    this.overlayCtx.stroke();


    return x;
  }

  stopLoading() {
    this.loader.pool = [];
    this.loader.iterator = this.loader.pool[Symbol.iterator]();
  }

  scrollCanvas(linePos: number): void {
    const x = ((this.overlayCanvas.nativeElement.width / this.spec.lastIndex) * linePos) *
      (this.spec.lastIndex / this.overlayCanvas.nativeElement.width);
    const canvasWrapper = this.canvasWrapper.nativeElement;
    const centerX = canvasWrapper.clientWidth / 2;
    canvasWrapper.scrollLeft = x - centerX;
  }

  loadSpectrogram(): void {
    const that = this;
    this.canvas.nativeElement
    this.http.get(`download/ts-features?value=${this.idSong}`, true).subscribe({
      next: async (data) => {
        that.songService.customizeSpectrogram(data.mel_spectrogram, data.tempo, false).then((res) => {
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
            const row = that.loader.iterator.next();
            that.loader.indexY++;
            if (row.done)
              return checkPoolRow(row);
            const columns: {
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
              const column = columns.iterator.next();
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

  ngOnDestroy(): void {
    clearInterval(this.intervalId); // Limpia el intervalo al destruir el componente
  }

}
