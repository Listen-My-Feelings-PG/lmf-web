// ─── Locks globales de procesos ──────────────────────────────────────────────
// Controlan el acceso exclusivo a entrenamiento y predicción.

let trainingInProgress = false;
let predictionInProgress = false;
let onboardCopyInProgress = false;
let libraryDeletionInProgress = false;
let vocadbYoutubeReportInProgress = false;

export function isTrainingActive(): boolean {
  return trainingInProgress;
}

export function isPredictionActive(): boolean {
  return predictionInProgress;
}

export function isOnboardCopyActive(): boolean {
  return onboardCopyInProgress;
}

export function isLibraryDeletionActive(): boolean {
  return libraryDeletionInProgress;
}

export function isVocadbYoutubeReportActive(): boolean {
  return vocadbYoutubeReportInProgress;
}

export function setTrainingLock(active: boolean): void {
  trainingInProgress = active;
}

export function setPredictionLock(active: boolean): void {
  predictionInProgress = active;
}

export function setOnboardCopyLock(active: boolean): void {
  onboardCopyInProgress = active;
}

export function setLibraryDeletionLock(active: boolean): void {
  libraryDeletionInProgress = active;
}

export function setVocadbYoutubeReportLock(active: boolean): void {
  vocadbYoutubeReportInProgress = active;
}
