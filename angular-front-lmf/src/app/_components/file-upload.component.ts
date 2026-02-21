import { Component, Input, Output, EventEmitter, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-file-upload',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="w-full">
      <label *ngIf="label" class="block text-sm font-medium mb-2 text-light-80">{{ label }}</label>
      
      <div class="border-2 border-dashed border-white-30 rounded-xl p-8 text-center cursor-pointer transition-all hover:border-info hover:bg-white-5"
           [ngClass]="{'border-info': isDragging, 'bg-white-5': isDragging}"
           (click)="fileInput.click()"
           (dragover)="onDragOver($event)"
           (dragleave)="onDragLeave($event)"
           (drop)="onDrop($event)">
        
        <input #fileInput
               type="file"
               class="hidden"
               [accept]="accept"
               [multiple]="multiple"
               (change)="onFileSelected($event)"
               [disabled]="disabled" />
        
        <div class="flex flex-col items-center gap-3">
          <i class="fas fa-cloud-upload-alt text-5xl text-info"></i>
          <p class="text-lg font-medium">
            {{ isDragging ? 'Suelta los archivos aquí' : 'Haz clic o arrastra archivos' }}
          </p>
          <p class="text-sm text-white-50">{{ acceptLabel }}</p>
        </div>
      </div>
      
      <div *ngIf="selectedFiles.length > 0" class="mt-4 space-y-2">
        <div *ngFor="let file of selectedFiles; let i = index"
             class="flex items-center justify-between p-3 bg-white-5 rounded-lg">
          <div class="flex items-center gap-3">
            <i class="fas fa-file-audio text-info text-xl"></i>
            <div>
              <p class="font-medium">{{ file.name }}</p>
              <p class="text-sm text-white-50">{{ formatFileSize(file.size) }}</p>
            </div>
          </div>
          <button class="btn-icon btn-sm text-danger hover:bg-danger-20"
                  (click)="removeFile(i)">
            <i class="fas fa-times"></i>
          </button>
        </div>
      </div>

      <button *ngIf="selectedFiles.length > 0 && !autoUpload"
              class="btn btn-primary w-full mt-4"
              (click)="upload()"
              [disabled]="disabled">
        <i class="fas fa-upload"></i>
        Subir {{ selectedFiles.length }} archivo(s)
      </button>
    </div>
  `
})
export class FileUploadComponent {
  @ViewChild('fileInput') fileInput!: ElementRef<HTMLInputElement>;

  @Input() label?: string;
  @Input() accept = 'audio/*';
  @Input() acceptLabel = 'MP3, WAV, OGG (máx. 100MB)';
  @Input() multiple = true;
  @Input() disabled = false;
  @Input() autoUpload = false;
  @Input() maxFileSize = 100 * 1024 * 1024; // 100MB

  @Output() filesSelected = new EventEmitter<File[]>();
  @Output() uploadFiles = new EventEmitter<File[]>();

  selectedFiles: File[] = [];
  isDragging = false;

  onFileSelected(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      this.handleFiles(Array.from(input.files));
    }
  }

  onDragOver(event: DragEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = true;
  }

  onDragLeave(event: DragEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;
  }

  onDrop(event: DragEvent) {
    event.preventDefault();
    event.stopPropagation();
    this.isDragging = false;

    if (event.dataTransfer?.files) {
      this.handleFiles(Array.from(event.dataTransfer.files));
    }
  }

  handleFiles(files: File[]) {
    // Filtrar archivos por tamaño
    const validFiles = files.filter(file => file.size <= this.maxFileSize);

    if (this.multiple) {
      this.selectedFiles = [...this.selectedFiles, ...validFiles];
    } else {
      this.selectedFiles = validFiles.slice(0, 1);
    }

    this.filesSelected.emit(this.selectedFiles);

    if (this.autoUpload && this.selectedFiles.length > 0) {
      this.upload();
    }
  }

  removeFile(index: number) {
    this.selectedFiles.splice(index, 1);
    this.filesSelected.emit(this.selectedFiles);
  }

  upload() {
    if (this.selectedFiles.length > 0) {
      this.uploadFiles.emit(this.selectedFiles);
    }
  }

  formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }
}
