import {
  Component, OnDestroy, OnChanges, SimpleChanges,
  Input, signal, Output, EventEmitter, effect
} from '@angular/core';
import { Playlist, Song } from '../_types/generals.models';
import { GlobalPlaylistService } from '../_services/global-playlist.service';
import { HttpService } from '../_services/http.service';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import {
  createAngularTable,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  getSortedRowModel,
  ColumnDef,
} from '@tanstack/angular-table';
import { UserScore } from '../_types/generals.interfaces';
import { environment } from '../../environments/environment';

@Component({
  selector: 'app-list',
  imports: [CommonModule, FormsModule],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent implements OnDestroy, OnChanges {
  @Input('list') list: Array<Song>;
  @Input('lockRate') lockRate: boolean;
  @Input('showTuneButton') showTuneButton: boolean;
  @Input('predictMode') predictMode: boolean;
  @Output('onSelectSong') onSelectSong: EventEmitter<Song>;
  @Output('onRateSong') onRateSong: EventEmitter<{ song: Song, score: UserScore }>;
  @Output('onTuneSong') onTuneSong: EventEmitter<number>;
  @Output('onPredictSelected') onPredictSelected: EventEmitter<number[]>;

  songPlaying: Song | null;
  currentPlaylist: Playlist | null;

  // TanStack Table signals
  data = signal<Song[]>([]);
  globalFilter = signal('');
  columnOrder = signal<string[]>([
    'id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'accuracy', 'tsTrainLevelGlobal', 'fileName'
  ]);
  selectedRows = signal<Set<number>>(new Set());
  hoveredRow = signal<number | null>(null);
  isCopyingOnboard = signal(false);

  // Helper methods for template
  Math = Math;

  // Environment thresholds
  env = environment;

  // Configuración de paginación
  maxPageButtons = 7; // Número de botones de página a mostrar

  // Define columns for TanStack Table
  allColumns: ColumnDef<Song>[] = [
    { accessorKey: 'id', id: 'id', header: '#', cell: info => info.getValue(), size: 60, minSize: 60, maxSize: 80, },
    { accessorFn: row => row.metadata?.title, id: 'title', header: 'Título', cell: info => info.getValue() || '-', size: 200, minSize: 150, },
    { accessorFn: row => row.metadata?.artist, id: 'artist', header: 'Artista', cell: info => info.getValue() || '-', size: 150, minSize: 120, },
    { accessorFn: row => row.metadata?.album, id: 'album', header: 'Álbum', cell: info => info.getValue() || '-', size: 150, minSize: 120, },
    { accessorKey: 'userScore', id: 'userScore', header: 'Rating', cell: info => info.getValue(), size: 130, minSize: 130, maxSize: 130, },
    { accessorFn: row => row.tsPrediction != null ? +row.tsPrediction : null, id: 'modelPrediction', header: 'Predicción', cell: info => info.getValue(), size: 180, minSize: 180, maxSize: 180, },
    { accessorKey: 'tsTrainLevelGlobal', id: 'tsTrainLevelGlobal', header: 'Nivel Entren. Global', cell: info => info.getValue(), size: 120, minSize: 100, maxSize: 150, },
    { accessorKey: 'accuracy', id: 'accuracy', header: 'Precisión', cell: info => info.getValue(), size: 100, minSize: 80, maxSize: 130, },
    { id: 'tune', header: '', cell: () => null, enableSorting: false, enableResizing: false, size: 50, minSize: 50, maxSize: 50, },
    { accessorKey: 'fileName', id: 'fileName', header: 'Nombre de archivo', cell: info => info.getValue(), minSize: 200, },
  ];
  columns = signal<ColumnDef<Song>[]>(this.allColumns.filter(c => c.id !== 'tune'));

  // Create TanStack Table instance
  table = createAngularTable(() => ({
    data: this.data(), columns: this.columns(), columnOrder: this.columnOrder(),
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

  constructor(private globalPlaylist: GlobalPlaylistService, private httpService: HttpService) {
    this.list = [];
    this.currentPlaylist = null;
    this.songPlaying = null;
    this.onSelectSong = new EventEmitter<Song>();
    this.onRateSong = new EventEmitter<{ song: Song, score: UserScore }>();
    this.lockRate = false;
    this.showTuneButton = false;
    this.predictMode = false;
    this.onTuneSong = new EventEmitter<number>();
    this.onPredictSelected = new EventEmitter<number[]>();

    // Effect en constructor (contexto de inyección válido)
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

  trainSingleSong(idSong: number): void {
    this.onTuneSong.emit(idSong);
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['list'] && changes['list'].currentValue) {
      this.data.set(this.list);
    }
    if (changes['showTuneButton']) {
      if (this.showTuneButton) {
        this.columns.set(this.allColumns);
        this.columnOrder.set([
          'id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'accuracy', 'tsTrainLevelGlobal', 'tune', 'fileName'
        ]);
      } else {
        this.columns.set(this.allColumns.filter(c => c.id !== 'tune'));
        this.columnOrder.set([
          'id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'accuracy', 'tsTrainLevelGlobal', 'fileName'
        ]);
      }
    }
  }

  selectSong(song: Song): void {
    this.onSelectSong.emit(song);
  }

  rateSong(song: Song, score: UserScore): void {
    this.onRateSong.emit({ song, score });
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

  // 'all' | 'some' | 'none'
  selectAllState(): 'all' | 'some' | 'none' {
    const filteredIds = this.table.getFilteredRowModel().rows.map(r => r.original.id!);
    if (filteredIds.length === 0) return 'none';
    const selected = this.selectedRows();
    const checkedCount = filteredIds.filter(id => selected.has(id)).length;
    if (checkedCount === 0) return 'none';
    if (checkedCount === filteredIds.length) return 'all';
    return 'some';
  }

  toggleSelectAll(): void {
    const filteredIds = this.table.getFilteredRowModel().rows.map(r => r.original.id!);
    const state = this.selectAllState();
    if (state === 'all') {
      // Deseleccionar todas las filtradas
      const newSelected = new Set(this.selectedRows());
      filteredIds.forEach(id => newSelected.delete(id));
      this.selectedRows.set(newSelected);
    } else {
      // Seleccionar todas las filtradas
      const newSelected = new Set(this.selectedRows());
      filteredIds.forEach(id => newSelected.add(id));
      this.selectedRows.set(newSelected);
    }
  }

  onSearchChange(value: string): void {
    this.globalFilter.set(value);
  }

  setPageSize(size: number): void {
    this.table.setPageSize(size);
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

  getCircularProgressStyle(value: number | null): string {
    if (value === null) return 'conic-gradient(#4b5563 360deg, #4b5563 0deg)';
    const percentage = Math.round(value);
    const degrees = (percentage / 100) * 360;
    return `conic-gradient(#46f0be ${degrees}deg, #374151 ${degrees}deg)`;
  }

  ngOnDestroy(): void {
    // Los effects se limpian automáticamente
  }

  async copyToOnboard(): Promise<void> {
    const ids = Array.from(this.selectedRows());
    if (ids.length === 0) return;
    this.isCopyingOnboard.set(true);
    try {
      await this.httpService.copySelectedSongsToOnboard(ids);
    } catch (error) {
      console.error('Error al copiar canciones al onboarding:', error);
    } finally {
      this.isCopyingOnboard.set(false);
    }
  }

  predictSelected(): void {
    const ids = Array.from(this.selectedRows());
    if (ids.length === 0) return;
    this.onPredictSelected.emit(ids);
  }
}
