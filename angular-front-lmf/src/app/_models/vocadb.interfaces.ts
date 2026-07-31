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
    filters: Record<string, unknown>;
  };
  stats: VocaDbExtractionStats;
  rangeLogs: VocaDbRangeLog[];
  urls: string[];
  report: VocaDbReportInfo;
}
