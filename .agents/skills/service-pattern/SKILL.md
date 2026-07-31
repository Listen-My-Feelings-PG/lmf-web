---
name: service-pattern
description: Convenciones estrictas sobre la modularidad de servicios HTTP, manejo de asincronía con RxJS, y gestión global de errores en Angular/Ionic.
---

# Service & State Pattern Skill

## 1. Modularidad de Servicios HTTP (Adiós al Monolito)
Queda estrictamente prohibido usar un único servicio (ej. `http.service.ts`) para agrupar todas las peticiones a la API.
- **Servicios por Dominio**: Cada feature o dominio de la aplicación debe tener su propio servicio responsable (Ej. `sondeo.service.ts`, `auth.service.ts`, `catalogos.service.ts`).
- **Inyección de Dependencias**: Inyecta únicamente los servicios que el componente o módulo en cuestión necesite.

## 2. Manejo de Asincronía: Observables (RxJS) sobre Promesas
El estándar del proyecto es aprovechar el diseño reactivo de Angular a través de Observables (RxJS).
- **No envolver en Promesas Clásicas**: Queda prohibido hacer `return new Promise((resolve, reject) => { this.http.get().subscribe(...) })`.
- **Retornar Observables**: Los métodos HTTP de los servicios deben retornar el `Observable` resultante de `HttpClient`. Los componentes o almacenes de estado (NgRx, Signals, etc.) son responsables de suscribirse a ellos (`.subscribe()` o `async pipe` en la vista).
- **Migración a async/await moderno (Si aplica)**: Si es absolutamente necesario usar Promesas para interoperar con librerías ajenas a RxJS (como Ionic Storage o Capacitor APIs), usa `firstValueFrom(this.http.get(...))` en lugar de constructores de `Promise` clásicos.

## 3. Manejo Global de Errores e Interceptores
- **Interceptores**: Para inyectar Tokens de Autorización en los headers y/o manejar errores HTTP (401, 403, 500) globalmente, se debe usar **HttpInterceptor** (o las funciones de interceptor modernas de Angular).
- **Prohibido manejo central manual**: No centralices el manejo de sesiones expiradas dentro de las funciones de un servicio HTTP. El interceptor se encargará de atrapar un 401/403, intentar renovar el token y/o expulsar al usuario (local logout).

> **Nota para el Agente**: Cuando se te pida crear una nueva integración con el backend, crea su propio servicio en `_services`, implementa las llamadas usando `Observable<T>`, e instancíalo donde sea necesario. No agregues métodos nuevos a un servicio HTTP general.
