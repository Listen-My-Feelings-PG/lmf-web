# Listen My Feelings 🎵

Una biblioteca musical inteligente que utiliza Machine Learning para predecir tus preferencias musicales.

## 🎯 Características

- **Gestión de biblioteca musical**: Organiza tus canciones en playlists personalizadas
- **Calificación inteligente**: Califica tus canciones del 1 al 3
- **Extracción de características**: Genera espectrogramas de Mel automáticamente
- **Entrenamiento de modelos**: Utiliza TensorFlow.js para crear modelos personalizados
- **Predicción automática**: El modelo predice qué canciones te gustarán
- **Interfaz estilo Spotify**: Diseño moderno y amigable
- **Reproductor integrado**: Escucha tus canciones directamente en la plataforma

## 🏗️ Arquitectura

### Frontend
- **Framework**: Angular 17 (Standalone Components)
- **UI**: Tailwind CSS con componentes personalizados
- **ML**: TensorFlow.js para entrenamiento e inferencia
- **Estado**: RxJS para manejo reactivo

### Backend
- **Framework**: Express.js + Node.js
- **Base de datos**: PostgreSQL
- **Procesamiento**: Python con librosa para extracción de características
- **Storage**: Sistema de archivos local para audio, modelos y features

## 📋 Requisitos Previos

### Backend
- Node.js >= 18.x
- Python >= 3.9
- PostgreSQL >= 14

### Frontend
- Node.js >= 18.x
- npm >= 9.x

## 🚀 Instalación

### 1. Configurar Base de Datos

```bash
# Crear la base de datos en PostgreSQL
psql -U postgres -f db/lmf_db.sql
```

### 2. Configurar Backend

```bash
cd express-server-lmf

# Instalar dependencias de Node
npm install

# Instalar dependencias de Python
pip install -r ../requirements.txt

# Copiar y configurar variables de entorno
cp .env.example .env
# Editar .env con tus credenciales de PostgreSQL
```

Configurar `.env`:
```env
DB_SERVER=localhost
DB_PORT=5432
DB_DATABASE=lmf_db
DB_USER=postgres
DB_PASS=tu_password

HTTP_PORT=3000
NODE_ENV=development
PYTHON_PATH=python
```

### 3. Configurar Frontend

```bash
cd angular-front-lmf

# Instalar dependencias
npm install

# Configurar Tailwind CSS (ya está configurado)
# El archivo tailwind.config.js ya está creado
```

## 🎮 Uso

### Iniciar Backend

```bash
cd express-server-lmf
npm start

# O para desarrollo con auto-reload:
npm run dev
```

El servidor estará disponible en `http://localhost:3000`

### Iniciar Frontend

```bash
cd angular-front-lmf
npm run serve
```

La aplicación estará disponible en `http://localhost:4200`

## 📖 Flujo de Trabajo

### 1. Etapa de Entrenamiento

1. **Crear Playlist**: Crea una nueva playlist o usa la global
2. **Subir Canciones**: Sube archivos MP3 marcados como "para entrenar"
3. **Calificar**: Asigna una calificación (1-3) a cada canción
4. **Extraer Características**: El sistema genera espectrogramas de Mel automáticamente
5. **Entrenar Modelo**: Crea un modelo de ML con las canciones calificadas

### 2. Etapa de Predicción

1. **Subir Canciones**: Sube nuevas canciones marcadas como "para predecir"
2. **Predicción Automática**: El modelo predice la calificación que les darías
3. **Revisión**: Puedes revisar y escuchar las predicciones

### 3. Etapa de Inferencia

1. **Corregir Predicciones**: Ajusta las calificaciones incorrectas
2. **Reentrenar**: El modelo aprende de las correcciones
3. **Mejorar**: Con cada iteración, el modelo se vuelve más preciso

## 🗂️ Estructura del Proyecto

```
listen-my-feelings/
├── angular-front-lmf/          # Frontend Angular
│   ├── src/
│   │   ├── app/
│   │   │   ├── _components/    # Componentes UI reutilizables
│   │   │   ├── _models/        # Modelos de datos
│   │   │   ├── _services/      # Servicios (HTTP, TensorFlow, etc.)
│   │   │   └── main/
│   │   │       └── library/    # Componente principal de biblioteca
│   │   └── styles.scss         # Estilos globales con Tailwind
│   ├── tailwind.config.js      # Configuración de Tailwind
│   └── package.json
│
├── express-server-lmf/         # Backend Express
│   ├── controllers/            # Controladores de API
│   │   ├── song.controller.js
│   │   ├── playlist.controller.js
│   │   └── model.controller.js
│   ├── models/                 # Modelos de base de datos
│   ├── routes/                 # Rutas de API
│   ├── services/               # Servicios (archivos, etc.)
│   ├── files/                  # Almacenamiento de archivos
│   │   ├── audio/
│   │   ├── models/
│   │   ├── spectrograms/
│   │   └── features/
│   └── main.js                 # Punto de entrada
│
├── db/
│   └── lmf_db.sql             # Schema de base de datos
│
├── feature_extractor.py        # Script de extracción de características
└── requirements.txt            # Dependencias de Python
```

## 🔌 API Endpoints

### Canciones
- `POST /api/v1/songs/upload` - Subir canciones
- `GET /api/v1/songs` - Listar todas las canciones
- `GET /api/v1/songs/playlist/:id` - Canciones de una playlist
- `POST /api/v1/songs/:id/extract-features` - Extraer características
- `PUT /api/v1/songs/:id/rating` - Actualizar calificación
- `DELETE /api/v1/songs/:id` - Eliminar canción

### Playlists
- `POST /api/v1/playlists/get-all` - Listar playlists
- `POST /api/v1/playlists` - Crear playlist
- `PUT /api/v1/playlists/:id` - Actualizar playlist
- `DELETE /api/v1/playlists/:id` - Eliminar playlist

### Modelos
- `GET /api/v1/models` - Listar modelos
- `POST /api/v1/models/save` - Guardar modelo
- `GET /api/v1/models/:id/download` - Descargar modelo
- `POST /api/v1/models/predictions` - Actualizar predicciones

## 🎨 Personalización

### Colores

Los colores de la aplicación están definidos en `src/styles.scss` y `tailwind.config.js`:

- **Primary**: `#0032c8` (Azul principal)
- **Success**: `#00b400` (Verde)
- **Warning**: `#fadc00` (Amarillo)
- **Danger**: `#fa6400` (Naranja/Rojo)
- **Info**: `#46f0be` (Cyan/Turquesa)
- **Accent**: `#f0c81e` (Dorado)
- **Purple**: `#8278e6` (Morado)
- **Background**: Variaciones oscuras de morado

## 🐛 Solución de Problemas

### El backend no inicia
- Verifica que PostgreSQL esté corriendo
- Revisa las credenciales en `.env`
- Asegúrate de que el puerto 3000 esté disponible

### Error al extraer características
- Verifica que Python esté instalado y en el PATH
- Instala las dependencias: `pip install -r requirements.txt`
- Comprueba que librosa esté correctamente instalado

### Problemas de CORS
- Verifica que el backend esté corriendo en el puerto correcto
- El backend ya tiene CORS habilitado por defecto

## 🚧 Próximas Funcionalidades

- [ ] Soporte multiusuario con autenticación
- [ ] Visualización de espectrogramas en tiempo real
- [ ] Exportar/importar modelos
- [ ] Estadísticas y análisis de preferencias
- [ ] Recomendaciones basadas en similitud
- [ ] Integración con servicios de streaming
- [ ] API pública documentada con Swagger

## 📝 Notas Técnicas

### Características Extraídas

Para cada canción, se extraen:
- **Espectrograma de Mel**: Representación visual del audio en escala logarítmica
- **Tempo**: BPM de la canción
- **Centroid Espectral**: Brillo del sonido
- **Rolloff Espectral**: Frecuencia de corte
- **Zero Crossing Rate**: Indicador de percusividad
- **MFCCs**: 13 coeficientes cepstrales
- **RMS Energy**: Energía/volumen promedio

### Modelo de Machine Learning

- Arquitectura: Red neuronal secuencial con TensorFlow.js
- Input: Espectrograma de Mel normalizado (128 x 20000)
- Output: Calificación predicha (0-3)
- Optimizador: Adam
- Loss: Mean Squared Error

## 📄 Licencia

ISC

## 👤 Autor

Pench

---

**¿Preguntas o problemas?** Abre un issue en el repositorio.
