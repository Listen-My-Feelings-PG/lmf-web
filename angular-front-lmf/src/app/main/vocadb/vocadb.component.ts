import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpService } from '../../_services/http.service';
import { VocaDbYoutubeExtractionResult } from '../../_types/vocadb.interfaces';

@Component({
  selector: 'app-vocadb',
  imports: [CommonModule, FormsModule],
  templateUrl: './vocadb.component.html',
  styleUrl: './vocadb.component.scss'
})
export class VocadbComponent {
  readonly minYear = 1900;
  readonly maxYear = 2100;
  readonly minRangeDays = 1;
  readonly maxRangeDays = 31;

  year = 2012;
  rangeDays = 3;
  loading = false;
  errorMessage = '';
  copyMessage = '';
  extraction: VocaDbYoutubeExtractionResult | null = null;

  constructor(private httpService: HttpService) { }

  get urlsText(): string {
    return this.extraction?.urls.join('\n') || '';
  }

  async runExtraction(): Promise<void> {
    const year = Number(this.year);
    const rangeDays = Number(this.rangeDays);

    if (!Number.isInteger(year) || year < this.minYear || year > this.maxYear) {
      this.errorMessage = `El año debe estar entre ${this.minYear} y ${this.maxYear}.`;
      return;
    }

    if (!Number.isInteger(rangeDays) || rangeDays < this.minRangeDays || rangeDays > this.maxRangeDays) {
      this.errorMessage = `El salto debe estar entre ${this.minRangeDays} y ${this.maxRangeDays} días.`;
      return;
    }

    this.loading = true;
    this.errorMessage = '';
    this.copyMessage = '';
    this.extraction = null;

    try {
      this.extraction = await this.httpService.createVocadbYoutubeLinksReport(year, rangeDays);
    } catch (error) {
      this.errorMessage = this.resolveErrorMessage(error);
    } finally {
      this.loading = false;
    }
  }

  async copyLinks(): Promise<void> {
    if (!this.urlsText)
      return;

    try {
      await navigator.clipboard.writeText(this.urlsText);
      this.copyMessage = 'Links copiados';
    } catch {
      this.copyMessage = 'No se pudo copiar';
    }
  }

  private resolveErrorMessage(error: unknown): string {
    if (typeof error === 'object' && error !== null) {
      const candidate = error as {
        error?: {
          error?: {
            message?: string
          },
          message?: string
        },
        message?: string
      };

      if (typeof candidate.error?.error?.message === 'string')
        return candidate.error.error.message;

      if (typeof candidate.error?.message === 'string')
        return candidate.error.message;

      if (typeof candidate.message === 'string')
        return candidate.message;
    }

    return 'No se pudo completar la extracción de VocaDB.';
  }
}
