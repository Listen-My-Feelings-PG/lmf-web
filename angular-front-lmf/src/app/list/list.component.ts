import { Component, OnInit, AfterViewInit, ViewChild, ElementRef, OnDestroy, Input } from '@angular/core';
import { Song } from '../_types/generals.models';
//import { sampleList } from './examples';
import $ from 'jquery';
import 'datatables.net';
import { Subscription } from 'rxjs';
import { PlaylistService } from '../_services/playlist.service';
import { HttpService } from '../_services/http.service';

@Component({
  selector: 'app-list',
  imports: [],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('songsTable', { static: false }) songsTable!: ElementRef;
  @Input('list') _list: Array<Song>;
  private subscription!: Subscription;
  private previousPlaylistId: number | null;
  private previousSongsCount: number;
  dataTable: any;
  songPlaying: Song | null
  get list(): Array<Song> {
    return this._list;
  }

  set list(value: Array<Song>) {
    this._list = value;
    // Si DataTables ya está inicializada, actualizar los datos
    if (this.dataTable) {
      this.dataTable.clear();
      this.dataTable.rows.add(this._list);
      this.dataTable.draw();
      // Resaltar canción en reproducción después de actualizar (con pequeño delay para que el DOM se actualice)
      setTimeout(() => this.highlightPlayingSong(), 50);
    }
  }

  constructor(private playlistService: PlaylistService, private httpService: HttpService) {
    this._list = [];
    this.songPlaying = null;
    this.previousPlaylistId = null;
    this.previousSongsCount = 0;
  }

  ngOnInit(): void {
    this.subscription = this.playlistService.getEventSubscription((value) => {
      const currentPlaylistId = value.selected?.id || null;
      const currentSongs = value.selected?.songs || [];
      const currentSongsCount = currentSongs.length;
      const playlistChanged = this.previousPlaylistId !== currentPlaylistId;
      const songsCountChanged = this.previousSongsCount !== currentSongsCount;

      // Detectar cambios en el contenido (ratings) comparando por referencia o valores
      const songsContentChanged = currentSongs.some((song, index) => {
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
        setTimeout(() => this.highlightPlayingSong(), 50);
      }

    });
  }

  private highlightPlayingSong(): void {
    if (!this.dataTable) return;

    // Remover resaltado anterior de todas las filas
    const allRows = $(this.dataTable.rows().nodes());
    allRows.removeClass('playing-song');
    allRows.attr('style', '');

    // Resaltar la canción actual
    if (this.songPlaying && this.songPlaying.id) {
      const songId = this.songPlaying.id;
      const rows = this.dataTable.rows().nodes();

      $(rows).each((index: number, node: HTMLElement) => {
        const rowData = this.dataTable.row(node).data() as Song;
        if (rowData && rowData.id === songId) {
          const $node = $(node);
          $node.addClass('playing-song');
          // Aplicar estilos inline para forzar el resaltado sobre las clases de Tailwind
          const currentStyle = $node.attr('style') || '';
          $node.attr('style', currentStyle +
            '; background: linear-gradient(to right, rgba(130, 120, 230, 0.25), rgba(185, 98, 231, 0.25)) !important' +
            '; border-left: 4px solid #8278e6 !important');
        }
      });
    }
  }

  async playSong(idSong: number): Promise<void> {
    try {
      const song = this._list.find(s => s.id === idSong);
      if (song)
        await this.playlistService.setSongPlaying(song);
    } catch (error) {
      console.error('Error al reproducir la canción:', error);
    }
  }

  ngAfterViewInit(): void {
    // Pequeña espera para asegurar que el DOM está completamente renderizado
    setTimeout(() => {
      this.dataTable = $(this.songsTable.nativeElement).DataTable({
        data: this._list,
        columns: [
          { data: 'id', className: 'font-mono text-sm' },
          {
            data: null, className: 'font-semibold', render: (data: any, type: any, row: Song) => {
              const title = row.metadata?.title ? `<span>${row.metadata.title}</span>` : '<span class="text-gray-500 italic">-</span>';
              return `<div class="flex items-center space-x-2"><i class="fas fa-play text-xs text-primary opacity-0 group-hover:opacity-100 transition-opacity"></i>${title}</div>`;
            }
          },
          { data: null, className: 'text-gray-300', render: (_data, _type, row: Song) => row.metadata?.artist || '-' },
          { data: null, className: 'text-gray-400', render: (data: any, type: any, row: Song) => row.metadata?.album || '-' },
          {
            data: 'userScore', className: 'text-center', orderable: false, render: (score: number | null, type: any, row: Song) => {
              let html = '<div style="display: flex; justify-content: center; align-items: center; gap: 0.25rem;">';

              // Thumbs down icon - always visible (solid for 0, outline otherwise)
              const thumbClass = score === 0 ? 'fas' : 'far';
              const thumbColor = score === 0 ? 'color: #ef4444;' : 'color: #4b5563;';
              html += `<button class="rating-btn rating-btn-0" data-song-id="${row.id}" data-score="0" style="background: none; border: none; cursor: pointer; padding: 2px; transition: transform 0.1s;"><i class="${thumbClass} fa-thumbs-down" style="font-size: 0.875rem; ${thumbColor}"></i></button>`;

              // Stars (1-3) - clickable
              for (let i = 1; i <= 3; i++) {
                const isFilled = score !== null && score >= i;
                const starClass = isFilled ? 'fas' : 'far';
                const starColor = isFilled ? 'color: #facc15;' : 'color: #4b5563;';
                html += `<button class="rating-btn rating-btn-${i}" data-song-id="${row.id}" data-score="${i}" style="background: none; border: none; cursor: pointer; padding: 2px; transition: transform 0.1s;"><i class="${starClass} fa-star" style="font-size: 0.875rem; ${starColor}"></i></button>`;
              }

              html += '</div>';
              return html;
            }
          },
          { data: 'fileName', className: 'text-gray-500 text-sm font-mono' }
        ],
        pageLength: 25, lengthMenu: [10, 25, 50, 100], order: [[0, 'asc']], scrollY: '350px', scrollCollapse: false, paging: true,
        dom: '<"flex flex-col md:flex-row justify-between items-center mb-4 gap-4"' +
          '<"flex items-center gap-3"l>' + '<"flex items-center gap-3"f>' +
          '>t<"flex flex-col md:flex-row justify-between items-center mt-4 gap-4"' + '<"text-gray-400"i>' + '<"flex items-center gap-2"p>>',
        rowCallback: (row: Node, data: any) => {
          const $row = $(row);
          $row.addClass('hover:bg-primary hover:bg-opacity-10 cursor-pointer transition-colors group');

          // Click en la fila para reproducir
          $row.off('click').on('click', (e) => {
            // No reproducir si se hizo click en un botón de rating
            if (!$(e.target).closest('.rating-btn').length) {
              const song = data as Song;
              if (song.id)
                this.playSong(song.id);
            }
          });

          // Event listeners para los botones de rating
          $row.find('.rating-btn').off('click').on('click', (e) => {
            e.stopPropagation(); // Prevenir que se dispare el evento de reproducción
            const $btn = $(e.currentTarget);
            const songId = parseInt($btn.attr('data-song-id') || '0', 10);
            const score = parseInt($btn.attr('data-score') || '0', 10) as 0 | 1 | 2 | 3;
            const song = this._list.find(s => s.id === songId);

            if (song) {
              this.rateSong(song, score);
            }
          });

          // Efecto hover en botones de rating
          $row.find('.rating-btn').hover(
            function () { $(this).css('transform', 'scale(1.2)'); },
            function () { $(this).css('transform', 'scale(1)'); }
          );
        },
        initComplete: function () {
          $('.dataTables_filter input').addClass('border-2 border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-primary transition-colors').attr('placeholder', 'Buscar canciones...');
          $('.dataTables_filter label').addClass('flex items-center gap-3 text-gray-300 font-semibold');
          $('.dataTables_length select').addClass('border-2 border-gray-600 rounded-lg px-3 py-2 focus:outline-none focus:border-primary transition-colors cursor-pointer');
          $('.dataTables_length label').addClass('flex items-center gap-3 text-gray-300 font-semibold');
          $('.dataTables_paginate .paginate_button').each(function () {
            const $btn = $(this);
            $btn.css({
              'display': 'inline-block', 'padding': '0.5rem 0.75rem', 'margin': '0 0.25rem', 'background-color': '#1f2937', 'border': '2px solid #4b5563',
              'color': '#d1d5db', 'border-radius': '0.5rem', 'cursor': 'pointer', 'transition': 'all 0.2s', 'font-weight': '500', 'min-width': '2.5rem', 'text-align': 'center'
            });
            if ($btn.hasClass('current')) $btn.css({ 'background-color': '#8278e6', 'border-color': '#8278e6', 'color': '#ffffff', 'font-weight': '700' });
            if ($btn.hasClass('disabled')) $btn.css({ 'opacity': '0.5', 'cursor': 'not-allowed' });
          });
          $('.dataTables_paginate .paginate_button').not('.disabled').hover(function () {
            if (!$(this).hasClass('current')) $(this).css({ 'background-color': '#374151', 'border-color': '#8278e6' });
          }, function () {
            if (!$(this).hasClass('current')) $(this).css({ 'background-color': '#1f2937', 'border-color': '#4b5563' });
          });
        },
        drawCallback: (function (this: ListComponent) {
          $('.dataTables_paginate .paginate_button').each(function () {
            const $btn = $(this);
            $btn.css({
              'display': 'inline-block', 'padding': '0.5rem 0.75rem', 'margin': '0 0.25rem', 'background-color': '#1f2937', 'border': '2px solid #4b5563',
              'color': '#d1d5db', 'border-radius': '0.5rem', 'cursor': 'pointer', 'transition': 'all 0.2s', 'font-weight': '500', 'min-width': '2.5rem', 'text-align': 'center'
            });
            if ($btn.hasClass('current'))
              $btn.css({ 'background-color': '#8278e6', 'border-color': '#8278e6', 'color': '#ffffff', 'font-weight': '700' });
            if ($btn.hasClass('disabled'))
              $btn.css({ 'opacity': '0.5', 'cursor': 'not-allowed' });
          });
          $('.dataTables_paginate .paginate_button').not('.disabled').off('mouseenter mouseleave').hover(
            function () {
              if (!$(this).hasClass('current'))
                $(this).css({ 'background-color': '#374151', 'border-color': '#8278e6' });
            },
            function () {
              if (!$(this).hasClass('current'))
                $(this).css({ 'background-color': '#1f2937', 'border-color': '#4b5563' });
            }
          );

          // Re-aplicar event listeners a los botones de rating después del redibujado
          const self = this;
          $('.rating-btn').off('click').on('click', function (e) {
            e.stopPropagation();
            const $btn = $(this);
            const songId = parseInt($btn.attr('data-song-id') || '0', 10);
            const score = parseInt($btn.attr('data-score') || '0', 10) as 0 | 1 | 2 | 3;
            const song = self._list.find(s => s.id === songId);

            if (song) {
              self.rateSong(song, score);
            }
          });

          // Efecto hover en botones de rating
          $('.rating-btn').hover(
            function () { $(this).css('transform', 'scale(1.2)'); },
            function () { $(this).css('transform', 'scale(1)'); }
          );

          // Resaltar la canción en reproducción después de cada redibujado
          this.highlightPlayingSong();
        }).bind(this),
        language: {
          search: "Buscar:", lengthMenu: "Mostrar _MENU_ canciones", info: "Mostrando _START_ a _END_ de _TOTAL_ canciones", infoEmpty: "Mostrando 0 a 0 de 0 canciones",
          infoFiltered: "(filtrado de _MAX_ canciones totales)", paginate: { first: "Primero", last: "Último", next: "Siguiente", previous: "Anterior" },
          zeroRecords: "No se encontraron canciones",
        }
      });

      // Resaltar canción actual si existe (con delay para que DataTable termine de inicializar)
      setTimeout(() => this.highlightPlayingSong(), 100);
    }, 300);
  }

  rateSong(song: Song, score: 0 | 1 | 2 | 3): void {
    this.httpService.rateSongByIdSong(song.id!, score).then(async () => {
      try {
        // Crear una nueva copia del array con el score actualizado
        const updatedList = this._list.map(s =>
          s.id === song.id
            ? { ...s, userScore: score }
            : s
        );

        // Actualizar la lista local
        this._list = updatedList;

        // Actualizar la fila en DataTable
        if (this.dataTable) {
          const rowIndex = updatedList.findIndex(s => s.id === song.id);
          if (rowIndex !== -1) {
            this.dataTable.row(rowIndex).data(updatedList[rowIndex]).draw(false);
          }
        }

        await this.playlistService.updateContentOfSelectedPlaylist(updatedList);
      } catch (error) {
        console.error('Error al actualizar el rating localmente después de calificar la canción:', error);
      }
    }).catch(error => console.error('Error al calificar la canción:', error));
  }

  ngOnDestroy(): void {
    if (this.subscription)
      this.subscription.unsubscribe();
    if (this.dataTable)
      this.dataTable.destroy();

  }
}
