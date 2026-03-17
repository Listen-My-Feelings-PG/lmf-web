import { app } from '../main';
import playlistRoutes from './playlist.routes';
import songRoutes from './song.routes';
import statsRoutes from './stats.routes';

app.use('/api/v1/playlists', playlistRoutes);
app.use('/api/v1/songs', songRoutes);
app.use('/api/v1/stats', statsRoutes);