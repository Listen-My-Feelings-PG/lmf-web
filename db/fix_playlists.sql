-- Script para agregar columnas faltantes a la tabla playlists

-- Agregar columna pl_fecha_modificacion si no existe
ALTER TABLE public.playlists 
ADD COLUMN IF NOT EXISTS pl_fecha_modificacion timestamp with time zone DEFAULT now();

-- Agregar columna pl_us_id si no existe
ALTER TABLE public.playlists 
ADD COLUMN IF NOT EXISTS pl_us_id integer;

-- Actualizar registros existentes para tener fecha de modificación
UPDATE public.playlists 
SET pl_fecha_modificacion = pl_fecha_creacion 
WHERE pl_fecha_modificacion IS NULL;

-- Verificar la estructura de la tabla
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'playlists'
ORDER BY ordinal_position;
