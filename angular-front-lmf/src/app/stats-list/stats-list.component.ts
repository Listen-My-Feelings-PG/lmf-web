import { Component, effect, EventEmitter, Input, Output, signal, SimpleChanges } from '@angular/core';
import { Playlist } from '../_types/generals.interfaces';
import { Song } from '../_types/generals.models';
import { environment } from '../../environments/environment';
import { ColumnDef, createAngularTable, getCoreRowModel, getFilteredRowModel, getPaginationRowModel, getSortedRowModel } from '@tanstack/angular-table';
import { GlobalPlaylistService } from '../_services/global-playlist.service';

@Component({
  selector: 'app-stats-list',
  imports: [],
  templateUrl: './stats-list.component.html',
  styleUrl: './stats-list.component.scss'
})
export class StatsListComponent {
  @Input('list') list: Array<Song>;
  @Output('onSelectSong') onSelectSong: EventEmitter<Song>;
  songPlaying: Song | null;
  currentPlaylist: Playlist | null;

  // TanStack Table signals
  data = signal<Song[]>([]);
  globalFilter = signal('');
  columnOrder = signal<string[]>([
    'id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'accuracy', 'tsTrainLevelGlobal', 'tune', 'fileName'
  ]);
  selectedRows = signal<Set<number>>(new Set());
  hoveredRow = signal<number | null>(null);

  // Helper methods for template
  Math = Math;

  // Environment thresholds
  env = environment;

  // Configuración de paginación
  maxPageButtons = 7; // Número de botones de página a mostrar

  // Define columns for TanStack Table
  columns: ColumnDef<Song>[] = [
    { accessorKey: 'id', id: 'id', header: '#', cell: info => info.getValue(), size: 60, minSize: 60, maxSize: 80, },
    { accessorFn: row => row.metadata?.title, id: 'title', header: 'Título', cell: info => info.getValue() || '-', size: 200, minSize: 150, },
    { accessorFn: row => row.metadata?.artist, id: 'artist', header: 'Artista', cell: info => info.getValue() || '-', size: 150, minSize: 120, },
    { accessorFn: row => row.metadata?.album, id: 'album', header: 'Álbum', cell: info => info.getValue() || '-', size: 150, minSize: 120, },
    { accessorKey: 'userScore', id: 'userScore', header: 'Rating', cell: info => info.getValue(), enableSorting: false, size: 130, minSize: 130, maxSize: 130, },
    { accessorFn: row => row, id: 'modelPrediction', header: 'Predicción', cell: info => info.getValue(), enableSorting: false, size: 180, minSize: 180, maxSize: 180, },
    { accessorKey: 'tsTrainLevelGlobal', id: 'tsTrainLevelGlobal', header: 'Nivel Entren. Global', cell: info => info.getValue(), size: 120, minSize: 100, maxSize: 150, },
    { accessorKey: 'accuracy', id: 'accuracy', header: 'Precisión', cell: info => info.getValue(), size: 100, minSize: 80, maxSize: 130, },
    { id: 'tune', header: '', cell: () => null, enableSorting: false, enableResizing: false, size: 50, minSize: 50, maxSize: 50, },
    { accessorKey: 'fileName', id: 'fileName', header: 'Nombre de archivo', cell: info => info.getValue(), minSize: 200, },
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



  ngOnChanges(changes: SimpleChanges): void {
    if (this.list.length) {
      this.data.set(this.list);
    }
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
}
