import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { TrainingComponent } from './main/training/training.component';
import { PlayerComponent } from './player/player.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'training', component: TrainingComponent },
      { path: 'player', component: PlayerComponent },
      { path: '', redirectTo: 'training', pathMatch: 'full' }
    ]
  },
  { path: '**', redirectTo: 'main', pathMatch: 'full' }
];
