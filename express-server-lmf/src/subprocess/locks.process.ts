// ─── Locks globales de procesos ──────────────────────────────────────────────
// Controlan el acceso exclusivo a entrenamiento y predicción.

let trainingInProgress = false;
let predictionInProgress = false;

export function isTrainingActive(): boolean {
  return trainingInProgress;
}

export function isPredictionActive(): boolean {
  return predictionInProgress;
}

export function setTrainingLock(active: boolean): void {
  trainingInProgress = active;
}

export function setPredictionLock(active: boolean): void {
  predictionInProgress = active;
}
