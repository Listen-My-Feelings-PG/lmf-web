const express = require('express');
const app = express();
const httpServer = require('http').Server(app);
const postgres = require('postgres');
const cookieParser = require('cookie-parser');

require('dotenv').config();

const psql = postgres({
  host: process.env.DB_SERVER,
  port: process.env.DB_PORT,
  database: process.env.DB_DATABASE,
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
  max: 1,
  max_lifetime: 3000
});

app.disable('x-powered-by');
app.use(express.urlencoded({ extended: false }));

// Middleware específico para chunks de imagen - debe ir antes del middleware JSON
app.use('/api/v1/uploads/boleta/image/chunk', express.raw({
  type: 'application/octet-stream',
  limit: '10mb'
}));

app.use(express.json({ limit: '10mb' }));

app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Methods', 'GET, POST');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Static-hash, X-File-Name, X-Boleta-Id, X-Chunk-Index, X-Total-Chunks');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  console.info(req.url, req.method, new Date().toLocaleString());
  next();
});

app.use(cookieParser());

module.exports = {
  app: app,
  psql
}

require('./routes/index.routes');

const port = process.env.HTTP_PORT || 3000;
const appOtaService = require('./services/app-ota.service');

httpServer.listen(port, (error) => {
  if (error)
    console.error('Error al iniciar el servidor:', error);
  appOtaService.main();
  console.info('Servidor iniciado en el puerto:', port);
});