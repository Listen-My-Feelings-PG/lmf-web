import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { HomeComponent } from './main/home/home.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'menu', component: HomeComponent },
      { path: '', redirectTo: 'menu', pathMatch: 'full' }
    ]
  },
  { path: '', redirectTo: 'main', pathMatch: 'full' }
];
