import {
  Component, OnInit, OnDestroy, OnChanges, SimpleChanges,
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

@Component({
  selector: 'app-list',
  imports: [CommonModule, FormsModule],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent implements OnInit, OnDestroy, OnChanges {
  @Input('list') list: Array<Song>;
  @Input('componentMode') componentMode: 'outlet' | 'child';
  @Input('songPlaying') songPlaying: Song | null;
  @Output('onSelectSong') onSelectSong: EventEmitter<Song>;
  @Output('onRateSong') onRateSong: EventEmitter<{ song: Song, score: UserScore }>;

  private previousPlaylistId: number | null;
  private previousSongsCount: number;
  currentPlaylist: Playlist | null;

  // TanStack Table signals
  data = signal<Song[]>([]);
  globalFilter = signal('');
  columnOrder = signal<string[]>([
    'id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'fileName'
  ]);
  selectedRows = signal<Set<number>>(new Set());
  hoveredRow = signal<number | null>(null);

  // Helper methods for template
  Math = Math;

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
    initialState: { pagination: { pageSize: 25, }, },
  }));

  constructor(private globalPlaylist: GlobalPlaylistService, private httpService: HttpService) {
    this.list = [];
    this.previousPlaylistId = null;
    this.previousSongsCount = 0;
    this.currentPlaylist = null;
    this.songPlaying = null;
    this.componentMode = 'outlet';
    this.onSelectSong = new EventEmitter<Song>();
    this.onRateSong = new EventEmitter<{ song: Song, score: UserScore }>();

    // Effect en constructor (contexto de inyección válido)
    effect(() => {
      console.log('effect activado en ListComponent - modo:', this.componentMode);
      if (this.componentMode == 'outlet') {
        const selectedPlaylist = this.globalPlaylist.selectedPlaylist();
        const currentSongs = this.globalPlaylist.songList();
        const songPlaying = this.globalPlaylist.currentSong();

        const currentPlaylistId = selectedPlaylist?.id || null;
        const currentSongsCount = currentSongs.length;
        const playlistChanged = this.previousPlaylistId !== currentPlaylistId;
        const songsCountChanged = this.previousSongsCount !== currentSongsCount;

        // Detectar cambios en el contenido (ratings) comparando por referencia o valores
        const songsContentChanged = currentSongs.some((song, index) => {
          this.currentPlaylist = selectedPlaylist as Playlist;
          const existingSong = this.list[index];
          return !existingSong || song.userScore !== existingSong.userScore;
        });

        if (playlistChanged || songsCountChanged || songsContentChanged) {
          this.previousPlaylistId = currentPlaylistId;
          this.previousSongsCount = currentSongsCount;
          this.list = currentSongs;
          this.data.set(currentSongs);
        }

        if (songPlaying && (songPlaying.id !== this.songPlaying?.id)) {
          this.songPlaying = songPlaying;
        }
      }
    });
  }

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['list'] && changes['list'].currentValue)
      this.data.set(changes['list'].currentValue);
  }

  ngOnInit(): void {
    this.data.set(this.list);
  }

  selectSong(song: Song): void {
    try {
      if (song) {
        if (this.componentMode == 'outlet') {
          const result = this.globalPlaylist.setSongPlaying(song);
          if (!result.ok) {
            console.error('Error al reproducir la canción:', result.error);
          }
        } else {
          this.onSelectSong.emit(song);
        }
      }
    } catch (error) {
      console.error('Error al reproducir la canción:', error);
    }
  }

  rateSong(song: Song, score: UserScore): void {
    if (this.componentMode == 'child')
      this.onRateSong.emit({ song, score });
    else
      this.httpService.rateSongByIdSong(song.id!, score).then(() => {
        try {
          const updatedSongList = this.list.map(s =>
            s.id === song.id
              ? { ...s, userScore: score }
              : s
          );

          this.list = updatedSongList;
          this.data.set(updatedSongList);

          const result = this.globalPlaylist.setSongList(updatedSongList);
          if (!result.ok) {
            console.error('Error al actualizar el rating localmente:', result.error);
          }
        } catch (error) {
          console.error('Error al actualizar el rating localmente después de calificar la canción:', error);
        }
      }).catch(error => console.error('Error al calificar la canción:', error));
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

  getCircularProgressStyle(value: number | null): string {
    if (value === null) return 'conic-gradient(#4b5563 360deg, #4b5563 0deg)';
    const percentage = Math.round(value);
    const degrees = (percentage / 100) * 360;
    return `conic-gradient(#46f0be ${degrees}deg, #374151 ${degrees}deg)`;
  }

  ngOnDestroy(): void {
    // Los effects se limpian automáticamente
  }
}
