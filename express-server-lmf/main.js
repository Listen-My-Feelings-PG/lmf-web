const express = require('express');
const app = express();
const httpServer = require('http').Server(app);
const postgres = require('postgres');
const cookieParser = require('cookie-parser');
const cors = require('cors');
const compression = require('compression');
const path = require('path');
const fs = require('fs');

require('dotenv').config();

// Configuración de PostgreSQL
const psql = postgres({
  host: process.env.DB_SERVER,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  max: 10,
  max_lifetime: 60 * 30
});

// Crear directorios necesarios si no existen
const directories = [
  process.env.AUDIO_PATH || './files/audio',
  process.env.MODELS_PATH || './files/models',
  process.env.SPECTROGRAMS_PATH || './files/spectrograms',
  './files/features'
];

directories.forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.info(`Directorio creado: ${dir}`);
  }
});

// Middleware de seguridad y configuración
app.disable('x-powered-by');
app.use(compression());
app.use(cors());
app.use(express.urlencoded({ extended: false, limit: '50mb' }));
app.use(express.json({ limit: '50mb' }));
app.use(cookieParser());

// Servir archivos estáticos
app.use('/audio', express.static(directories[0]));
app.use('/models', express.static(directories[1]));
app.use('/spectrograms', express.static(directories[2]));

// Logger middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.info(`[${timestamp}] ${req.method} ${req.url}`);
  next();
});

// Exportar para usar en controladores
module.exports = {
  app,
  psql,
  paths: {
    audio: directories[0],
    models: directories[1],
    spectrograms: directories[2],
    features: './files/features'
  }
};

// Cargar rutas
require('./routes/index.routes');

// Manejador de errores global
app.use((err, req, res, next) => {
  console.error('Error no manejado:', err);
  res.status(500).json({
    error: true,
    message: 'Error interno del servidor',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Iniciar servidor
const port = process.env.HTTP_PORT || 3000;

httpServer.listen(port, (error) => {
  if (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
  console.info('='.repeat(50));
  console.info('🎵 Listen My Feelings Server');
  console.info(`Servidor iniciado en puerto: ${port}`);
  console.info(`Entorno: ${process.env.NODE_ENV || 'development'}`);
  console.info(`Base de datos: ${process.env.DB_DATABASE}`);
  console.info('='.repeat(50));
});