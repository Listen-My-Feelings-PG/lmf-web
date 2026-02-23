-- Script para verificar y corregir las configuraciones de Foreign Keys
-- en la tabla rel_playlists_canciones

-- ============================================================
-- PASO 1: VERIFICAR LAS CONSTRAINTS ACTUALES
-- ============================================================
SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.update_rule,
    rc.delete_rule
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
    JOIN information_schema.referential_constraints AS rc ON tc.constraint_name = rc.constraint_name
    AND tc.table_schema = rc.constraint_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'rel_playlists_canciones';

-- ============================================================
-- ANÁLISIS DE CONFIGURACIÓN REQUERIDA:
-- ============================================================
--
-- 1. link_canciones_rel_playlists_canciones (pr_ca_id -> canciones.ca_id)
--    Estado actual: ON UPDATE CASCADE, ON DELETE NO ACTION ❌
--    Requerido: ON UPDATE CASCADE, ON DELETE CASCADE ✅
--    Razón: Al eliminar una canción física, debe eliminarse su asociación con playlists
--           PERO NO debe eliminarse la playlist misma
--
-- 2. link_playlists_rel_playlists_canciones (pr_pl_id -> playlists.pl_id)
--    Estado actual: ON UPDATE CASCADE, ON DELETE CASCADE ✅
--    Estado: CORRECTO - Al eliminar una playlist se eliminan sus relaciones
--
-- ============================================================
-- PASO 2: CORREGIR LA FK DE CANCIONES -> REL_PLAYLISTS_CANCIONES
-- ============================================================
-- Este script corrige la FK para que tenga ON DELETE CASCADE

-- Eliminar constraint existente
ALTER TABLE public.rel_playlists_canciones
DROP CONSTRAINT IF EXISTS link_canciones_rel_playlists_canciones;

-- Recrear constraint con ON DELETE CASCADE
ALTER TABLE public.rel_playlists_canciones
ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones (ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;

-- ============================================================
-- RESULTADO ESPERADO:
-- ============================================================
-- Si se elimina una canción de la tabla 'canciones':
--   ✅ Se eliminan automáticamente sus asociaciones en 'rel_playlists_canciones'
--   ✅ Las playlists NO se eliminan
--
-- Si se elimina una playlist de la tabla 'playlists':
--   ✅ Se eliminan automáticamente sus asociaciones en 'rel_playlists_canciones'
--   ✅ Las canciones NO se eliminan
-- ============================================================

-- Verificar que la corrección se aplicó correctamente
SELECT tc.constraint_name, rc.update_rule, rc.delete_rule
FROM information_schema.table_constraints AS tc
    JOIN information_schema.referential_constraints AS rc ON tc.constraint_name = rc.constraint_name
    AND tc.table_schema = rc.constraint_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'rel_playlists_canciones'
    AND tc.constraint_name = 'link_canciones_rel_playlists_canciones';