import express, { Application, Request, Response, NextFunction } from 'express';
import { Server as HttpServer } from 'http';
import postgres, { Sql } from 'postgres';
import cookieParser from 'cookie-parser';
import cors from 'cors';
import compression from 'compression';
import fs from 'fs';
import dotenv from 'dotenv';
import { AppConfig, AppPaths } from './types/generals.types';
import { checkEnv } from './services/environment.service';

dotenv.config();
checkEnv();

const psql: Sql = postgres({
  host: process.env.DB_SERVER!,
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_DATABASE!,
  username: process.env.DB_USER!,
  password: process.env.DB_PASS!,
  max: 10,
  max_lifetime: 60 * 30
});

const directories: string[] = [
  process.env.AUDIO_PATH || './files/audio'
];

directories.forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
    console.info(`Directorio creado: ${dir}`);
  }
});

const app: Application = express();
const httpServer: HttpServer = require('http').Server(app);

app.disable('x-powered-by');
app.use(compression());
app.use(cors({
  origin: ['http://localhost:4200', 'http://localhost:5173'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.urlencoded({ extended: false, limit: '50mb' }));
app.use(express.json({ limit: '50mb' }));
app.use(cookieParser());

app.use('/audio', express.static(directories[0]));

app.use((req: Request, _res: Response, next: NextFunction) => {
  const timestamp = new Date().toISOString();
  console.info(`[${timestamp}] ${req.method} ${req.url}`);
  next();
});

const appPaths: AppPaths = {
  audio: directories[0]
};

export const config: AppConfig = {
  app,
  psql,
  paths: appPaths
};

export { app, psql, appPaths as paths };

import('./routes/index.routes');

app.use((err: Error, _req: Request, res: Response, _next: NextFunction) => {
  console.error('Error no manejado:', err);
  res.status(500).json({
    error: true,
    message: 'Error interno del servidor',
    details: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

const port = parseInt(process.env.PORT || process.env.HTTP_PORT || '3000');

httpServer.listen(port, async (error?: Error) => {
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

  // Inicializar sincronización de canciones almacenadas
  const { initializeStoragedSongs } = await import('./services/songs-storaged-initializer');
  await initializeStoragedSongs(directories[0]);
});
