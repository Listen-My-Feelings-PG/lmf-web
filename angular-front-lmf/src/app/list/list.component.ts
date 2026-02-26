import { Component, OnInit, OnDestroy, OnChanges, SimpleChanges, Input, computed, signal } from '@angular/core';
import { Playlist, Song } from '../_types/generals.models';
import { Subscription } from 'rxjs';
import { PlaylistService } from '../_services/playlist.service';
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

@Component({
  selector: 'app-list',
  imports: [CommonModule, FormsModule],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent implements OnInit, OnDestroy, OnChanges {
  @Input('list') _list: Array<Song> = [];
  @Input('componentMode') componentMode: 'outlet' | 'child' = 'outlet';

  private subscription!: Subscription;
  private previousPlaylistId: number | null = null;
  private previousSongsCount: number = 0;
  currentPlaylist: Playlist | null = null;
  songPlaying: Song | null = null;

  // TanStack Table signals
  data = signal<Song[]>([]);
  globalFilter = signal('');
  columnOrder = signal<string[]>(['id', 'title', 'artist', 'album', 'userScore', 'modelPrediction', 'fileName']);
  selectedRows = signal<Set<number>>(new Set());
  hoveredRow = signal<number | null>(null);

  // Helper methods for template
  Math = Math;

  // Configuración de paginación
  maxPageButtons = 7; // Número de botones de página a mostrar

  get list(): Array<Song> {
    return this._list;
  }

  set list(value: Array<Song>) {
    this._list = value;
    this.data.set(value);
  }

  // Define columns for TanStack Table
  columns: ColumnDef<Song>[] = [
    {
      accessorKey: 'id',
      id: 'id',
      header: '#',
      cell: info => info.getValue(),
      size: 60,
      minSize: 60,
      maxSize: 80,
    },
    {
      accessorFn: row => row.metadata?.title,
      id: 'title',
      header: 'Título',
      cell: info => info.getValue() || '-',
      size: 200,
      minSize: 150,
    },
    {
      accessorFn: row => row.metadata?.artist,
      id: 'artist',
      header: 'Artista',
      cell: info => info.getValue() || '-',
      size: 150,
      minSize: 120,
    },
    {
      accessorFn: row => row.metadata?.album,
      id: 'album',
      header: 'Álbum',
      cell: info => info.getValue() || '-',
      size: 150,
      minSize: 120,
    },
    {
      accessorKey: 'userScore',
      id: 'userScore',
      header: 'Rating',
      cell: info => info.getValue(),
      enableSorting: false,
      size: 130,
      minSize: 130,
      maxSize: 130,
    },
    {
      accessorFn: row => row,
      id: 'modelPrediction',
      header: 'Predicción',
      cell: info => info.getValue(),
      enableSorting: false,
      size: 180,
      minSize: 180,
      maxSize: 180,
    },
    {
      accessorKey: 'fileName',
      id: 'fileName',
      header: 'Nombre de archivo',
      cell: info => info.getValue(),
      minSize: 200,
    },
  ];

  // Create TanStack Table instance
  table = createAngularTable(() => ({
    data: this.data(),
    columns: this.columns,
    columnOrder: this.columnOrder(),
    state: {
      globalFilter: this.globalFilter(),
      columnOrder: this.columnOrder(),
    },
    onGlobalFilterChange: (updater) => {
      if (typeof updater === 'function') {
        this.globalFilter.set(updater(this.globalFilter()));
      } else {
        this.globalFilter.set(updater);
      }
    },
    onColumnOrderChange: (updater) => {
      if (typeof updater === 'function') {
        this.columnOrder.set(updater(this.columnOrder()));
      } else {
        this.columnOrder.set(updater);
      }
    },
    enableColumnResizing: true,
    columnResizeMode: 'onChange' as const,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    initialState: {
      pagination: {
        pageSize: 25,
      },
    },
  }));

  constructor(private playlistService: PlaylistService, private httpService: HttpService) { }

  ngOnChanges(changes: SimpleChanges): void {
    // Detectar cambios en el input _list
    if (changes['_list'] && changes['_list'].currentValue) {
      this.data.set(changes['_list'].currentValue);
    }
  }

  ngOnInit(): void {
    this.data.set(this._list);

    this.subscription = this.playlistService.getEventSubscription((value) => {
      if (this.componentMode == 'outlet') {
        const currentPlaylistId = value.selected?.id || null;
        const currentSongs = value.songList || [];
        const currentSongsCount = currentSongs.length;
        const playlistChanged = this.previousPlaylistId !== currentPlaylistId;
        const songsCountChanged = this.previousSongsCount !== currentSongsCount;

        // Detectar cambios en el contenido (ratings) comparando por referencia o valores
        const songsContentChanged = currentSongs.some((song, index) => {
          this.currentPlaylist = value.selected as Playlist;
          const existingSong = this._list[index];
          return !existingSong || song.userScore !== existingSong.userScore;
        });

        if (playlistChanged || songsCountChanged || songsContentChanged) {
          this.previousPlaylistId = currentPlaylistId;
          this.previousSongsCount = currentSongsCount;
          this.list = currentSongs;
        }

        if (value.songPlaying && (value.songPlaying.id !== this.songPlaying?.id)) {
          this.songPlaying = value.songPlaying;
        }
      }
    });
  }

  async playSong(song: Song): Promise<void> {
    try {
      if (song) {
        await this.playlistService.setSongPlaying(song);
        if (this.componentMode == 'child')
          await this.playlistService.updateSongList(this._list, true);
      }
    } catch (error) {
      console.error('Error al reproducir la canción:', error);
    }
  }

  rateSong(song: Song, score: 0 | 1 | 2 | 3): void {
    this.httpService.rateSongByIdSong(song.id!, score).then(async () => {
      try {
        // Crear una nueva copia del array con el score actualizado
        const updatedSongList = this._list.map(s =>
          s.id === song.id
            ? { ...s, userScore: score }
            : s
        );

        // Actualizar la lista local
        this._list = updatedSongList;
        this.data.set(updatedSongList);

        await this.playlistService.updateSongList(updatedSongList, false);
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
    if (newSelected.has(songId)) {
      newSelected.delete(songId);
    } else {
      newSelected.add(songId);
    }
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

    if (totalPages <= this.maxPageButtons) {
      // Si hay menos páginas que el máximo, mostrar todas
      return Array.from({ length: totalPages }, (_, i) => i);
    }

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
      if (startPage > 1) {
        pages.push('...');
      }
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
    if (this.subscription)
      this.subscription.unsubscribe();
  }
}
