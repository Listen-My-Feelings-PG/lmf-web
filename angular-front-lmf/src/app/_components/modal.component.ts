import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-modal',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div *ngIf="visible" class="modal-overlay animate-fade-in" (click)="onOverlayClick($event)">
      <div class="modal-content" (click)="$event.stopPropagation()">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-2xl font-bold text-info">{{ title }}</h2>
          <button
            class="btn-icon text-white/70 hover:text-white hover:bg-white/10"
            (click)="close()"
          >
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="modal-body">
          <ng-content></ng-content>
        </div>
        <div *ngIf="showFooter" class="flex justify-end gap-3 mt-6 pt-4 border-t border-white/10">
          <button class="btn btn-outline text-white" (click)="close()">
            {{ cancelText }}
          </button>
          <button 
            *ngIf="showConfirm"
            class="btn btn-primary"
            (click)="confirm()"
            [disabled]="confirmDisabled"
          >
            {{ confirmText }}
          </button>
        </div>
      </div>
    </div>
  `
})
export class ModalComponent {
  @Input() visible = false;
  @Input() title = '';
  @Input() showFooter = true;
  @Input() showConfirm = true;
  @Input() confirmText = 'Confirmar';
  @Input() cancelText = 'Cancelar';
  @Input() confirmDisabled = false;
  @Input() closeOnOverlayClick = true;

  @Output() visibleChange = new EventEmitter<boolean>();
  @Output() confirmed = new EventEmitter<void>();
  @Output() cancelled = new EventEmitter<void>();

  close() {
    this.visible = false;
    this.visibleChange.emit(false);
    this.cancelled.emit();
  }

  confirm() {
    this.confirmed.emit();
  }

  onOverlayClick(event: Event) {
    if (this.closeOnOverlayClick) {
      this.close();
    }
  }
}
