-- ============================================================
-- SCRIPT PARA CORREGIR FOREIGN KEY DE rel_playlists_canciones
-- ============================================================
--
-- Este script corrige la FK link_canciones_rel_playlists_canciones
-- para agregar ON DELETE CASCADE
--
-- EJECUTAR ESTE SCRIPT en tu base de datos existente si ya está creada
-- Si vas a crear la BD desde cero, usa lmf_db.sql que ya tiene la corrección
-- ============================================================

-- Eliminar constraint existente (sin ON DELETE CASCADE)
ALTER TABLE public.rel_playlists_canciones
DROP CONSTRAINT IF EXISTS link_canciones_rel_playlists_canciones;

-- Recrear constraint con ON DELETE CASCADE
ALTER TABLE public.rel_playlists_canciones
ADD CONSTRAINT link_canciones_rel_playlists_canciones FOREIGN KEY (pr_ca_id) REFERENCES public.canciones (ca_id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;

-- Verificar que se aplicó correctamente
SELECT tc.constraint_name, rc.update_rule AS on_update, rc.delete_rule AS on_delete
FROM information_schema.table_constraints AS tc
    JOIN information_schema.referential_constraints AS rc ON tc.constraint_name = rc.constraint_name
    AND tc.table_schema = rc.constraint_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name = 'rel_playlists_canciones'
    AND tc.constraint_name = 'link_canciones_rel_playlists_canciones';

-- Debe mostrar: update_rule = CASCADE, delete_rule = CASCADE