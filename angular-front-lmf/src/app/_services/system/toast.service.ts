import { Injectable } from '@angular/core';
import { Subject } from 'rxjs';

export interface ToastMessage {
  message: string;
  type: 'success' | 'error' | 'info' | 'warning';
  id?: number;
}

@Injectable({
  providedIn: 'root'
})
export class ToastService {
  private toasts: ToastMessage[] = [];
  public toasts$ = new Subject<ToastMessage[]>();
  private idCounter = 0;

  show(message: string, type: 'success' | 'error' | 'info' | 'warning' = 'info') {
    const id = this.idCounter++;
    const toast = { message, type, id };
    this.toasts.push(toast);
    this.toasts$.next(this.toasts);

    setTimeout(() => {
      this.remove(id);
    }, 5000);
  }

  remove(id: number) {
    this.toasts = this.toasts.filter(t => t.id !== id);
    this.toasts$.next(this.toasts);
  }
}
