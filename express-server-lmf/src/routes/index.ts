import { app } from '../main';
import songRoutes from './song.routes';
import playlistRoutes from './playlist.routes';
import modelRoutes from './model.routes';

// Configurar rutas con prefijo API
const API_PREFIX = '/api/v1';

// Rutas de canciones
app.use(`${API_PREFIX}/songs`, songRoutes);

// Rutas de playlists
app.use(`${API_PREFIX}/playlists`, playlistRoutes);

// Rutas de modelos
app.use(`${API_PREFIX}/models`, modelRoutes);

// Ruta de health check
app.get(`${API_PREFIX}/health`, (_req, res) => {
  res.json({
    success: true,
    message: 'Listen My Feelings API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Ruta por defecto
app.get('/', (_req, res) => {
  res.json({
    success: true,
    message: 'Listen My Feelings API',
    endpoints: {
      health: `${API_PREFIX}/health`,
      songs: `${API_PREFIX}/songs`,
      playlists: `${API_PREFIX}/playlists`,
      models: `${API_PREFIX}/models`
    }
  });
});

export { };
