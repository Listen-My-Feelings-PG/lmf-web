# Comandos Útiles - Listen My Feelings

## 🖥️ Backend (Express)

### Desarrollo
```bash
cd express-server-lmf
npm run dev          # Iniciar con auto-reload (nodemon)
npm start            # Iniciar en modo producción
```

### Base de Datos
```bash
# Resetear base de datos
psql -U postgres -f db/lmf_db.sql

# Backup de base de datos
pg_dump -U postgres lmf_db_oneuser > db/backup.sql

# Restaurar backup
psql -U postgres lmf_db_oneuser < db/backup.sql

# Conectar a la base de datos
psql -U postgres -d lmf_db_oneuser

# Ver tablas
\dt

# Ver estructura de tabla
\d canciones
```

### Logs y Debug
```bash
# Ver logs en tiempo real
tail -f logs/server.log

# Ver errores
tail -f logs/error.log

# Debug con inspector de Node
node --inspect main.js
```

### Limpieza
```bash
# Limpiar archivos subidos (CUIDADO!)
rm -rf files/audio/*
rm -rf files/models/*
rm -rf files/features/*
rm -rf files/spectrograms/*

# Limpiar node_modules
rm -rf node_modules
npm install
```

---

## 🎨 Frontend (Angular)

### Desarrollo
```bash
cd angular-front-lmf
npm run serve                    # Iniciar dev server
ng serve --open                  # Abrir automáticamente
ng serve --port 4300            # Cambiar puerto
```

### Build
```bash
ng build                         # Build de desarrollo
ng build --configuration production  # Build de producción
ng build --prod --aot           # Build optimizado
```

### Testing
```bash
ng test                          # Ejecutar tests unitarios
ng test --watch=false           # Ejecutar tests una vez
ng test --code-coverage         # Con cobertura
ng e2e                          # Tests end-to-end
```

### Generación de Componentes
```bash
# Generar componente
ng generate component nombre --standalone

# Generar servicio
ng generate service nombre

# Generar modelo
ng generate interface nombre

# Generar pipe
ng generate pipe nombre
```

### Análisis
```bash
# Analizar tamaño del bundle
ng build --stats-json
npx webpack-bundle-analyzer dist/stats.json

# Lint
ng lint

# Format
ng format
```

---

## 🐍 Python (Feature Extraction)

### Instalar Dependencias
```bash
# Con pip
pip install -r requirements.txt

# Con conda
conda create -n lmf python=3.9
conda activate lmf
pip install -r requirements.txt
```

### Ejecutar Script Manualmente
```bash
# Extraer características de un archivo
python feature_extractor.py "ruta/al/archivo.mp3"

# Con output a archivo
python feature_extractor.py "archivo.mp3" > features.json

# Debug
python -m pdb feature_extractor.py "archivo.mp3"
```

### Actualizar Dependencias
```bash
# Actualizar librosa
pip install --upgrade librosa

# Ver versiones instaladas
pip list | grep librosa
pip list | grep numpy
```

---

## 🔧 Utilidades Generales

### Git
```bash
# Actualizar desde main
git pull origin main

# Ver cambios
git status
git diff

# Commit
git add .
git commit -m "feat: nueva funcionalidad"
git push

# Crear rama
git checkout -b feature/nueva-feature

# Ver logs
git log --oneline --graph

# Deshacer último commit (sin perder cambios)
git reset --soft HEAD~1
```

### NPM
```bash
# Limpiar caché
npm cache clean --force

# Reinstalar todo
rm -rf node_modules package-lock.json
npm install

# Actualizar dependencias
npm update

# Ver dependencias desactualizadas
npm outdated

# Auditar seguridad
npm audit
npm audit fix
```

### Docker (Opcional)
```bash
# Build imagen backend
docker build -t lmf-backend ./express-server-lmf

# Ejecutar contenedor
docker run -p 3000:3000 --env-file .env lmf-backend

# Docker compose (si tienes docker-compose.yml)
docker-compose up
docker-compose down

# Ver logs
docker logs lmf-backend

# Entrar al contenedor
docker exec -it lmf-backend /bin/bash
```

---

## 🧪 Testing y Debugging

### Backend Tests
```bash
# Instalar Jest
npm install --save-dev jest supertest

# Ejecutar tests
npm test

# Con cobertura
npm test -- --coverage

# Watch mode
npm test -- --watch
```

### Frontend Tests
```bash
# Karma + Jasmine
ng test

# Un solo componente
ng test --include='**/*.component.spec.ts'

# Con cobertura mínima requerida
ng test --code-coverage --coverageReporters=text-summary
```

### Debugging

**Backend (Node.js):**
```bash
# Con Chrome DevTools
node --inspect main.js
# Luego abre chrome://inspect

# Con VS Code
# Crear .vscode/launch.json:
{
  "type": "node",
  "request": "launch",
  "name": "Debug Backend",
  "program": "${workspaceFolder}/express-server-lmf/main.js"
}
```

**Frontend (Angular):**
```bash
# En browser DevTools
# Usa el source map para debuggear TypeScript directamente

# Con VS Code Debugger para Chrome
# Instalar extensión "Debugger for Chrome"
```

---

## 📊 Monitoreo y Performance

### Backend
```bash
# Instalar PM2 (process manager)
npm install -g pm2

# Iniciar con PM2
pm2 start main.js --name lmf-backend

# Ver status
pm2 status
pm2 logs lmf-backend

# Monitoreo
pm2 monit

# Restart
pm2 restart lmf-backend

# Stop
pm2 stop lmf-backend
```

### Database Performance
```bash
# Ver queries lentas
psql -U postgres -d lmf_db_oneuser

SELECT * FROM pg_stat_activity WHERE state = 'active';

# Analizar query
EXPLAIN ANALYZE SELECT * FROM canciones WHERE ca_activo = true;

# Reindexar
REINDEX TABLE canciones;
```

---

## 🚀 Deployment

### Backend (Heroku/Render)
```bash
# Heroku
heroku login
heroku create lmf-backend
git push heroku main

# Logs
heroku logs --tail

# Ejecutar comandos
heroku run bash
```

### Frontend (Vercel/Netlify)
```bash
# Vercel
npm install -g vercel
vercel login
vercel

# Netlify
npm install -g netlify-cli
netlify login
netlify deploy
```

---

## 💾 Backup y Restauración

### Backup Completo
```bash
# Script de backup
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)

# Backup DB
pg_dump -U postgres lmf_db_oneuser > backup_db_$DATE.sql

# Backup files
tar -czf backup_files_$DATE.tar.gz express-server-lmf/files/

echo "Backup completado: $DATE"
```

### Restauración
```bash
# Restaurar DB
psql -U postgres lmf_db_oneuser < backup_db_YYYYMMDD.sql

# Restaurar archivos
tar -xzf backup_files_YYYYMMDD.tar.gz
```

---

## 🔍 Troubleshooting

### Puerto ya en uso
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:3000 | xargs kill -9
```

### Node modules corruptos
```bash
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
```

### Python no encuentra librosa
```bash
# Verificar instalación
python -c "import librosa; print(librosa.__version__)"

# Reinstalar
pip uninstall librosa
pip install librosa
```

### PostgreSQL no conecta
```bash
# Verificar que está corriendo
sudo systemctl status postgresql  # Linux
brew services list  # Mac
services.msc  # Windows

# Reiniciar
sudo systemctl restart postgresql  # Linux
brew services restart postgresql  # Mac
```

---

## 📝 Notas Adicionales

### Variables de Entorno

```bash
# Backend (.env)
DB_SERVER=localhost
DB_PORT=5432
DB_DATABASE=lmf_db_oneuser
DB_USER=postgres
DB_PASS=password
HTTP_PORT=3000
NODE_ENV=development
PYTHON_PATH=python
```

### Puertos por Defecto

- Backend API: 3000
- Frontend Dev: 4200
- PostgreSQL: 5432

### URLs Importantes

- API Health Check: http://localhost:3000/api/v1/health
- Frontend: http://localhost:4200
- API Documentation (si implementas): http://localhost:3000/api-docs

---

**💡 Pro Tips:**

1. Usa `npm run dev` en backend para auto-reload durante desarrollo
2. Mantén dos terminales abiertas: una para backend, otra para frontend
3. Usa Git branches para features nuevas
4. Haz commits frecuentes con mensajes descriptivos
5. Prueba los endpoints con Postman o Thunder Client
6. Revisa los logs cuando algo falle
7. Mantén las dependencias actualizadas regularmente

---

¿Necesitas ayuda? Consulta [DEVELOPMENT.md](DEVELOPMENT.md) o [README.md](README.md)
