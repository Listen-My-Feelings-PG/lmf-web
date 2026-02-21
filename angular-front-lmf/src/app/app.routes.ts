import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { MenuComponent } from './main/menu/menu.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'menu', component: MenuComponent },
      { path: '', redirectTo: 'menu', pathMatch: 'full' }
    ]
  },
  { path: '', redirectTo: 'main', pathMatch: 'full' }
];
