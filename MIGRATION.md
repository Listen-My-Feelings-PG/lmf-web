# 🔄 Guía de Migración - De PrimeNG a Tailwind CSS

Esta guía te ayudará a migrar componentes del antiguo código con PrimeNG al nuevo sistema con Tailwind CSS.

---

## 📋 Tabla de Equivalencias

### Botones

#### Antes (PrimeNG)
```html
<p-button 
  label="Guardar"
  icon="pi pi-save"
  severity="primary"
  [outlined]="true"
  (onClick)="save()"
></p-button>
```

#### Ahora (Tailwind + Custom Component)
```html
<app-button
  label="Guardar"
  icon="fas fa-save"
  variant="primary"
  (clicked)="save()"
></app-button>
```

---

### Inputs

#### Antes (PrimeNG)
```html
<input 
  type="text" 
  pInputText 
  [(ngModel)]="name"
  placeholder="Nombre"
/>
```

#### Ahora (Custom Component)
```html
<app-input
  label="Nombre"
  type="text"
  placeholder="Ingresa tu nombre"
  [(ngModel)]="name"
></app-input>
```

---

### File Upload

#### Antes (PrimeNG)
```html
<p-fileUpload 
  mode="basic"
  chooseLabel="Subir"
  accept="audio/mp3"
  [multiple]="true"
  (onSelect)="onUpload($event)"
></p-fileUpload>
```

#### Ahora (Custom Component)
```html
<app-file-upload
  accept="audio/mp3"
  [multiple]="true"
  (uploadFiles)="onUpload($event)"
></app-file-upload>
```

---

### Modals/Dialogs

#### Antes (PrimeNG)
```html
<p-dialog 
  [(visible)]="displayModal"
  header="Título"
  [modal]="true"
>
  <p>Contenido</p>
  <ng-template pTemplate="footer">
    <p-button label="Cancelar" (onClick)="close()"></p-button>
    <p-button label="Guardar" (onClick)="save()"></p-button>
  </ng-template>
</p-dialog>
```

#### Ahora (Custom Component)
```html
<app-modal
  [(visible)]="displayModal"
  title="Título"
  (confirmed)="save()"
  (cancelled)="close()"
>
  <p>Contenido</p>
</app-modal>
```

---

### Tables

#### Antes (PrimeNG)
```html
<p-table [value]="items">
  <ng-template pTemplate="header">
    <tr>
      <th>Nombre</th>
      <th>Acciones</th>
    </tr>
  </ng-template>
  <ng-template pTemplate="body" let-item>
    <tr>
      <td>{{ item.name }}</td>
      <td><button>Editar</button></td>
    </tr>
  </ng-template>
</p-table>
```

#### Ahora (Tailwind)
```html
<table class="table">
  <thead>
    <tr>
      <th>Nombre</th>
      <th>Acciones</th>
    </tr>
  </thead>
  <tbody>
    <tr *ngFor="let item of items">
      <td>{{ item.name }}</td>
      <td>
        <app-button label="Editar" size="sm"></app-button>
      </td>
    </tr>
  </tbody>
</table>
```

---

### Listbox

#### Antes (PrimeNG)
```html
<p-listbox 
  [options]="playlists"
  [(ngModel)]="selectedPlaylist"
  optionLabel="name"
></p-listbox>
```

#### Ahora (Tailwind)
```html
<div class="space-y-2">
  <div 
    *ngFor="let playlist of playlists"
    [class.bg-info/20]="playlist === selectedPlaylist"
    class="p-3 rounded-lg cursor-pointer hover:bg-white/5"
    (click)="selectedPlaylist = playlist"
  >
    {{ playlist.name }}
  </div>
</div>
```

---

### Tags/Badges

#### Antes (PrimeNG)
```html
<p-tag 
  value="MP3"
  severity="primary"
></p-tag>
```

#### Ahora (Tailwind)
```html
<span class="badge badge-primary">
  <i class="fas fa-file-audio mr-1"></i>
  MP3
</span>
```

---

### Chips

#### Antes (PrimeNG)
```html
<p-chip label="Entrenado" icon="pi pi-check"></p-chip>
```

#### Ahora (Tailwind)
```html
<span class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-success/20 text-success">
  <i class="fas fa-check"></i>
  Entrenado
</span>
```

---

## 🎨 Clases CSS Equivalentes

### Layout

| PrimeNG | Tailwind |
|---------|----------|
| `.p-grid` | `.grid` o `.flex` |
| `.p-col-6` | `.w-1/2` o `.col-6` |
| `.p-d-flex` | `.flex` |
| `.p-jc-center` | `.justify-center` |
| `.p-ai-center` | `.items-center` |

### Spacing

| PrimeNG | Tailwind |
|---------|----------|
| `.p-mt-3` | `.mt-3` |
| `.p-mb-3` | `.mb-3` |
| `.p-p-3` | `.p-3` |
| `.p-px-3` | `.px-3` |
| `.p-py-3` | `.py-3` |

### Typography

| PrimeNG | Tailwind |
|---------|----------|
| `.p-text-bold` | `.font-bold` |
| `.p-text-center` | `.text-center` |
| `.p-text-lg` | `.text-lg` |

---

## 🔧 Migración de Imports

### Antes
```typescript
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { DialogModule } from 'primeng/dialog';
import { TableModule } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ListboxModule } from 'primeng/listbox';
import { TagModule } from 'primeng/tag';
import { ChipModule } from 'primeng/chip';
import { TooltipModule } from 'primeng/tooltip';

@Component({
  imports: [
    ButtonModule,
    FileUploadModule,
    DialogModule,
    TableModule,
    InputTextModule,
    ListboxModule,
    TagModule,
    ChipModule,
    TooltipModule
  ]
})
```

### Ahora
```typescript
import { ButtonComponent } from '../../_components/button.component';
import { InputComponent } from '../../_components/input.component';
import { ModalComponent } from '../../_components/modal.component';
import { RatingComponent } from '../../_components/rating.component';
import { FileUploadComponent } from '../../_components/file-upload.component';

@Component({
  imports: [
    CommonModule,
    FormsModule,
    ButtonComponent,
    InputComponent,
    ModalComponent,
    RatingComponent,
    FileUploadComponent
  ]
})
```

---

## 📝 Ejemplo Completo de Migración

### Componente Antiguo (PrimeNG)

```typescript
// training.component.ts
import { Component } from '@angular/core';
import { ButtonModule } from 'primeng/button';
import { FileUploadModule } from 'primeng/fileupload';
import { TableModule } from 'primeng/table';
import { DialogModule } from 'primeng/dialog';

@Component({
  selector: 'app-training',
  standalone: true,
  imports: [
    CommonModule,
    ButtonModule,
    FileUploadModule,
    TableModule,
    DialogModule
  ],
  template: `
    <div class="p-grid">
      <div class="p-col-12">
        <h1>Training</h1>
        
        <p-button 
          label="Upload"
          icon="pi pi-upload"
          (onClick)="showUploadDialog = true"
        ></p-button>

        <p-dialog 
          [(visible)]="showUploadDialog"
          header="Upload Files"
        >
          <p-fileUpload 
            (onSelect)="onUpload($event)"
            [multiple]="true"
          ></p-fileUpload>
        </p-dialog>

        <p-table [value]="songs">
          <ng-template pTemplate="header">
            <tr>
              <th>Name</th>
              <th>Rating</th>
            </tr>
          </ng-template>
          <ng-template pTemplate="body" let-song>
            <tr>
              <td>{{ song.name }}</td>
              <td>{{ song.rating }}</td>
            </tr>
          </ng-template>
        </p-table>
      </div>
    </div>
  `
})
export class TrainingComponent {
  showUploadDialog = false;
  songs = [];

  onUpload(event: any) {
    // Logic
  }
}
```

### Componente Nuevo (Tailwind)

```typescript
// library.component.ts
import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonComponent } from '../../_components/button.component';
import { ModalComponent } from '../../_components/modal.component';
import { FileUploadComponent } from '../../_components/file-upload.component';

@Component({
  selector: 'app-library',
  standalone: true,
  imports: [
    CommonModule,
    ButtonComponent,
    ModalComponent,
    FileUploadComponent
  ],
  template: `
    <div class="container mx-auto px-4">
      <div class="mb-6">
        <h1 class="text-3xl font-bold mb-4">Library</h1>
        
        <app-button
          label="Upload"
          icon="fas fa-upload"
          variant="primary"
          (clicked)="showUploadDialog = true"
        ></app-button>

        <app-modal
          [(visible)]="showUploadDialog"
          title="Upload Files"
        >
          <app-file-upload
            [multiple]="true"
            (uploadFiles)="onUpload($event)"
          ></app-file-upload>
        </app-modal>

        <table class="table mt-6">
          <thead>
            <tr>
              <th>Name</th>
              <th>Rating</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let song of songs">
              <td>{{ song.name }}</td>
              <td>{{ song.rating }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  `
})
export class LibraryComponent {
  showUploadDialog = false;
  songs = [];

  onUpload(files: File[]) {
    // Logic
  }
}
```

---

## 🎯 Pasos de Migración

### 1. Actualizar package.json
```bash
# Remover PrimeNG
npm uninstall primeng primeicons

# Instalar Tailwind
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init
```

### 2. Configurar Tailwind

**tailwind.config.js:**
```javascript
module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {
      colors: {
        primary: '#0032c8',
        success: '#00b400',
        warning: '#fadc00',
        danger: '#fa6400',
        info: '#46f0be',
      }
    }
  }
}
```

**styles.scss:**
```scss
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### 3. Crear Componentes Personalizados

Copia los componentes de `src/app/_components/` del proyecto actualizado.

### 4. Migrar Componentes uno por uno

1. Identifica componentes de PrimeNG en uso
2. Reemplaza con equivalentes de Tailwind o custom components
3. Actualiza imports
4. Ajusta estilos
5. Prueba funcionalidad

### 5. Actualizar Imports Globales

Remueve todas las importaciones de PrimeNG:
```typescript
// ❌ Remover
import { ButtonModule } from 'primeng/button';

// ✅ Agregar
import { ButtonComponent } from '../../_components/button.component';
```

---

## ✅ Checklist de Migración

- [ ] package.json actualizado (PrimeNG removido, Tailwind instalado)
- [ ] tailwind.config.js creado
- [ ] styles.scss actualizado con Tailwind directives
- [ ] Componentes custom creados en _components/
- [ ] Todas las importaciones de PrimeNG reemplazadas
- [ ] Todos los componentes PrimeNG reemplazados
- [ ] Estilos actualizados a clases de Tailwind
- [ ] Funcionalidad probada
- [ ] Build exitoso sin errores
- [ ] Tests actualizados (si existen)

---

## 🐛 Problemas Comunes

### 1. Tailwind no aplica estilos

**Solución:**
```bash
# Verificar que el build esté corriendo
npm run serve

# Limpiar caché
rm -rf .angular/cache
ng serve
```

### 2. Componentes custom no se encuentran

**Solución:**
```typescript
// Verificar que el path sea correcto
import { ButtonComponent } from '../../_components/button.component';

// Y que esté en imports
@Component({
  imports: [ButtonComponent]
})
```

### 3. Estilos antiguos de PrimeNG persisten

**Solución:**
```scss
// En styles.scss, remover:
// @import "primeng/resources/themes/...";
// @import "primeng/resources/primeng.css";
```

---

## 📚 Recursos Adicionales

- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Angular Standalone Components](https://angular.io/guide/standalone-components)
- [FontAwesome Icons](https://fontawesome.com/icons)

---

¿Dudas? Consulta [DEVELOPMENT.md](DEVELOPMENT.md) o abre un issue.

**¡Buena suerte con la migración!** 🚀
