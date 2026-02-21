import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { LibraryComponent } from './main/library/library.component';
import { TrainingComponent } from './main/training/training.component';
import { PlayerComponent } from './player/player.component';
import { SpectrogramViewerComponent } from './spectrogram-viewer/spectrogram-viewer.component';
import { HomeComponent } from './main/home/home.component';

export const routes: Routes = [
  {
    path: 'main', component: MainComponent, children: [
      { path: 'library', component: LibraryComponent },
      { path: 'training', component: TrainingComponent },
      { path: 'player', component: PlayerComponent },
      { path: 'home', component: HomeComponent },
      { path: '', redirectTo: 'library', pathMatch: 'full' }
    ],
  },
  { path: 'spectrogram-viewer', component: SpectrogramViewerComponent },
  { path: '**', redirectTo: 'main', pathMatch: 'full' }
];
