import { ColumnDef } from '@tanstack/angular-table';
import { Song } from './generals.models';

export const ListColumnsDefinition: ColumnDef<Song>[] = [
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

export const StatsListColumnsDefinition: ColumnDef<Song>[] = [
  { accessorKey: 'id', id: 'id', header: '#', cell: info => info.getValue(), size: 60, minSize: 60, maxSize: 80 },
  { accessorKey: 'fileName', id: 'fileName', header: 'Nombre de archivo', cell: info => info.getValue(), minSize: 200 },
  { accessorKey: 'userScore', id: 'userScore', header: 'Rating', cell: info => info.getValue(), enableSorting: false, size: 130, minSize: 130, maxSize: 130 },
  { accessorFn: row => row, id: 'modelPrediction', header: 'Predicción', cell: info => info.getValue(), enableSorting: false, size: 180, minSize: 180, maxSize: 180 },
  { accessorKey: 'tsTrainLevelGlobal', id: 'tsTrainLevelGlobal', header: 'Nivel Entren. Global', cell: info => info.getValue(), size: 120, minSize: 100, maxSize: 150 },
  { id: 'chart', header: 'Gráfica', cell: () => null, enableSorting: false, enableResizing: false, size: 500, minSize: 500 },
];
