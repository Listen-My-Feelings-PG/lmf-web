import { Component, effect, EventEmitter, Input, Output, signal, SimpleChanges, AfterViewChecked } from '@angular/core';
import { Calibration, Playlist } from '../_types/generals.interfaces';
import { Song } from '../_types/generals.models';
import { environment } from '../../environments/environment';
import { ColumnDef, createAngularTable, getCoreRowModel, getFilteredRowModel, getPaginationRowModel, getSortedRowModel } from '@tanstack/angular-table';
import { GlobalPlaylistService } from '../_services/global-playlist.service';
import { Chart, registerables } from 'chart.js';

Chart.register(...registerables);

@Component({
  selector: 'app-stats-list',
  imports: [],
  templateUrl: './stats-list.component.html',
  styleUrl: './stats-list.component.scss'
})
export class StatsListComponent implements AfterViewChecked {
  @Input('list') list: Array<Song>;
  @Output('onSelectSong') onSelectSong: EventEmitter<Song>;
  songPlaying: Song | null;
  currentPlaylist: Playlist | null;

  // Chart
  expandedSongId = signal<number | null>(null);
  private chartInstances = new Map<number, Chart>();
  private expandedChart: Chart | null = null;
  private renderedChartIds = new Set<number>();

  // TanStack Table signals
  data = signal<Song[]>([]);
  globalFilter = signal('');
  columnOrder = signal<string[]>([
    'id', 'fileName', 'userScore', 'modelPrediction', 'tsTrainLevelGlobal', 'chart'
  ]);
  selectedRows = signal<Set<number>>(new Set());
  hoveredRow = signal<number | null>(null);

  // Helper methods for template
  Math = Math;

  // Environment thresholds
  env = environment;

  // Configuración de paginación
  maxPageButtons = 7;

  // Define columns for TanStack Table
  columns: ColumnDef<Song>[] = [
    { accessorKey: 'id', id: 'id', header: '#', cell: info => info.getValue(), size: 60, minSize: 60, maxSize: 80 },
    { accessorKey: 'fileName', id: 'fileName', header: 'Nombre de archivo', cell: info => info.getValue(), minSize: 200 },
    { accessorKey: 'userScore', id: 'userScore', header: 'Rating', cell: info => info.getValue(), enableSorting: false, size: 130, minSize: 130, maxSize: 130 },
    { accessorFn: row => row, id: 'modelPrediction', header: 'Predicción', cell: info => info.getValue(), enableSorting: false, size: 180, minSize: 180, maxSize: 180 },
    { accessorKey: 'tsTrainLevelGlobal', id: 'tsTrainLevelGlobal', header: 'Nivel Entren. Global', cell: info => info.getValue(), size: 120, minSize: 100, maxSize: 150 },
    { id: 'chart', header: 'Gráfica', cell: () => null, enableSorting: false, enableResizing: false, size: 500, minSize: 500 },
  ];

  // Create TanStack Table instance
  table = createAngularTable(() => ({
    data: this.data(), columns: this.columns, columnOrder: this.columnOrder(),
    state: {
      globalFilter: this.globalFilter(),
      columnOrder: this.columnOrder(),
    },
    onGlobalFilterChange: (updater) => {
      if (typeof updater === 'function')
        this.globalFilter.set(updater(this.globalFilter()));
      else
        this.globalFilter.set(updater);
    },
    onColumnOrderChange: (updater) => {
      if (typeof updater === 'function')
        this.columnOrder.set(updater(this.columnOrder()));
      else
        this.columnOrder.set(updater);
    }, enableColumnResizing: true, columnResizeMode: 'onChange' as const, getCoreRowModel: getCoreRowModel(), getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(), getPaginationRowModel: getPaginationRowModel(),
    autoResetPageIndex: false,
    initialState: { pagination: { pageSize: 10, }, },
  }));

  constructor(private globalPlaylist: GlobalPlaylistService) {
    this.list = [];
    this.currentPlaylist = null;
    this.songPlaying = null;
    this.onSelectSong = new EventEmitter<Song>();
    effect(() => {
      const songPlaying = this.globalPlaylist.currentSong();
      if (songPlaying) {
        const indexInList = this.list.findIndex(song => song.id === songPlaying.id);
        if (indexInList !== -1) {
          const isNewSong = songPlaying.id !== this.songPlaying?.id;
          const isScoreChanged = songPlaying.userScore !== this.list[indexInList].userScore;

          if (isNewSong || isScoreChanged) {
            this.list[indexInList] = songPlaying;
            this.data.set([...this.list]);
          }
        }
        this.songPlaying = songPlaying;
      }
    });
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (this.list.length) {
      this.destroyAllCharts();
      this.data.set(this.list);
    }
  }

  ngAfterViewChecked(): void {
    this.renderVisibleCharts();
  }

  ngOnDestroy(): void {
    this.destroyAllCharts();
  }

  selectSong(song: Song): void {
    this.onSelectSong.emit(song);
  }

  isPlaying(song: Song): boolean {
    return this.songPlaying?.id === song.id;
  }

  toggleRowSelection(songId: number): void {
    const selected = this.selectedRows();
    const newSelected = new Set(selected);
    if (newSelected.has(songId))
      newSelected.delete(songId);
    else
      newSelected.add(songId);
    this.selectedRows.set(newSelected);
  }

  isRowSelected(songId: number): boolean {
    return this.selectedRows().has(songId);
  }

  onSearchChange(value: string): void {
    this.globalFilter.set(value);
  }

  setPageSize(size: number): void {
    this.destroyAllCharts();
    this.table.setPageSize(size);
  }

  // Chart methods
  private destroyAllCharts(): void {
    this.chartInstances.forEach(chart => chart.destroy());
    this.chartInstances.clear();
    this.renderedChartIds.clear();
    this.destroyExpandedChart();
  }

  private destroyExpandedChart(): void {
    if (this.expandedChart) {
      this.expandedChart.destroy();
      this.expandedChart = null;
    }
  }

  private renderVisibleCharts(): void {
    const rows = this.table.getRowModel().rows;
    for (const row of rows) {
      const song = row.original;
      if (!song.stats?.length || !song.id) continue;

      // Mini chart
      if (this.renderedChartIds.has(song.id)) {
        const existing = this.chartInstances.get(song.id);
        if (!existing?.canvas?.isConnected) {
          existing?.destroy();
          this.chartInstances.delete(song.id);
          this.renderedChartIds.delete(song.id);
        }
      }

      if (!this.renderedChartIds.has(song.id)) {
        const canvas = document.getElementById(`chart-${song.id}`) as HTMLCanvasElement;
        if (canvas) {
          this.renderedChartIds.add(song.id);
          this.renderMiniChart(song, canvas);
        }
      }

      // Expanded chart
      if (this.expandedSongId() === song.id) {
        const expandedCanvas = document.getElementById(`expanded-chart-${song.id}`) as HTMLCanvasElement;
        if (expandedCanvas && !this.expandedChart) {
          this.renderExpandedChart(song, expandedCanvas);
        }
      }
    }
  }

  // 350 entrenamientos → 303rem (proporción base)
  private readonly REM_PER_TRAINING = 303 / 350;
  private readonly SCROLL_THRESHOLD = 100;

  getExpandedChartWidth(song: Song): string {
    const count = song.stats?.length ?? 0;
    if (count <= this.SCROLL_THRESHOLD) return '100%';
    return `${(count * this.REM_PER_TRAINING).toFixed(1)}rem`;
  }

  toggleExpandedChart(song: Song): void {
    if (this.expandedSongId() === song.id) {
      this.expandedSongId.set(null);
      this.destroyExpandedChart();
    } else {
      this.destroyExpandedChart();
      this.expandedSongId.set(song.id!);
    }
  }

  private renderMiniChart(song: Song, canvas: HTMLCanvasElement): void {
    if (this.chartInstances.has(song.id!)) {
      this.chartInstances.get(song.id!)!.destroy();
    }

    const stats = [...song.stats!].sort(
      (a, b) => new Date(a.interactionDate).getTime() - new Date(b.interactionDate).getTime()
    );

    const labels = stats.map((_, i) => `${i + 1}`);
    const accuracyData = stats.map(s => s.prediction?.accuracy != null ? +s.prediction.accuracy : null);

    const ctx = canvas.getContext('2d')!;
    const gradient = ctx.createLinearGradient(0, 0, 0, canvas.parentElement?.clientHeight || 26);
    gradient.addColorStop(0, '#46f0be');
    gradient.addColorStop(0.5, '#f0c81e');
    gradient.addColorStop(1, '#fa6400');

    const fillGradient = ctx.createLinearGradient(0, 0, 0, canvas.parentElement?.clientHeight || 26);
    fillGradient.addColorStop(0, 'rgba(70, 240, 190, 0.15)');
    fillGradient.addColorStop(1, 'rgba(250, 100, 0, 0.03)');

    this.chartInstances.set(song.id!, new Chart(canvas, {
      type: 'line',
      data: {
        labels,
        datasets: [{
          data: accuracyData,
          borderColor: gradient,
          backgroundColor: fillGradient,
          borderWidth: 1.5,
          pointRadius: 0,
          pointHoverRadius: 0,
          tension: 0.4,
          fill: true,
          spanGaps: true,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        events: [],
        plugins: { legend: { display: false }, tooltip: { enabled: false } },
        scales: {
          y: { display: false, beginAtZero: true, max: 100 },
          x: { display: false }
        }
      }
    }));
  }

  private renderExpandedChart(song: Song, canvas: HTMLCanvasElement): void {
    const stats = [...song.stats!].sort(
      (a, b) => new Date(a.interactionDate).getTime() - new Date(b.interactionDate).getTime()
    );

    const labels = stats.map((_, i) => `#${i + 1}`);
    const accuracyData = stats.map(s => s.prediction?.accuracy != null ? +s.prediction.accuracy : null);

    const ctx = canvas.getContext('2d')!;
    const h = canvas.parentElement?.clientHeight || 200;
    const gradient = ctx.createLinearGradient(0, 0, 0, h);
    gradient.addColorStop(0, '#46f0be');
    gradient.addColorStop(0.5, '#f0c81e');
    gradient.addColorStop(1, '#fa6400');

    const fillGradient = ctx.createLinearGradient(0, 0, 0, h);
    fillGradient.addColorStop(0, 'rgba(70, 240, 190, 0.2)');
    fillGradient.addColorStop(0.5, 'rgba(240, 200, 30, 0.1)');
    fillGradient.addColorStop(1, 'rgba(250, 100, 0, 0.05)');

    this.expandedChart = new Chart(canvas, {
      type: 'line',
      data: {
        labels,
        datasets: [{
          label: 'Precisi\u00f3n (%)',
          data: accuracyData,
          borderColor: gradient,
          backgroundColor: fillGradient,
          borderWidth: 2,
          pointBackgroundColor: accuracyData.map(v => {
            if (v == null) return '#9ca3af';
            if (v >= 80) return '#46f0be';
            if (v >= 50) return '#f0c81e';
            return '#fa6400';
          }),
          pointBorderColor: accuracyData.map(v => {
            if (v == null) return '#9ca3af';
            if (v >= 80) return '#46f0be';
            if (v >= 50) return '#f0c81e';
            return '#fa6400';
          }),
          pointRadius: 4,
          pointHoverRadius: 7,
          tension: 0.3,
          fill: true,
          spanGaps: true,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: 'rgba(17, 24, 39, 0.95)',
            titleColor: '#46f0be',
            bodyColor: '#d1d5db',
            borderColor: '#374151',
            borderWidth: 1,
            padding: 10,
            displayColors: false,
            callbacks: {
              title: (items) => {
                const cal = stats[items[0].dataIndex];
                return `Predicción #${items[0].dataIndex + 1} — ${new Date(cal.interactionDate).toLocaleString()}`;
              },
              label: () => '',
              afterBody: (items) => {
                const cal = stats[items[0].dataIndex];
                return [
                  `ID: ${cal.id}`,
                  `Canci\u00f3n ID: ${cal.songId}  |  Modelo ID: ${cal.modelId}`,
                  `Predicción: ${cal.prediction?.score != null ? (+cal.prediction.score).toFixed(5) : 'N/A'}`,
                  `Precisión: ${cal.prediction?.accuracy != null ? (+cal.prediction.accuracy).toFixed(4) + '%' : 'N/A'}`,
                  `User Score: ${cal.userScore ?? 'N/A'}`,
                  `Último Entren. ID: ${cal.prediction?.idLastFit ?? 'N/A'}`,
                ];
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 100,
            ticks: { color: '#9ca3af', font: { size: 10 } },
            grid: { color: 'rgba(75, 85, 99, 0.3)' },
            title: { display: true, text: 'Precisi\u00f3n (%)', color: '#9ca3af', font: { size: 11 } }
          },
          x: {
            ticks: { color: '#9ca3af', font: { size: 10 } },
            grid: { color: 'rgba(75, 85, 99, 0.3)' },
            title: { display: true, text: 'Interacci\u00f3n', color: '#9ca3af', font: { size: 11 } }
          }
        }
      }
    });
  }

  // Calcula qué números de página mostrar en la paginación
  getPageNumbers(): (number | '...')[] {
    const currentPage = this.table.getState().pagination.pageIndex;
    const totalPages = this.table.getPageCount();

    if (totalPages <= this.maxPageButtons)
      return Array.from({ length: totalPages }, (_, i) => i);


    const pages: (number | '...')[] = [];
    const halfButtons = Math.floor(this.maxPageButtons / 2);
    let startPage = Math.max(0, currentPage - halfButtons);
    let endPage = Math.min(totalPages - 1, startPage + this.maxPageButtons - 1);

    // Ajustar si estamos cerca del final
    if (endPage - startPage < this.maxPageButtons - 1) {
      startPage = Math.max(0, endPage - this.maxPageButtons + 1);
    }

    // Siempre mostrar primera página
    if (startPage > 0) {
      pages.push(0);
      if (startPage > 1)
        pages.push('...');

    }

    // Páginas en el rango
    for (let i = startPage; i <= endPage; i++) {
      pages.push(i);
    }

    // Siempre mostrar última página
    if (endPage < totalPages - 1) {
      if (endPage < totalPages - 2) {
        pages.push('...');
      }
      pages.push(totalPages - 1);
    }

    return pages;
  }
}
