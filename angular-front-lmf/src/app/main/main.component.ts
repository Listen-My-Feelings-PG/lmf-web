import { Component, OnInit } from '@angular/core';
import { RouterOutlet, RouterLink } from '@angular/router';
import { PlayerComponent } from '../player/player.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-main',
  standalone: true,
  imports: [
    RouterOutlet,
    RouterLink,
    PlayerComponent,
    CommonModule
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  menuItems: any[] | undefined;
  profileItems: any[] | undefined;
  menubarVisible: boolean;
  timer: any;
  constructor(
  ) {
    this.menubarVisible = true;
  }
  ngOnInit(): void {
    this.hideMenubar();
    this.menuItems = [
      {
        label: 'Listen my Feelings',
        icon: 'pi pi-music',
        styleClass: 'menu-title',
      },
      {
        label: 'Biblioteca',
        icon: 'pi pi-book'
      },
      {
        label: 'Descubre',
        icon: 'pi pi-compass',
        routerLink: 'player'
      },
      {
        label: 'Entrenamiento',
        icon: 'pi pi-chart-line',
        routerLink: 'training'
      }
    ];
    this.profileItems = [
      {
        label: 'Options',
        items: [
          {
            label: 'Refresh',
            icon: 'pi pi-refresh'
          },
          {
            label: 'Export',
            icon: 'pi pi-upload'
          }
        ]
      }
    ];
  }

  showMenuBar(): void {
    this.menubarVisible = true;
  }

  clearTimer() {
    clearTimeout(this.timer);
  }

  hideMenubar(): void {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.menubarVisible = false;
    }, 500);
  }
}
