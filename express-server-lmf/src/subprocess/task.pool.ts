// ─── Pool de Tareas ──────────────────────────────────────────────
// Reemplaza los bloqueos estáticos y permite conocer el estado de cada proceso

export interface Task {
  type: 'training' | 'prediction' | 'fine-tuning' | 'onboard-copy' | 'library-deletion' | 'vocadb-youtube-report';
  songId?: number;
  status: string;
  timestamp: Date;
}

const taskPool = new Map<string, Task>();

export function generateTaskId(type: string, songId?: number): string {
  return songId ? `${type}-${songId}` : type;
}

export function addTask(type: Task['type'], songId?: number): string {
  const taskId = generateTaskId(type, songId);
  taskPool.set(taskId, {
    type,
    songId,
    status: type,
    timestamp: new Date()
  });
  return taskId;
}

export function removeTask(taskId: string): void {
  taskPool.delete(taskId);
}

export function isTaskActive(type: Task['type'], songId?: number): boolean {
  if (songId) {
    return taskPool.has(generateTaskId(type, songId));
  }
  // Si no se pasa songId, verificar si hay alguna tarea de este tipo activa
  for (const task of taskPool.values()) {
    if (task.type === type) return true;
  }
  return false;
}

export function getActiveTasks(): Task[] {
  return Array.from(taskPool.values());
}
