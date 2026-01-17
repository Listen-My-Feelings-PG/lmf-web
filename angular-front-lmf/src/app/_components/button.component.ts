import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-button',
  standalone: true,
  imports: [CommonModule],
  template: `
    <button
      [type]="type"
      [disabled]="disabled || loading"
      [class]="buttonClasses"
      (click)="handleClick($event)"
    >
      <i *ngIf="loading" class="fas fa-spinner fa-spin"></i>
      <i *ngIf="!loading && icon" [class]="icon"></i>
      <span *ngIf="label">{{ label }}</span>
      <ng-content *ngIf="!label"></ng-content>
    </button>
  `,
  styles: [`
    button:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  `]
})
export class ButtonComponent {
  @Input() label?: string;
  @Input() icon?: string;
  @Input() variant: 'primary' | 'success' | 'warning' | 'danger' | 'info' | 'outline' = 'primary';
  @Input() size: 'sm' | 'md' | 'lg' = 'md';
  @Input() type: 'button' | 'submit' | 'reset' = 'button';
  @Input() disabled = false;
  @Input() loading = false;
  @Input() fullWidth = false;
  @Input() iconOnly = false;

  @Output() clicked = new EventEmitter<Event>();

  get buttonClasses(): string {
    const classes = ['btn'];

    // Variant
    if (this.variant === 'outline') {
      classes.push('btn-outline');
    } else {
      classes.push(`btn-${this.variant}`);
    }

    // Size
    if (this.size === 'sm') classes.push('btn-sm');
    if (this.size === 'lg') classes.push('btn-lg');

    // Icon only
    if (this.iconOnly) classes.push('btn-icon');

    // Full width
    if (this.fullWidth) classes.push('w-full');

    return classes.join(' ');
  }

  handleClick(event: Event) {
    if (!this.disabled && !this.loading) {
      this.clicked.emit(event);
    }
  }
}
