# Guía de Despliegue en Render

## 🚀 Configuración en Render Dashboard

Cuando crees tu Web Service en Render, usa esta configuración:

### Settings Básicos

- **Name**: `listen-my-feelings-api` (o el nombre que prefieras)
- **Environment**: `Node`
- **Region**: Elige la más cercana a tus usuarios
- **Branch**: `main` (o tu rama principal)
- **Root Directory**: `express-server-lmf`

### Build & Deploy Settings

#### Build Command:
```bash
npm install && npm run build
```

#### Start Command:
```bash
npm run start:prod
```

### Variables de Entorno

En la sección "Environment" de Render, agrega estas variables:

```
DB_SERVER=tu_servidor_postgres
DB_PORT=5432
DB_DATABASE=lmf_db_oneuser
DB_USER=tu_usuario
DB_PASS=tu_contraseña
HTTP_PORT=3000
NODE_ENV=production
AUDIO_PATH=./files/audio
MODELS_PATH=./files/models
SPECTROGRAMS_PATH=./files/spectrograms
PYTHON_PATH=python3
```

## 📋 Pasos Detallados

### 1. Preparar tu Repositorio

Asegúrate de que tu código esté en GitHub/GitLab/Bitbucket:

```bash
git add .
git commit -m "Ready for Render deployment"
git push origin main
```

### 2. Crear Web Service en Render

1. Ve a [Render Dashboard](https://dashboard.render.com/)
2. Click en "New +" → "Web Service"
3. Conecta tu repositorio
4. Configura según los settings de arriba

### 3. Base de Datos PostgreSQL

Si no tienes una BD externa:

1. En Render: "New +" → "PostgreSQL"
2. Crea la base de datos
3. Copia el "Internal Database URL" o los valores individuales
4. Agrégalos como variables de entorno en tu Web Service

### 4. Deploy

Render automáticamente:
1. ✅ Clona tu repositorio
2. ✅ Ejecuta `npm install`
3. ✅ Ejecuta `npm run build` (compila TypeScript → JavaScript)
4. ✅ Crea el directorio `dist/` con los archivos compilados
5. ✅ Ejecuta `npm run start:prod` (inicia desde `dist/main.js`)

## 🔄 Redeploys Automáticos

Cada vez que hagas `git push` a tu rama principal, Render:
- Detecta los cambios
- Recompila todo (`npm run build`)
- Reinicia el servidor

## 🐛 Troubleshooting

### Error: "Module not found"
- Verifica que todas las dependencias estén en `dependencies` (no solo en `devDependencies`)
- Asegúrate de que TypeScript compile correctamente localmente

### Error de Base de Datos
- Verifica las variables de entorno
- Asegúrate de que la BD permita conexiones externas
- Revisa el firewall/whitelist de tu BD

### Puerto Incorrecto
Render asigna el puerto automáticamente vía `process.env.PORT`:
```typescript
const port = parseInt(process.env.PORT || process.env.HTTP_PORT || '3000');
```

## 📁 Estructura de Archivos en Render

```
/opt/render/project/
├── src/               # Tu código TypeScript (Git)
├── dist/              # Generado por build (NO en Git)
├── node_modules/      # Generado por npm install
├── files/             # Archivos de la app (persisten con Disks)
└── package.json       # Tu configuración
```

## 💾 Persistencia de Archivos

Los archivos en `files/` (audio, modelos, etc.) se perderán en cada redeploy a menos que uses **Render Disks**:

1. En tu servicio → "Disks"
2. Add Disk
3. Mount Path: `/opt/render/project/src/express-server-lmf/files`
4. Size: Según necesites

## 🎯 Resumen

**NO subas `dist/` a Git** ❌  
**Render lo genera automáticamente** ✅

Render es el entorno ideal para Node.js + TypeScript porque maneja la compilación automáticamente.

---

¿Dudas? Revisa los logs en Render Dashboard → Tu servicio → Logs
