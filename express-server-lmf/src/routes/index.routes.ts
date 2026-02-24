import { app } from '../main';
import playlistRoutes from './playlist.routes';
import songRoutes from './song.routes';

// Obtener todas las playlists
app.use('/api/v1/playlists', playlistRoutes);
app.use('/api/v1/songs', songRoutes);