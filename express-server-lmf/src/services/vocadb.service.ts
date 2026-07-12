import fs from 'fs';
import path from 'path';

const VOCADB_API_URL = 'https://vocadb.net/api/songs';
const VOCADB_MAX_RESULTS = 100;
const DEFAULT_REPORTS_PATH = './files/vocadb_reports';

const VOCADB_FILTERS = {
  query: '',
  artistId: 1,
  artistParticipationStatus: 'Everything',
  childVoicebanks: true,
  childTags: false,
  minScore: 4,
  onlyWithPvs: false,
  sort: 'RatingScore',
  fields: 'PVs,Artists',
  advancedFilter: {
    description: 'Artist type: Vocaloid',
    filterType: 'ArtistType',
    negate: false,
    param: 'Vocaloid'
  }
} as const;

interface VocaDbPv {
  id?: number;
  service?: string;
  url?: string;
  pvId?: string;
  name?: string;
  author?: string;
  pvType?: string;
  disabled?: boolean;
  publishDate?: string;
}

interface VocaDbSong {
  id?: number;
  name?: string;
  defaultName?: string;
  artistString?: string;
  publishDate?: string;
  ratingScore?: number;
  songType?: string;
  status?: string;
  pvs?: VocaDbPv[];
}

interface VocaDbApiResponse {
  items?: VocaDbSong[];
  totalCount?: number;
}

interface DateRange {
  after: Date;
  before: Date;
}

interface VocaDbRangeResponse {
  json: VocaDbApiResponse;
  requestUrl: string;
  status: number;
}

export interface VocaDbRangeLog {
  afterDate: string;
  beforeDate: string;
  days: number;
  received: number;
  totalCount: number;
  truncated: boolean;
  status: number;
  requestUrl: string;
}

export interface VocaDbExtractionStats {
  totalSongsReceived: number;
  totalCountFromApi: number;
  youtubeOriginalPvs: number;
  uniqueYoutubeOriginalUrls: number;
  duplicateYoutubeUrls: number;
  requestsMade: number;
  truncatedRanges: number;
  unresolvedTruncatedRanges: number;
  leafRanges: number;
}

export interface VocaDbReportInfo {
  fileName: string;
  filePath: string;
  linksWritten: number;
}

export interface VocaDbYoutubeExtractionResult {
  config: {
    year: number;
    rangeDays: number;
    maxResults: number;
    filters: typeof VOCADB_FILTERS;
  };
  stats: VocaDbExtractionStats;
  rangeLogs: VocaDbRangeLog[];
  urls: string[];
  report: VocaDbReportInfo;
}

interface ExtractionAccumulator {
  stats: VocaDbExtractionStats;
  rangeLogs: VocaDbRangeLog[];
  seenUrls: Set<string>;
  urls: string[];
}

function pad2(value: number): string {
  return String(value).padStart(2, '0');
}

function formatVocaDate(date: Date): string {
  return `${date.getUTCFullYear()}-${pad2(date.getUTCMonth() + 1)}-${pad2(date.getUTCDate())}T00:00:00`;
}

function formatReportTimestamp(date: Date): string {
  return [
    date.getFullYear(),
    pad2(date.getMonth() + 1),
    pad2(date.getDate()),
    pad2(date.getHours()),
    pad2(date.getMinutes()),
    pad2(date.getSeconds())
  ].join('');
}

function addUtcDays(date: Date, days: number): Date {
  const next = new Date(date.getTime());
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function getRangeDays(range: DateRange): number {
  const millisecondsPerDay = 24 * 60 * 60 * 1000;
  return Math.max(1, Math.round((range.before.getTime() - range.after.getTime()) / millisecondsPerDay));
}

function makeYearRanges(year: number, rangeDays: number): DateRange[] {
  const ranges: DateRange[] = [];
  const end = new Date(Date.UTC(year + 1, 0, 1));
  let cursor = new Date(Date.UTC(year, 0, 1));

  while (cursor.getTime() < end.getTime()) {
    const next = addUtcDays(cursor, rangeDays);
    ranges.push({
      after: cursor,
      before: next.getTime() < end.getTime() ? next : end
    });
    cursor = next;
  }

  return ranges;
}

function buildVocadbUrl(afterDate: string, beforeDate: string): string {
  const params = new URLSearchParams();

  params.set('query', VOCADB_FILTERS.query);
  params.set('artistId', String(VOCADB_FILTERS.artistId));
  params.set('artistParticipationStatus', VOCADB_FILTERS.artistParticipationStatus);
  params.set('childVoicebanks', String(VOCADB_FILTERS.childVoicebanks));
  params.set('childTags', String(VOCADB_FILTERS.childTags));
  params.set('minScore', String(VOCADB_FILTERS.minScore));
  params.set('onlyWithPvs', String(VOCADB_FILTERS.onlyWithPvs));
  params.set('sort', VOCADB_FILTERS.sort);
  params.set('start', '0');
  params.set('maxResults', String(VOCADB_MAX_RESULTS));
  params.set('getTotalCount', 'true');
  params.set('fields', VOCADB_FILTERS.fields);
  params.set('advancedFilters[0][description]', VOCADB_FILTERS.advancedFilter.description);
  params.set('advancedFilters[0][filterType]', VOCADB_FILTERS.advancedFilter.filterType);
  params.set('advancedFilters[0][negate]', String(VOCADB_FILTERS.advancedFilter.negate));
  params.set('advancedFilters[0][param]', VOCADB_FILTERS.advancedFilter.param);
  params.set('afterDate', afterDate);
  params.set('beforeDate', beforeDate);

  return `${VOCADB_API_URL}?${params.toString()}`;
}

async function fetchVocadbRange(afterDate: string, beforeDate: string): Promise<VocaDbRangeResponse> {
  const requestUrl = buildVocadbUrl(afterDate, beforeDate);
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 30000);

  try {
    const response = await fetch(requestUrl, {
      method: 'GET',
      headers: {
        Accept: 'application/json',
        'User-Agent': 'ListenMyFeelings/1.0 VocaDB YouTube links reporter'
      },
      signal: controller.signal
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`VocaDB API ${response.status}: ${text.slice(0, 300)}`);
    }

    const json = await response.json() as VocaDbApiResponse;
    return {
      json,
      requestUrl,
      status: response.status
    };
  } finally {
    clearTimeout(timeout);
  }
}

function isYoutubeOriginalPv(pv: VocaDbPv): boolean {
  const service = String(pv.service || '');
  const pvType = String(pv.pvType || '');
  const url = String(pv.url || '');

  return (
    service === 'Youtube' &&
    pvType === 'Original' &&
    /^https:\/\/(www\.)?(youtube\.com|youtu\.be)\//i.test(url)
  );
}

function collectYoutubeOriginalUrls(items: VocaDbSong[], accumulator: ExtractionAccumulator): void {
  for (const song of items) {
    for (const pv of song.pvs || []) {
      if (!isYoutubeOriginalPv(pv))
        continue;

      const url = String(pv.url || '').trim();
      accumulator.stats.youtubeOriginalPvs++;

      if (accumulator.seenUrls.has(url)) {
        accumulator.stats.duplicateYoutubeUrls++;
        continue;
      }

      accumulator.seenUrls.add(url);
      accumulator.urls.push(url);
    }
  }
}

/**
 * Lógica recursiva: Procesa un rango de fechas contra la API de VocaDB.
 * Si la API indica que hay más resultados de los permitidos por página (truncated = true),
 * la función divide el rango de fechas actual exactamente a la mitad y se llama a sí misma
 * dos veces (recursión) para asegurar la extracción del 100% de los datos sin perder ninguno.
 * 
 * @param range Rango de fechas a consultar
 * @param accumulator Objeto mutado por referencia para ir acumulando resultados y estadísticas
 */
async function processRange(range: DateRange, accumulator: ExtractionAccumulator): Promise<void> {
  const afterDate = formatVocaDate(range.after);
  const beforeDate = formatVocaDate(range.before);
  const response = await fetchVocadbRange(afterDate, beforeDate);
  const items = response.json.items || [];
  const totalCount = typeof response.json.totalCount === 'number'
    ? response.json.totalCount
    : items.length;
  const days = getRangeDays(range);
  const truncated = totalCount > items.length;

  accumulator.stats.requestsMade++;
  accumulator.rangeLogs.push({
    afterDate,
    beforeDate,
    days,
    received: items.length,
    totalCount,
    truncated,
    status: response.status,
    requestUrl: response.requestUrl
  });

  if (truncated) {
    accumulator.stats.truncatedRanges++;

    if (days > 1) {
      const halfDays = Math.max(1, Math.floor(days / 2));
      const middle = addUtcDays(range.after, halfDays);

      await processRange({ after: range.after, before: middle }, accumulator);
      await processRange({ after: middle, before: range.before }, accumulator);
      return;
    }

    accumulator.stats.unresolvedTruncatedRanges++;
  }

  accumulator.stats.leafRanges++;
  accumulator.stats.totalSongsReceived += items.length;
  accumulator.stats.totalCountFromApi += totalCount;
  collectYoutubeOriginalUrls(items, accumulator);
}

async function writeLinksReport(year: number, urls: string[]): Promise<VocaDbReportInfo> {
  const reportsPath = path.resolve(process.env.VOCADB_YOUTUBE_LINKS_REPORTS_PATH || DEFAULT_REPORTS_PATH);
  const fileName = `report_${year}_${formatReportTimestamp(new Date())}.txt`;
  const filePath = path.join(reportsPath, fileName);
  const content = urls.length > 0 ? `${urls.join('\n')}\n` : '';

  await fs.promises.mkdir(reportsPath, { recursive: true });
  await fs.promises.writeFile(filePath, content, 'utf8');

  return {
    fileName,
    filePath,
    linksWritten: urls.length
  };
}

/**
 * Servicio: Ejecuta la extracción iterando sobre rangos de fechas de un año completo.
 * VocaDB tiene un límite estricto de resultados, por lo que este método divide el año 
 * en bloques de `rangeDays` y realiza peticiones usando la función recursiva `processRange`.
 * Al finalizar, guarda el resultado en un archivo `.txt` en disco.
 * 
 * @param year Año de publicación de las canciones a buscar (ej: 2023)
 * @param rangeDays Salto de días inicial para las particiones (ej: 3)
 * @returns Un objeto estructurado con las URLs, estadísticas del proceso y metadatos del reporte generado.
 */
export async function extractVocadbYoutubeLinks(year: number, rangeDays: number): Promise<VocaDbYoutubeExtractionResult> {
  const accumulator: ExtractionAccumulator = {
    stats: {
      totalSongsReceived: 0,
      totalCountFromApi: 0,
      youtubeOriginalPvs: 0,
      uniqueYoutubeOriginalUrls: 0,
      duplicateYoutubeUrls: 0,
      requestsMade: 0,
      truncatedRanges: 0,
      unresolvedTruncatedRanges: 0,
      leafRanges: 0
    },
    rangeLogs: [],
    seenUrls: new Set<string>(),
    urls: []
  };

  for (const range of makeYearRanges(year, rangeDays))
    await processRange(range, accumulator);

  accumulator.stats.uniqueYoutubeOriginalUrls = accumulator.urls.length;
  const report = await writeLinksReport(year, accumulator.urls);

  return {
    config: {
      year,
      rangeDays,
      maxResults: VOCADB_MAX_RESULTS,
      filters: VOCADB_FILTERS
    },
    stats: accumulator.stats,
    rangeLogs: accumulator.rangeLogs,
    urls: accumulator.urls,
    report
  };
}
