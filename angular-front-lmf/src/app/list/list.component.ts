import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { Song } from '../_types/generals.models';
import { sampleList } from './examples';
import $ from 'jquery';
import 'datatables.net';

@Component({
  selector: 'app-list',
  imports: [],
  templateUrl: './list.component.html',
  styleUrl: './list.component.scss'
})
export class ListComponent implements OnInit, AfterViewInit {
  @ViewChild('songsTable', { static: false }) songsTable!: ElementRef;

  private _list: Array<Song>;
  dataTable: any;

  get list(): Array<Song> {
    return this._list;
  }

  set list(value: Array<Song>) {
    this._list = value;
    // Si DataTables ya está inicializada, actualizar los datos
    if (this.dataTable) {
      this.updateTableData();
    }
  }

  constructor() {
    this._list = [];
  }

  ngOnInit(): void {
    this._list = sampleList;

  }



  ngAfterViewInit(): void {
    // Pequeña espera para asegurar que el DOM está completamente renderizado
    setTimeout(() => {

      this.dataTable = $(this.songsTable.nativeElement).DataTable({
        data: this._list,
        columns: [
          {
            data: 'id',
            className: 'font-mono text-sm'
          },
          {
            data: null,
            className: 'font-semibold',
            render: (data: any, type: any, row: Song) => {
              const title = row.metadata?.title
                ? `<span>${row.metadata.title}</span>`
                : '<span class="text-gray-500 italic">-</span>';
              return `
                <div class="flex items-center space-x-2">
                  <i class="fas fa-play text-xs text-primary opacity-0 group-hover:opacity-100 transition-opacity"></i>
                  ${title}
                </div>
              `;
            }
          },
          {
            data: null,
            className: 'text-gray-300',
            render: (data: any, type: any, row: Song) => {
              return row.metadata?.artist || '-';
            }
          },
          {
            data: null,
            className: 'text-gray-400',
            render: (data: any, type: any, row: Song) => {
              return row.metadata?.album || '-';
            }
          },
          {
            data: 'userScore',
            className: 'text-center',
            orderable: false,
            render: (score: number) => {
              let stars = '';
              for (let i = 1; i <= 3; i++) {
                if (i <= score) {
                  stars += '<i class="fas fa-star text-yellow-400 text-sm"></i> ';
                } else {
                  stars += '<i class="far fa-star text-gray-600 text-sm"></i> ';
                }
              }
              return `<div class="flex justify-center space-x-1">${stars}</div>`;
            }
          },
          {
            data: 'fileName',
            className: 'text-gray-500 text-sm font-mono'
          }
        ],
        pageLength: 25,
        lengthMenu: [10, 25, 50, 100],
        order: [[0, 'asc']],
        scrollY: '350px',
        scrollCollapse: false,
        paging: true,
        dom: '<"flex flex-col md:flex-row justify-between items-center mb-4 gap-4"<"flex items-center gap-3"l><"flex items-center gap-3"f>>t<"flex flex-col md:flex-row justify-between items-center mt-4 gap-4"<"text-gray-400"i><"flex items-center gap-2"p>>',
        rowCallback: (row: Node) => {
          $(row).addClass('hover:bg-primary hover:bg-opacity-10 cursor-pointer transition-colors group');
        },
        initComplete: function () {
          // Personalizar el input de búsqueda
          $('.dataTables_filter input')
            .addClass('border-2 border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-primary transition-colors')
            .attr('placeholder', 'Buscar canciones...');
          $('.dataTables_filter label').addClass('flex items-center gap-3 text-gray-300 font-semibold');

          // Personalizar el selector de cantidad
          $('.dataTables_length select')
            .addClass('border-2 border-gray-600 rounded-lg px-3 py-2 focus:outline-none focus:border-primary transition-colors cursor-pointer');
          $('.dataTables_length label').addClass('flex items-center gap-3 text-gray-300 font-semibold');

          // Personalizar botones de paginación con estilos inline
          $('.dataTables_paginate .paginate_button').each(function () {
            const $btn = $(this);
            $btn.css({
              'display': 'inline-block',
              'padding': '0.5rem 0.75rem',
              'margin': '0 0.25rem',
              'background-color': '#1f2937',
              'border': '2px solid #4b5563',
              'color': '#d1d5db',
              'border-radius': '0.5rem',
              'cursor': 'pointer',
              'transition': 'all 0.2s',
              'font-weight': '500',
              'min-width': '2.5rem',
              'text-align': 'center'
            });

            // Estilos para botón actual
            if ($btn.hasClass('current')) {
              $btn.css({
                'background-color': '#8278e6',
                'border-color': '#8278e6',
                'color': '#ffffff',
                'font-weight': '700'
              });
            }

            // Estilos para botón deshabilitado
            if ($btn.hasClass('disabled')) {
              $btn.css({
                'opacity': '0.5',
                'cursor': 'not-allowed'
              });
            }
          });

          // Agregar eventos hover para los botones
          $('.dataTables_paginate .paginate_button').not('.disabled').hover(
            function () {
              if (!$(this).hasClass('current')) {
                $(this).css({
                  'background-color': '#374151',
                  'border-color': '#8278e6'
                });
              }
            },
            function () {
              if (!$(this).hasClass('current')) {
                $(this).css({
                  'background-color': '#1f2937',
                  'border-color': '#4b5563'
                });
              }
            }
          );
        },
        drawCallback: function () {
          // Re-aplicar estilos después de cada redibujado (cambio de página)
          $('.dataTables_paginate .paginate_button').each(function () {
            const $btn = $(this);
            $btn.css({
              'display': 'inline-block',
              'padding': '0.5rem 0.75rem',
              'margin': '0 0.25rem',
              'background-color': '#1f2937',
              'border': '2px solid #4b5563',
              'color': '#d1d5db',
              'border-radius': '0.5rem',
              'cursor': 'pointer',
              'transition': 'all 0.2s',
              'font-weight': '500',
              'min-width': '2.5rem',
              'text-align': 'center'
            });

            // Estilos para botón actual
            if ($btn.hasClass('current')) {
              $btn.css({
                'background-color': '#8278e6',
                'border-color': '#8278e6',
                'color': '#ffffff',
                'font-weight': '700'
              });
            }

            // Estilos para botón deshabilitado
            if ($btn.hasClass('disabled')) {
              $btn.css({
                'opacity': '0.5',
                'cursor': 'not-allowed'
              });
            }
          });

          // Re-aplicar eventos hover
          $('.dataTables_paginate .paginate_button').not('.disabled').off('mouseenter mouseleave').hover(
            function () {
              if (!$(this).hasClass('current')) {
                $(this).css({
                  'background-color': '#374151',
                  'border-color': '#8278e6'
                });
              }
            },
            function () {
              if (!$(this).hasClass('current')) {
                $(this).css({
                  'background-color': '#1f2937',
                  'border-color': '#4b5563'
                });
              }
            }
          );
        },
        language: {
          search: "Buscar:",
          lengthMenu: "Mostrar _MENU_ canciones",
          info: "Mostrando _START_ a _END_ de _TOTAL_ canciones",
          infoEmpty: "Mostrando 0 a 0 de 0 canciones",
          infoFiltered: "(filtrado de _MAX_ canciones totales)",
          paginate: {
            first: "Primero",
            last: "Último",
            next: "Siguiente",
            previous: "Anterior"
          },
          zeroRecords: "No se encontraron canciones",
        }
      });
    }, 100);
  }

  /**
   * Actualiza los datos de la tabla sin reinicializarla
   */
  updateTableData(): void {
    if (this.dataTable) {
      this.dataTable.clear();
      this.dataTable.rows.add(this._list);
      this.dataTable.draw();
    }
  }

  ngOnDestroy(): void {
    if (this.dataTable) {
      this.dataTable.destroy();
    }
  }
}
