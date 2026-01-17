# Guía de Desarrollo - Listen My Feelings

## 📚 Tabla de Contenidos

1. [Arquitectura](#arquitectura)
2. [Componentes Principales](#componentes-principales)
3. [Flujo de Datos](#flujo-de-datos)
4. [Agregar Nuevas Funcionalidades](#agregar-nuevas-funcionalidades)
5. [Testing](#testing)
6. [Deployment](#deployment)

## Arquitectura

### Frontend (Angular 17)

```
angular-front-lmf/
├── src/app/
│   ├── _components/           # Componentes UI reutilizables
│   │   ├── button.component.ts
│   │   ├── input.component.ts
│   │   ├── modal.component.ts
│   │   ├── rating.component.ts
│   │   └── file-upload.component.ts
│   │
│   ├── _models/               # Modelos de datos TypeScript
│   │   ├── all.model.ts       # Song, Playlist, Model
│   │   └── types.ts           # Tipos auxiliares
│   │
│   ├── _services/             # Servicios de negocio
│   │   ├── http.service.ts    # Cliente HTTP con manejo de errores
│   │   ├── song.service.ts    # Lógica de canciones
│   │   ├── player.service.ts  # Reproductor de audio
│   │   └── tensorflow-v2.service.ts  # ML con TensorFlow.js
│   │
│   └── main/
│       └── library/           # Componente principal de biblioteca
│           ├── library.component.ts
│           ├── library.component.html
│           └── library.component.scss
```

### Backend (Express.js)

```
express-server-lmf/
├── controllers/               # Lógica de negocio
│   ├── song.controller.js     # CRUD de canciones
│   ├── playlist.controller.js # CRUD de playlists
│   └── model.controller.js    # CRUD de modelos
│
├── models/                    # Modelos de BD
│   ├── song.model.js
│   ├── playlist.model.js
│   └── model.model.js
│
├── routes/                    # Definición de rutas
│   ├── song.routes.js
│   ├── playlist.routes.js
│   ├── model.routes.js
│   └── index.routes.js
│
├── services/                  # Servicios auxiliares
│   └── file.service.js        # Manejo de archivos, ZIP, etc.
│
└── main.js                    # Punto de entrada
```

## Componentes Principales

### 1. ButtonComponent

Componente de botón reutilizable con variantes y estados.

```typescript
<app-button
  label="Guardar"
  icon="fas fa-save"
  variant="primary"
  size="md"
  [loading]="isSaving"
  (clicked)="save()"
></app-button>
```

**Props:**
- `label`: Texto del botón
- `icon`: Clase de ícono FontAwesome
- `variant`: 'primary' | 'success' | 'warning' | 'danger' | 'info' | 'outline'
- `size`: 'sm' | 'md' | 'lg'
- `loading`: Muestra spinner
- `disabled`: Deshabilitado
- `fullWidth`: Ancho completo

### 2. InputComponent

Input personalizado con soporte para FormControl.

```typescript
<app-input
  label="Nombre"
  placeholder="Ingresa el nombre"
  type="text"
  icon="fas fa-user"
  [(ngModel)]="name"
  [error]="errorMessage"
></app-input>
```

### 3. ModalComponent

Modal/Dialog reutilizable.

```typescript
<app-modal
  [(visible)]="showModal"
  title="Confirmar Acción"
  (confirmed)="onConfirm()"
  (cancelled)="onCancel()"
>
  <p>¿Estás seguro?</p>
</app-modal>
```

### 4. RatingComponent

Sistema de calificación por estrellas.

```typescript
<app-rating
  [value]="song.rating"
  [max]="3"
  (rated)="updateRating($event)"
></app-rating>
```

### 5. FileUploadComponent

Componente de carga de archivos con drag & drop.

```typescript
<app-file-upload
  label="Subir Canciones"
  accept="audio/mp3"
  [multiple]="true"
  (uploadFiles)="onUpload($event)"
></app-file-upload>
```

## Flujo de Datos

### Subida de Canciones

```
1. Usuario selecciona archivos
   ↓
2. FileUploadComponent emite archivos
   ↓
3. LibraryComponent crea FormData
   ↓
4. HTTP POST a /api/v1/songs/upload
   ↓
5. Backend guarda archivos
   ↓
6. Registro en BD (tabla canciones)
   ↓
7. Relación con playlist (tabla canciones_playlists)
   ↓
8. Respuesta con IDs de canciones
   ↓
9. Frontend recarga lista de canciones
```

### Extracción de Características

```
1. Usuario hace clic en "Extraer Características"
   ↓
2. HTTP POST a /api/v1/songs/:id/extract-features
   ↓
3. Backend ejecuta feature_extractor.py
   ↓
4. Python con librosa genera:
   - Espectrograma de Mel
   - Tempo, centroid, MFCCs, etc.
   ↓
5. Características se comprimen (gzip)
   ↓
6. Se guardan en /files/features/
   ↓
7. Se actualiza BD con ruta del archivo
   ↓
8. Frontend recibe confirmación
```

### Entrenamiento del Modelo

```
1. Usuario hace clic en "Entrenar Modelo"
   ↓
2. Frontend obtiene canciones con:
   - userRating !== null
   - featuresFile !== null
   ↓
3. Se descomprimen características
   ↓
4. TensorFlow.js crea modelo:
   - Input: Espectrograma normalizado
   - Capas: Conv2D + Dense
   - Output: Calificación predicha
   ↓
5. Entrenamiento con datos
   ↓
6. Modelo se serializa a JSON
   ↓
7. Se crea ZIP con modelo
   ↓
8. Se guarda en /files/models/
   ↓
9. Registro en BD (tabla modelos)
```

### Predicción

```
1. Usuario carga modelo existente
   ↓
2. Carga canciones sin calificar
   ↓
3. Extrae características de nuevas canciones
   ↓
4. Modelo predice calificación
   ↓
5. Se guarda predicción en BD
   ↓
6. Usuario revisa y corrige si es necesario
```

## Agregar Nuevas Funcionalidades

### Agregar un Nuevo Endpoint

#### 1. Backend

**Crear el controlador:**

```javascript
// controllers/mi-nueva-feature.controller.js
const { sendResponse, sendError } = require('../services/file.service');

async function miNuevaFuncion(req, res) {
  try {
    const { param } = req.body;
    
    // Lógica aquí
    
    sendResponse(res, true, data, 'Éxito');
  } catch (error) {
    sendError(res, 'Error en mi función', 500, error);
  }
}

module.exports = { miNuevaFuncion };
```

**Crear la ruta:**

```javascript
// routes/mi-nueva-feature.routes.js
const express = require('express');
const router = express.Router();
const controller = require('../controllers/mi-nueva-feature.controller');

router.post('/accion', controller.miNuevaFuncion);

module.exports = router;
```

**Registrar en index.routes.js:**

```javascript
const miNuevaFeatureRoutes = require('./mi-nueva-feature.routes');
app.use(`${API_PREFIX}/mi-feature`, miNuevaFeatureRoutes);
```

#### 2. Frontend

**Crear el servicio:**

```typescript
// _services/mi-feature.service.ts
@Injectable({ providedIn: 'root' })
export class MiFeatureService {
  constructor(private http: HttpService) {}
  
  async ejecutarAccion(data: any) {
    return this.http.post('mi-feature/accion', data, true).toPromise();
  }
}
```

**Usar en componente:**

```typescript
constructor(private miFeatureService: MiFeatureService) {}

async hacerAlgo() {
  try {
    const result = await this.miFeatureService.ejecutarAccion({ param: 'valor' });
    console.log('Resultado:', result);
  } catch (error) {
    console.error('Error:', error);
  }
}
```

### Agregar un Nuevo Componente UI

```typescript
// _components/mi-componente.component.ts
import { Component, Input, Output, EventEmitter } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-mi-componente',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="card p-4">
      <h3>{{ title }}</h3>
      <button class="btn btn-primary" (click)="accion.emit()">
        Hacer algo
      </button>
    </div>
  `
})
export class MiComponente {
  @Input() title = '';
  @Output() accion = new EventEmitter<void>();
}
```

## Testing

### Backend

```bash
# Instalar dependencias de testing
npm install --save-dev jest supertest

# Crear test
# tests/song.test.js
const request = require('supertest');
const { app } = require('../main');

describe('Song API', () => {
  test('GET /api/v1/songs', async () => {
    const response = await request(app).get('/api/v1/songs');
    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });
});

# Ejecutar tests
npm test
```

### Frontend

```bash
# Los tests ya están configurados con Jasmine/Karma

# Ejecutar tests
ng test

# Test de un componente
# library.component.spec.ts
describe('LibraryComponent', () => {
  it('should load playlists on init', async () => {
    const component = new LibraryComponent(...);
    await component.ngOnInit();
    expect(component.playlists.length).toBeGreaterThan(0);
  });
});
```

## Deployment

### Backend (Render/Heroku)

```bash
# 1. Crear Procfile
echo "web: node main.js" > Procfile

# 2. Configurar variables de entorno en el hosting
DB_SERVER=tu_servidor
DB_PORT=5432
DB_DATABASE=lmf_db_oneuser
DB_USER=tu_usuario
DB_PASS=tu_password
HTTP_PORT=3000
NODE_ENV=production

# 3. Desplegar
git push heroku main
```

### Frontend (Vercel/Netlify)

```bash
# 1. Build de producción
npm run build

# 2. Los archivos están en dist/
# 3. Configurar variables de entorno
# API_URL=https://tu-backend.herokuapp.com/api/v1

# 4. Desplegar
vercel deploy
```

### Consideraciones de Producción

1. **Seguridad:**
   - Usar HTTPS
   - Implementar rate limiting
   - Validar todos los inputs
   - Sanitizar datos

2. **Performance:**
   - Habilitar compresión (gzip)
   - Usar CDN para assets estáticos
   - Implementar caché
   - Optimizar tamaño de modelos

3. **Escalabilidad:**
   - Usar S3 o similar para archivos
   - Implementar queue para procesamiento de audio
   - Considerar microservicios

4. **Monitoreo:**
   - Logs centralizados (Winston, Sentry)
   - Métricas de performance
   - Alertas de errores

## Recursos Adicionales

- [Angular Docs](https://angular.io/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [TensorFlow.js](https://www.tensorflow.org/js)
- [Librosa Documentation](https://librosa.org/doc/latest/index.html)
- [Tailwind CSS](https://tailwindcss.com/docs)

## Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

**Happy Coding! 🎵**
