import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { TrainingComponent } from './main/training/training.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'training', component: TrainingComponent },
      { path: '', redirectTo: 'training', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'main', pathMatch: 'full' }
];
