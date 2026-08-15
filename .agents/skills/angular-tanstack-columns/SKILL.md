---
name: angular-tanstack-columns
description: >-
  Use this skill whenever creating or refactoring Angular components that use TanStack Table.
  It enforces the centralization of column definitions into a separate models file to keep components clean.
---

# Angular TanStack Columns Pattern

This skill enforces a specific architectural pattern for Angular applications using `@tanstack/angular-table`.

## Rules and Guidelines

1. **Centralize Definitions**: Never define `ColumnDef<T>[]` arrays directly inside the component's `.ts` file. 
2. **Dedicated File**: All column definitions must reside in a dedicated file, typically `src/app/_models/tanstack.columns.definitions.ts` (or an equivalent models/types directory depending on the project structure).
3. **Export Constants**: Export each column definition as a constant. For example:

   ```typescript
   import { ColumnDef } from '@tanstack/angular-table';
   import { MyModel } from './my.models';

   export const MyComponentColumnsDefinition: ColumnDef<MyModel>[] = [
     { accessorKey: 'id', header: 'ID' },
     { accessorKey: 'name', header: 'Name' },
     // ... additional column definitions
   ];
   ```

4. **Import in Component**: In the Angular component, import the constant and assign it to the column configuration property:

   ```typescript
   import { MyComponentColumnsDefinition } from '../_models/tanstack.columns.definitions';

   @Component({
     // ...
   })
   export class MyComponent {
     columns: ColumnDef<MyModel>[] = MyComponentColumnsDefinition;
     
     // Provide it to the table instance...
   }
   ```

5. **Reusability and Cleanliness**: This ensures components remain focused on logic, signals, and state management, rather than being cluttered with bulky column configuration arrays.
