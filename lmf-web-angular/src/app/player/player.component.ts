import { CommonModule } from '@angular/common';
import { Component, ElementRef, Input, OnChanges, SimpleChanges, ViewChild } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { ButtonGroupModule } from 'primeng/buttongroup';

@Component({
  selector: 'app-player',
  standalone: true,
  imports: [CommonModule, ButtonModule, ButtonGroupModule],
  templateUrl: './player.component.html',
  styleUrl: './player.component.scss'
})
export class PlayerComponent implements OnChanges {
  @Input() songUrl: string = ''; // URL de la canción recibida del componente padre
  @ViewChild('audioPlayer') audioPlayer!: ElementRef<HTMLAudioElement>;

  isPlaying = false;
  currentTime = 0;
  duration = 0;

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['songUrl'] && changes['songUrl'].currentValue) {
      this.playNewSong();
    }
  }

  playNewSong(): void {
    const audio = this.audioPlayer.nativeElement;

    // Detener cualquier reproducción en curso
    audio.pause();

    // Cargar la nueva URL y reproducir
    audio.src = this.songUrl;
    audio.load();
    audio.play().then(() => {
      this.isPlaying = true;
    }).catch((error) => {
      console.error('Error al reproducir la canción:', error);
      this.isPlaying = false;
    });
  }

  togglePlayPause(): void {
    const audio = this.audioPlayer.nativeElement;
    if (this.isPlaying) {
      audio.pause();
    } else {
      audio.play();
    }
    this.isPlaying = !this.isPlaying;
  }

  updateProgress(): void {
    const audio = this.audioPlayer.nativeElement;
    this.currentTime = audio.currentTime;
  }

  updateMetadata(): void {
    const audio = this.audioPlayer.nativeElement;
    this.duration = audio.duration;
  }

  onSeek(event: Event): void {
    const input = event.target as HTMLInputElement;
    const audio = this.audioPlayer.nativeElement;
    audio.currentTime = parseFloat(input.value);
    this.currentTime = audio.currentTime;
  }

  formatTime(seconds: number): string {
    const minutes = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${minutes}:${secs < 10 ? '0' : ''}${secs}`;
  }
}
