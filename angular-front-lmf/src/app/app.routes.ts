import { Routes } from '@angular/router';
import { MainComponent } from './main/main.component';
import { HomeComponent } from './main/home/home.component';
import { ListComponent } from './list/list.component';
import { TrainingComponent } from './main/training/training.component';
import { PredictionComponent } from './main/prediction/prediction.component';
import { StatsComponent } from './main/stats/stats.component';
import { VocadbComponent } from './main/vocadb/vocadb.component';
import { LoginComponent } from './login/login.component';
import { AuthGuard } from './_guards/auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'main', 
    component: MainComponent, 
    canActivate: [AuthGuard],
    children: [
      { path: 'menu', component: HomeComponent },
      { path: 'list', component: ListComponent },
      { path: 'training', component: TrainingComponent },
      { path: 'prediction', component: PredictionComponent },
      { path: 'stats', component: StatsComponent },
      { path: 'vocadb', component: VocadbComponent },
      { path: '', redirectTo: 'list', pathMatch: 'full' }
    ]
  },
  { path: '', redirectTo: 'main', pathMatch: 'full' }
];
