---
name: frontend-architecture
description: Reglas estrictas sobre la arquitectura de directorios y componentes en el entorno Frontend (Angular/Ionic/Vue).
---

# Frontend Architecture Skill

## 1. Estructura de Directorios (Módulos Compartidos vs Módulos de Características)
Se debe mantener una estricta separación de responsabilidades a nivel de carpetas. Todo código reutilizable (servicios, modelos, utilidades) debe situarse en directorios precedidos por un guion bajo `_` para denotar su naturaleza de "núcleo" o "compartido".

- **Carpetas con prefijo `_`**:
  - `_services/`: Servicios modulares e interceptores (Ej. `auth.service.ts`, `sondeo.service.ts`, `auth.interceptor.ts`).
  - `_models/`: Interfaces, tipos y clases de datos (`generals.model.ts`, `interfaces.model.ts`).
  - `_utils/`: Funciones puras de utilidad (`logcat.util.ts`, `formatters.ts`).
  - `_components/`: Componentes UI reutilizables (Smart/Dumb) que no pertenecen a un módulo específico.
  - `_guards/`: Guards de enrutamiento para protección de rutas.

- **Módulos de características (Feature Modules)**:
  - Todas las vistas, flujos o pantallas principales deben agruparse en carpetas con nombres descriptivos de dominio SIN prefijo (Ej. `login`, `main`, `sondeo`, `dashboard`).
  - Cada Feature Module debe ser lo más independiente posible.

## 2. Componentes Smart vs Dumb (Container vs Presentational)
- **Componentes Smart (Contenedores)**: Son los responsables de inyectar dependencias (servicios), manejar el estado global, e interactuar con la lógica de negocio. Pasan datos (Inputs) a los componentes Dumb y escuchan sus eventos (Outputs).
- **Componentes Dumb (Presentacionales)**: Solo reciben datos por `@Input()` y emiten acciones por `@Output()`. No deben inyectar servicios relacionados al negocio ni manejar peticiones HTTP directamente.

## 3. Nombrado de Archivos
- Mantener la convención de Angular (Kebab-case): `feature.component.ts`, `feature.service.ts`, `feature.module.ts`.

> **Nota para el Agente**: Siempre que crees un nuevo servicio, utilería, modelo o componente compartido, colócalo en el directorio `_` correspondiente. Si creas una vista o funcionalidad completa, aíslala en su propia carpeta en la raíz de la app (ej. `src/app/feature-name`).
