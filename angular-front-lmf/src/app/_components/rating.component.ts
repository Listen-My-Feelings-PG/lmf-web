import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-rating',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="flex items-center gap-1">
      <i
        *ngFor="let star of stars; let i = index"
        [class]="getStarClass(i)"
        (click)="onStarClick(i)"
        (mouseenter)="onStarHover(i)"
        (mouseleave)="onMouseLeave()"
      ></i>
    </div>
  `,
  styles: [`
    i {
      transition: all 0.2s ease;
    }
  `]
})
export class RatingComponent {
  @Input() value = 0;
  @Input() max = 3;
  @Input() disabled = false;
  @Input() size: 'sm' | 'md' | 'lg' = 'md';

  @Output() valueChange = new EventEmitter<number>();
  @Output() rated = new EventEmitter<number>();

  hoverValue: number | null = null;

  get stars(): number[] {
    return Array(this.max).fill(0).map((_, i) => i);
  }

  getStarClass(index: number): string {
    const classes = ['star'];

    // Size
    if (this.size === 'sm') classes.push('text-lg');
    if (this.size === 'lg') classes.push('text-3xl');

    // Filled or empty
    const displayValue = this.hoverValue !== null ? this.hoverValue : this.value;
    if (index < displayValue) {
      classes.push('star-filled fas fa-star');
    } else {
      classes.push('star-empty far fa-star');
    }

    // Disabled
    if (this.disabled) {
      classes.push('opacity-50 cursor-not-allowed');
    }

    return classes.join(' ');
  }

  onStarClick(index: number) {
    if (!this.disabled) {
      const newValue = index + 1;
      this.value = newValue;
      this.valueChange.emit(newValue);
      this.rated.emit(newValue);
    }
  }

  onStarHover(index: number) {
    if (!this.disabled) {
      this.hoverValue = index + 1;
    }
  }

  onMouseLeave() {
    this.hoverValue = null;
  }
}
