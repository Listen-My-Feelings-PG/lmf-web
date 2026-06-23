import { Injectable, NgZone } from '@angular/core';
import { io, Socket } from 'socket.io-client';
import { ToastService } from './toast.service';
import { Subject } from 'rxjs';

export interface TaskMessage {
  type: string;
  songId?: number;
  message: string;
}

@Injectable({
  providedIn: 'root'
})
export class SocketService {
  private socket!: Socket;

  public taskExec$ = new Subject<TaskMessage>();
  public taskFinish$ = new Subject<TaskMessage>();

  constructor(private toastService: ToastService, private ngZone: NgZone) { }

  public connect() {
    if (this.socket && this.socket.connected) return;

    const token = sessionStorage.getItem('lmf_token');
    if (!token) return;

    this.socket = io('http://localhost:3000', {
      extraHeaders: {
        Authorization: `Bearer ${token}`
      }
    });

    this.socket.on('connect', () => {
      console.log('Conectado a Socket.IO');
    });

    this.socket.on('task-exec', (data: TaskMessage) => {
      this.ngZone.run(() => {
        this.toastService.show(data.message, 'info');
        this.taskExec$.next(data);
      });
    });

    this.socket.on('task-finish', (data: TaskMessage) => {
      this.ngZone.run(() => {
        this.toastService.show(data.message, 'success');
        this.taskFinish$.next(data);
      });
    });

    this.socket.on('disconnect', () => {
      console.log('Desconectado de Socket.IO');
    });
  }

  public disconnect() {
    if (this.socket) {
      this.socket.disconnect();
    }
  }
}
