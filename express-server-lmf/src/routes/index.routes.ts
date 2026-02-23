import { app } from '../main';
import playlistRoutes from './playlist.routes';

// Obtener todas las playlists
app.use('/api/v1/playlists', playlistRoutes);