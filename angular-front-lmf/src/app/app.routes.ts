import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { HomeComponent } from './main/home/home.component';
import { ListComponent } from './list/list.component';
import { TrainingComponent } from './main/training/training.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'menu', component: HomeComponent },
      { path: 'list', component: ListComponent },
      { path: 'training', component: TrainingComponent },
      { path: '', redirectTo: 'list', pathMatch: 'full' }
    ]
  },
  { path: '', redirectTo: 'main', pathMatch: 'full' }
];
