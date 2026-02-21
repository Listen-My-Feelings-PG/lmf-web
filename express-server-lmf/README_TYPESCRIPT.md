# Express Server LMF - TypeScript

Servidor Express con TypeScript para Listen My Feelings.

## 🚀 Características

- ✅ TypeScript configurado con tipos estrictos
- ✅ Arquitectura modular (Models, Controllers, Routes, Services)
- ✅ PostgreSQL con `postgres` library
- ✅ Manejo de archivos con Multer
- ✅ Compresión de características de audio
- ✅ API RESTful

## 📁 Estructura del Proyecto

```
express-server-lmf/
├── src/
│   ├── main.ts                 # Punto de entrada de la aplicación
│   ├── types/                  # Definiciones de tipos TypeScript
│   │   ├── index.ts
│   │   └── models.ts
│   ├── models/                 # Modelos de base de datos
│   │   ├── song.model.ts
│   │   ├── playlist.model.ts
│   │   ├── model.model.ts
│   │   └── auth.model.ts
│   ├── controllers/            # Controladores de lógica de negocio
│   │   ├── song.controller.ts
│   │   ├── playlist.controller.ts
│   │   ├── model.controller.ts
│   │   └── auth.controller.ts
│   ├── routes/                 # Rutas de la API
│   │   ├── index.ts
│   │   ├── song.routes.ts
│   │   ├── playlist.routes.ts
│   │   ├── model.routes.ts
│   │   └── auth.routes.ts
│   └── services/               # Servicios auxiliares
│       ├── file.service.ts
│       └── utils.service.ts
├── files/                      # Archivos generados
│   ├── audio/
│   ├── models/
│   ├── features/
│   └── spectrograms/
├── dist/                       # Código compilado (generado)
├── tsconfig.json              # Configuración de TypeScript
├── package.json
└── .env                       # Variables de entorno

```

## 🛠️ Instalación

1. **Instalar dependencias:**
```bash
npm install
```

2. **Configurar variables de entorno:**
Copia `.env.example` a `.env` y configura las variables:
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

## 🚀 Scripts Disponibles

### Desarrollo
```bash
npm start
# Inicia el servidor en modo desarrollo con hot-reload (ts-node + nodemon)
```

### Producción
```bash
# Compilar TypeScript
npm run build

# Iniciar servidor compilado
npm run start:prod
```

**Para desplegar en Render/servicios en la nube:**  
Ver guía completa en [DEPLOY_RENDER.md](DEPLOY_RENDER.md)

## 🔧 Desarrollo con TypeScript

### Tipos de TypeScript

Los tipos están definidos en `src/types/`:
- `index.ts`: Tipos generales (AppConfig, ApiResponse, etc.)
- `models.ts`: Tipos de modelos de base de datos

### Compilación

TypeScript se compila con las siguientes opciones (ver `tsconfig.json`):
- **Target**: ES2020
- **Module**: CommonJS
- **Strict mode**: Habilitado
- **Output**: `dist/`

### Estructura de Código

**Modelos** (`src/models/`):
- Clases estáticas para interactuar con PostgreSQL
- Tipado completo de queries y respuestas

**Controladores** (`src/controllers/`):
- Funciones async/await con tipos Express (Request, Response)
- Manejo de errores con tipos

**Rutas** (`src/routes/`):
- Express Router con imports ES6
- Exportación por default

**Servicios** (`src/services/`):
- Funciones utilitarias tipadas
- Logger, manejo de archivos, etc.

## 🔌 API Endpoints

### Health Check
```
GET /api/v1/health
```

### Canciones (Songs)
```
POST   /api/v1/songs/upload
GET    /api/v1/songs
GET    /api/v1/songs/playlist/:playlistId
GET    /api/v1/songs/status/:status
POST   /api/v1/songs/:songId/extract-features
GET    /api/v1/songs/:songId/features
PUT    /api/v1/songs/:songId/rating
GET    /api/v1/songs/:songId/download
DELETE /api/v1/songs/:songId
```

### Playlists
```
POST   /api/v1/playlists/get-all
GET    /api/v1/playlists/global
GET    /api/v1/playlists/:playlistId
POST   /api/v1/playlists
PUT    /api/v1/playlists/:playlistId
DELETE /api/v1/playlists/:playlistId
POST   /api/v1/playlists/add-song
POST   /api/v1/playlists/remove-song
```

### Modelos ML
```
GET    /api/v1/models
GET    /api/v1/models/global
GET    /api/v1/models/playlist/:playlistId
GET    /api/v1/models/:modelId
POST   /api/v1/models/save
GET    /api/v1/models/:modelId/download
POST   /api/v1/models/predictions
PUT    /api/v1/models/:modelId/deactivate
```

## 📝 Migración desde JavaScript

El proyecto ha sido migrado de JavaScript a TypeScript manteniendo:
- ✅ La misma arquitectura de carpetas
- ✅ Los mismos endpoints de API
- ✅ La misma lógica de negocio
- ✅ Compatibilidad con el código Python (feature_extractor.py)

### Cambios principales:
1. Todos los archivos `.js` → `.ts`
2. `require()` → `import/export`
3. `module.exports` → `export default` o `export`
4. Añadidos tipos TypeScript en todas las funciones
5. Configuración de `tsconfig.json`
6. Scripts actualizados en `package.json`

## 🐛 Troubleshooting

**Error: Cannot find module 'postgres'**
```bash
npm install
```

**Error de compilación TypeScript**
```bash
npm run start:prod
```
Este comando limpiará `dist/` y recompilará todo.

**Error de conexión a PostgreSQL**
- Verifica las credenciales en `.env`
- Asegúrate de que PostgreSQL esté corriendo
- Verifica el puerto (por defecto 5432)

## 📄 Licencia

ISC
