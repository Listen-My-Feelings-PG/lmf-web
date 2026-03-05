-- ============================================================================
-- Migración: Campos adicionales para ts_modelos y calibracion
-- Fecha: 2026-03-03
-- Descripción: Agrega campos de configuración del modelo (propios del modelo)
--              y campos de métricas por interacción en calibracion.
-- ============================================================================

-- ── ts_modelos: Campos de configuración/arquitectura del modelo ──────────────
ALTER TABLE public.ts_modelos
ADD COLUMN IF NOT EXISTS ts_learning_rate numeric(10, 8) DEFAULT 0.001 NOT NULL,
ADD COLUMN IF NOT EXISTS ts_batch_size integer DEFAULT 32 NOT NULL,
ADD COLUMN IF NOT EXISTS ts_num_clases integer DEFAULT 4 NOT NULL,
ADD COLUMN IF NOT EXISTS ts_input_dim integer DEFAULT 128 NOT NULL,
ADD COLUMN IF NOT EXISTS ts_arquitectura text;

COMMENT ON COLUMN public.ts_modelos.ts_learning_rate IS 'Tasa de aprendizaje del optimizador Adam';

COMMENT ON COLUMN public.ts_modelos.ts_batch_size IS 'Tamaño de batch para entrenamiento';

COMMENT ON COLUMN public.ts_modelos.ts_num_clases IS 'Número de clases de salida (4: scores 0-3)';

COMMENT ON COLUMN public.ts_modelos.ts_input_dim IS 'Dimensión de entrada (128 para VGGish embeddings)';

COMMENT ON COLUMN public.ts_modelos.ts_arquitectura IS 'Arquitectura del modelo en formato JSON';

-- ── calibracion: Snapshot de configuración en cada interacción ───────────────
ALTER TABLE public.calibracion
ADD COLUMN IF NOT EXISTS cl_loss numeric(10, 6),
ADD COLUMN IF NOT EXISTS cl_accuracy numeric(6, 4),
ADD COLUMN IF NOT EXISTS cl_learning_rate numeric(10, 8),
ADD COLUMN IF NOT EXISTS cl_batch_size integer;

COMMENT ON COLUMN public.calibracion.cl_loss IS 'Loss del modelo al momento de la interacción';

COMMENT ON COLUMN public.calibracion.cl_accuracy IS 'Accuracy del modelo al momento de la interacción';

COMMENT ON COLUMN public.calibracion.cl_learning_rate IS 'Learning rate usado en la interacción';

COMMENT ON COLUMN public.calibracion.cl_batch_size IS 'Batch size usado en la interacción';