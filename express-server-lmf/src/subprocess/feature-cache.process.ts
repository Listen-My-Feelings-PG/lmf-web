// ─── Caché de features en memoria ────────────────────────────────────────────
// Evita releer .npy de disco en cada fine-tune.
// Clave: songId, valor: Float32Array normalizado (128-dim).

import path from 'path';
import { readNpy, fileExists } from '../services/filesystem.service';

/** 
 * Mapa en memoria que guarda las características (features) extraídas de las canciones.
 * Actúa como caché rápida. La clave es el ID de la canción y el valor es el array de floats normalizado.
 */
const featureCache = new Map<number, Float32Array>();

/**
 * Obtiene el feature vector normalizado de una canción.
 * Si ya está en la memoria caché, lo retorna instantáneamente sin tocar el disco.
 * Si no está en caché, lee el archivo `.npy`, procesa los embeddings y guarda el resultado en caché.
 * @param songId ID numérico de la canción.
 * @param featuresFileName Nombre del archivo `.npy` generado previamente.
 * @param featuresDir Directorio absoluto donde se guardan los archivos de características.
 * @returns Un arreglo flotante de 1D o null si no se encontró.
 */
export function getCachedFeature(songId: number, featuresFileName: string, featuresDir: string): Float32Array | null {
  const cached = featureCache.get(songId);
  if (cached) return cached;

  const featurePath = path.join(featuresDir, featuresFileName);
  if (!fileExists(featurePath)) return null;

  try {
    const npy = readNpy(featurePath);
    const pooled = poolEmbeddings(npy.data, npy.shape);
    const normalized = normalizeEmbedding(pooled);
    featureCache.set(songId, normalized);
    return normalized;
  } catch {
    return null;
  }
}

/**
 * Invalida (borra) la entrada de caché para una canción específica o limpia toda la caché.
 * Esto es vital llamarlo si el archivo original cambia (ej. re-extracción de features).
 * @param songId ID de la canción a borrar de caché. Si es undefined, vacía el mapa completo.
 */
export function invalidateFeatureCache(songId?: number): void {
  if (songId !== undefined) featureCache.delete(songId);
  else featureCache.clear();
}

// ─── Helpers de features ─────────────────────────────────────────────────────
/**
 * Mean & Std-pool de embeddings VGGish: (N, 128) → (256,)
 * Captura el promedio (característica general) y la desviación estándar (dinamismo).
 */
/**
 * Realiza un Pooling (promedio y desviación estándar) a lo largo del eje del tiempo de los embeddings de VGGish.
 * VGGish genera dimensiones `(N, 128)` donde N son los frames por segundo del audio. 
 * Esta función los comprime a un vector estático de `(256,)` para poder ingresarlo a una red neuronal clásica (Dense).
 * 
 * @param data Array plano que contiene los embeddings leídos del `.npy`.
 * @param shape Forma original de la matriz `[numFrames, embDim]`.
 * @returns Array flotante estático de longitud `embDim * 2`.
 */
export function poolEmbeddings(data: Float32Array, shape: number[]): Float32Array {
  const [numFrames, embDim] = shape;
  
  // El resultado medirá el doble de la dimensión base (128*2 = 256)
  const result = new Float32Array(embDim * 2);

  // Bucle externo: Itera sobre cada uno de los "canales" (128 características numéricas).
  for (let j = 0; j < embDim; j++) {
    
    // -- 1. Calcular el Promedio (Mean Pooling) para este canal a través de todos los frames del audio --
    let sum = 0;
    // Bucle interno 1: Recorre cada fragmento de tiempo (frame) de la canción.
    for (let i = 0; i < numFrames; i++) {
      // data se almacena de forma contigua, así que i * embDim salta al frame correcto, y j agarra la característica.
      sum += data[i * embDim + j];
    }
    const mean = sum / numFrames;
    result[j] = mean; // Primera mitad del resultado: Guarda el Promedio (captura el tono general del track a través del tiempo).

    // -- 2. Calcular la Desviación Estándar (Std Pooling) para este canal --
    let varianceSum = 0;
    // Segundo Bucle interno: Recorre de nuevo para medir qué tanto varía esta característica con respecto al promedio.
    for (let i = 0; i < numFrames; i++) {
      const diff = data[i * embDim + j] - mean;
      varianceSum += diff * diff;
    }
    const std = Math.sqrt(varianceSum / numFrames);
    result[embDim + j] = std; // Segunda mitad del resultado: Guarda la Desviación estándar (captura la energía y variación acústica).
  }

  return result;
}

/**
 * Normaliza los datos comprimidos de los embeddings (0-255) escalándolos entre 0 y 1.
 * Las redes neuronales (TensorFlow) entrenan mejor y convergen más rápido cuando los rangos de entrada 
 * se encuentran dentro del espectro `[0.0, 1.0]`.
 * 
 * @param data Array 1D con los datos estáticos de pooling calculados previamente.
 * @returns Nuevo arreglo con todos sus valores divididos de forma lineal.
 */
export function normalizeEmbedding(data: Float32Array): Float32Array {
  const normalized = new Float32Array(data.length);
  // Iteración lineal estándar sobre todos los números del array.
  for (let i = 0; i < data.length; i++) {
    normalized[i] = data[i] / 255.0;
  }
  return normalized;
}
