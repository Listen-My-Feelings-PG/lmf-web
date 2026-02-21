import { Component, Input, forwardRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, NG_VALUE_ACCESSOR, ControlValueAccessor } from '@angular/forms';

@Component({
  selector: 'app-input',
  standalone: true,
  imports: [CommonModule, FormsModule],
  providers: [
    {
      provide: NG_VALUE_ACCESSOR,
      useExisting: forwardRef(() => InputComponent),
      multi: true
    }
  ],
  template: `
    <div class="w-full">
      <label *ngIf="label" class="block text-sm font-medium mb-2 text-light/80">
        {{ label }}
        <span *ngIf="required" class="text-danger">*</span>
      </label>
      <div class="relative">
        <i *ngIf="icon" [class]="icon + ' absolute left-3 top-1/2 transform -translate-y-1/2 text-white/50'"></i>
        <input
          [type]="type"
          [placeholder]="placeholder"
          [disabled]="disabled"
          [class]="inputClasses"
          [(ngModel)]="value"
          (blur)="onTouched()"
        />
      </div>
      <p *ngIf="error" class="text-danger text-sm mt-1">{{ error }}</p>
      <p *ngIf="hint && !error" class="text-white/50 text-sm mt-1">{{ hint }}</p>
    </div>
  `
})
export class InputComponent implements ControlValueAccessor {
  @Input() label?: string;
  @Input() placeholder = '';
  @Input() type: 'text' | 'email' | 'password' | 'number' | 'search' = 'text';
  @Input() icon?: string;
  @Input() disabled = false;
  @Input() required = false;
  @Input() error?: string;
  @Input() hint?: string;

  private _value: any = '';

  get value(): any {
    return this._value;
  }

  set value(val: any) {
    this._value = val;
    this.onChange(val);
  }

  get inputClasses(): string {
    const classes = ['input'];
    if (this.icon) classes.push('pl-10');
    if (this.error) classes.push('border-danger');
    return classes.join(' ');
  }

  onChange: any = () => { };
  onTouched: any = () => { };

  writeValue(value: any): void {
    this._value = value;
  }

  registerOnChange(fn: any): void {
    this.onChange = fn;
  }

  registerOnTouched(fn: any): void {
    this.onTouched = fn;
  }

  setDisabledState(isDisabled: boolean): void {
    this.disabled = isDisabled;
  }
}
