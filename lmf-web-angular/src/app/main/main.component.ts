import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MenuItem } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { MenubarModule } from 'primeng/menubar';
import { AvatarModule } from 'primeng/avatar';
import { MenuModule } from 'primeng/menu';
import { PlayerComponent } from '../player/player.component';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-main',
  standalone: true,
  imports: [
    RouterOutlet,
    MenubarModule,
    ButtonModule,
    AvatarModule,
    MenuModule,
    PlayerComponent,
    CommonModule
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  menuItems: MenuItem[] | undefined;
  profileItems: MenuItem[] | undefined;
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
