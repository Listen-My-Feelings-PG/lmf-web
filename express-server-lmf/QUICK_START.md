# 🚀 Inicio Rápido - Express Server TypeScript

## Instalación

```bash
cd express-server-lmf
npm install
```

## Desarrollo

```bash
# Iniciar servidor en modo desarrollo (hot-reload)
npm start
```

El servidor se iniciará en `http://localhost:3000` (o el puerto configurado en `.env`)

## Compilar para Producción

```bash
# Compilar TypeScript a JavaScript
npm run build
```

## Producción

```bash
# Iniciar servidor desde archivos compilados
npm run start:prod
```

**Para desplegar en Render:** Ver [DEPLOY_RENDER.md](DEPLOY_RENDER.md)

## Verificar Estado

Abre en el navegador o usa curl:
```bash
curl http://localhost:3000/api/v1/health
```

Deberías ver:
```json
{
  "success": true,
  "message": "Listen My Feelings API is running",
  "timestamp": "2026-02-21T...",
  "version": "1.0.0"
}
```

## Variables de Entorno Requeridas

Crea un archivo `.env` con:

```env
# Base de datos
DB_SERVER=localhost
DB_PORT=5432
DB_DATABASE=lmf_db_oneuser
DB_USER=postgres
DB_PASS=tu_contraseña

# Servidor
HTTP_PORT=3000
NODE_ENV=development

# Rutas de archivos
AUDIO_PATH=./files/audio
MODELS_PATH=./files/models
SPECTROGRAMS_PATH=./files/spectrograms

# Python
PYTHON_PATH=python
```

## Endpoints Principales

### Health Check
```bash
GET /api/v1/health
```

### Canciones
```bash
POST   /api/v1/songs/upload           # Subir canciones
GET    /api/v1/songs                  # Listar todas
GET    /api/v1/songs/:id              # Obtener por ID
DELETE /api/v1/songs/:id              # Eliminar
```

### Playlists
```bash
POST   /api/v1/playlists/get-all      # Listar todas
GET    /api/v1/playlists/:id          # Obtener por ID
POST   /api/v1/playlists              # Crear nueva
DELETE /api/v1/playlists/:id          # Eliminar
```

### Modelos
```bash
GET    /api/v1/models                 # Listar todos
GET    /api/v1/models/global          # Obtener modelo global
POST   /api/v1/models/save            # Guardar modelo
```

## Scripts Disponibles

```bash
npm start          # Desarrollo con hot-reload
npm run build      # Compilar TypeScript
npm run start:prod # Iniciar en producción
```

## Estructura de Carpetas

```
express-server-lmf/
├── src/              # Código fuente TypeScript
│   ├── main.ts       # Entrada principal
│   ├── controllers/  # Controladores
│   ├── models/       # Modelos de BD
│   ├── routes/       # Rutas de API
│   ├── services/     # Servicios
│   └── types/        # Definiciones de tipos
├── dist/             # Código compilado (generado)
├── files/            # Archivos de la app
│   ├── audio/        # Archivos de audio
│   ├── models/       # Modelos ML
│   ├── features/     # Características
│   └── spectrograms/ # Espectrogramas
└── node_modules/     # Dependencias
```

## ¿Problemas?

### No se encuentra el módulo
```bash
npm install
```

### Error de compilación
```bash
npm run clean
npm run build
```

### Puerto en uso
Cambia `HTTP_PORT` en `.env` a otro puerto (ej: 3001, 8080)

### Error de base de datos
- Verifica que PostgreSQL esté corriendo
- Revisa las credenciales en `.env`
- Ejecuta el script de BD: `psql -U postgres -f ../db/lmf_db.sql`

---

¡Listo para desarrollar! 🎵
