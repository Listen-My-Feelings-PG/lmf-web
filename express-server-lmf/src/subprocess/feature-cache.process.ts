// ─── Caché de features en memoria ────────────────────────────────────────────
// Evita releer .npy de disco en cada fine-tune.
// Clave: songId, valor: Float32Array normalizado (128-dim).

import path from 'path';
import { readNpy, fileExists } from '../services/filesystem.service';

const featureCache = new Map<number, Float32Array>();

/**
 * Obtiene el feature vector normalizado de una canción, usando caché si existe.
 */
export function getCachedFeature(songId: number, featuresFileName: string, featuresDir: string): Float32Array | null {
  const cached = featureCache.get(songId);
  if (cached) return cached;

  const featurePath = path.join(featuresDir, featuresFileName);
  if (!fileExists(featurePath)) return null;

  try {
    const npy = readNpy(featurePath);
    const pooled = meanPoolEmbeddings(npy.data, npy.shape);
    const normalized = normalizeEmbedding(pooled);
    featureCache.set(songId, normalized);
    return normalized;
  } catch {
    return null;
  }
}

/**
 * Invalida la entrada de caché para una canción (si se re-extraen features).
 */
export function invalidateFeatureCache(songId?: number): void {
  if (songId !== undefined) featureCache.delete(songId);
  else featureCache.clear();
}

// ─── Helpers de features ─────────────────────────────────────────────────────
/**
 * Mean-pool de embeddings VGGish: (N, 128) → (128,)
 * Promedia los embeddings a través del tiempo para obtener un vector fijo.
 */
export function meanPoolEmbeddings(data: Float32Array, shape: number[]): Float32Array {
  const [numFrames, embDim] = shape;
  const result = new Float32Array(embDim);

  for (let j = 0; j < embDim; j++) {
    let sum = 0;
    for (let i = 0; i < numFrames; i++) {
      sum += data[i * embDim + j];
    }
    result[j] = sum / numFrames;
  }

  return result;
}

/**
 * Normaliza un embedding VGGish dividiendo entre 255.
 * VGGish produce embeddings cuantizados en rango [0, 255].
 */
export function normalizeEmbedding(data: Float32Array): Float32Array {
  const normalized = new Float32Array(data.length);
  for (let i = 0; i < data.length; i++) {
    normalized[i] = data[i] / 255.0;
  }
  return normalized;
}
