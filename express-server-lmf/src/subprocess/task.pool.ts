// ─── Pool de Tareas ──────────────────────────────────────────────
// Reemplaza los bloqueos estáticos y permite conocer el estado de cada proceso

import { emitTaskExec, emitTaskFinish } from '../services/socket.service';

export interface Task {
  id?: string;
  type: 'training' | 'prediction' | 'fine-tuning' | 'onboard-copy' | 'library-deletion' | 'vocadb-youtube-report';
  scope: 'single' | 'global';
  songIds: Array<number>;
  status?: string;
  timestamp?: Date;
  execute: (songIds: number[]) => Promise<void>;
  options?: any;
}

const queue: Task[] = [];
const activeTasks = new Map<string, Task>();
let isProcessing = false;

export function generateTaskId(type: string, songId?: number): string {
  return songId ? `${type}-${songId}` : type;
}

export function addTask(task: Omit<Task, 'id' | 'status' | 'timestamp'>): string {
  const id = generateTaskId(task.type, task.scope === 'single' ? task.songIds[0] : undefined);
  
  const newTask: Task = {
    ...task,
    id,
    status: 'queued',
    timestamp: new Date()
  };

  queue.push(newTask);
  processQueue(); // Iniciar worker si no está corriendo
  
  return id;
}

export function isTaskActive(type: Task['type'], songId?: number): boolean {
  if (songId) {
    return activeTasks.has(generateTaskId(type, songId)) || queue.some(t => t.id === generateTaskId(type, songId));
  }
  for (const task of activeTasks.values()) {
    if (task.type === type) return true;
  }
  for (const task of queue) {
    if (task.type === type) return true;
  }
  return false;
}

export function getActiveTasks(): Task[] {
  return Array.from(activeTasks.values());
}

export function removeTask(taskId: string): void {
  activeTasks.delete(taskId);
}

async function processQueue() {
  if (isProcessing || queue.length === 0) return;
  isProcessing = true;

  while (queue.length > 0) {
    const currentTask = queue.shift()!;
    currentTask.status = 'processing';
    activeTasks.set(currentTask.id!, currentTask);

    const songIdContext = currentTask.scope === 'single' ? currentTask.songIds[0] : undefined;

    // Enviar socket: Iniciando
    emitTaskExec({ 
      type: currentTask.type, 
      songId: songIdContext, 
      message: `Iniciando tarea: ${currentTask.type}` 
    });

    try {
       await currentTask.execute(currentTask.songIds);
    } catch (err) {
       console.error(`[TaskPool] Error en tarea ${currentTask.type}:`, err);
    } finally {
       activeTasks.delete(currentTask.id!);
       // Enviar socket: Finalizado
       emitTaskFinish({ 
         type: currentTask.type, 
         songId: songIdContext, 
         message: `Tarea finalizada: ${currentTask.type}` 
       });
    }
  }

  isProcessing = false;
}
