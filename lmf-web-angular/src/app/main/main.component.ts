import { Component, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { MenuItem } from 'primeng/api';
import { ButtonModule } from 'primeng/button';
import { MenubarModule } from 'primeng/menubar';
import { AvatarModule } from 'primeng/avatar';
import { MenuModule } from 'primeng/menu';
import { PlayerComponent } from '../player/player.component';

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
  ],
  templateUrl: './main.component.html',
  styleUrl: './main.component.scss'
})
export class MainComponent implements OnInit {
  menuItems: MenuItem[] | undefined;
  profileItems: MenuItem[] | undefined;
  constructor(
  ) { }
  ngOnInit(): void {
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
}
