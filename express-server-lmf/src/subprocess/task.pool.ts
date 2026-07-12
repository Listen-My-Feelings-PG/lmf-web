// ─── Pool de Tareas ──────────────────────────────────────────────
// Reemplaza los bloqueos estáticos y permite conocer el estado de cada proceso

import { emitTaskExec, emitTaskFinish } from '../services/socket.service';
import { TaskScope, TaskStatus, TaskType } from '../types/generals.types';

/**
 * Interfaz que define la estructura de una tarea asíncrona dentro del pool de tareas.
 */
export interface Task {
  id?: string;
  type: TaskType;
  scope: TaskScope;
  songIds: Array<number>;
  status?: TaskStatus;
  timestamp?: Date;
  /** Función asíncrona que contiene la lógica a ejecutar. */
  execute: (songIds: number[]) => Promise<void>;
}

/** Cola de tareas pendientes por procesar. Actúa como un búfer FIFO. */
const queue: Task[] = [];
/** Mapa de tareas actualmente en ejecución. La clave es el ID de la tarea. */
const activeTasks = new Map<string, Task>();
/** Bandera (Flag) que indica si el worker (bucle processQueue) está actualmente procesando tareas. */
let isProcessing = false;

/**
 * Genera un ID único para la tarea basándose en su tipo y opcionalmente en el ID de la canción.
 * @param type Tipo de tarea (ej. 'training', 'prediction').
 * @param songId ID de la canción si el contexto de la tarea es 'single'.
 * @returns Cadena con el ID de la tarea.
 */
export function generateTaskId(type: string, songId?: number): string {
  return songId ? `${type}-${songId}` : type;
}

/**
 * Agrega una nueva tarea a la cola y activa el proceso de ejecución si está detenido.
 * @param task Objeto con la información y la función a ejecutar (omitiendo metadatos autogenerados).
 * @returns El ID generado para la nueva tarea.
 */
export function addTask(task: Omit<Task, 'id' | 'status' | 'timestamp'>): string {
  // Genera un ID, agregando el ID de la canción si el alcance (scope) es de una sola canción.
  const id = generateTaskId(task.type, task.scope === 'single' ? task.songIds[0] : undefined);

  const newTask: Task = {
    ...task,
    id,
    status: 'queued',
    timestamp: new Date()
  };

  // Encola la tarea en el búfer FIFO.
  queue.push(newTask);
  // Invoca el procesador. Si ya está corriendo, esta llamada no hace nada (se controla mediante isProcessing).
  processQueue(); 

  return id;
}

/**
 * Verifica si existe una tarea (ya sea en cola o en ejecución) de un tipo específico, 
 * o para una canción específica si se proporciona el ID.
 * @param type El tipo de tarea a buscar (ej. 'prediction').
 * @param songId (Opcional) ID de la canción para verificar si esa canción exacta está siendo procesada.
 * @returns `true` si hay una tarea coincidente, `false` de lo contrario.
 */
export function isTaskActive(type: Task['type'], songId?: number): boolean {
  if (songId) {
    // Si hay songId, comprobamos directamente por el ID generado en el mapa activo y en la cola.
    return activeTasks.has(generateTaskId(type, songId)) || queue.some(t => t.id === generateTaskId(type, songId));
  }
  // Bucle for: Itera sobre todas las tareas activas para verificar si alguna coincide con el tipo solicitado.
  for (const task of activeTasks.values()) {
    if (task.type === type) return true;
  }
  // Bucle for: Itera sobre la cola de pendientes por el mismo motivo.
  for (const task of queue) {
    if (task.type === type) return true;
  }
  return false;
}

/**
 * Obtiene una lista de todas las tareas actualmente en ejecución.
 * @returns Array de tareas.
 */
export function getActiveTasks(): Task[] {
  return Array.from(activeTasks.values());
}

/**
 * Elimina forzosamente una tarea del registro de tareas activas.
 * @param taskId ID de la tarea a eliminar.
 */
export function removeTask(taskId: string): void {
  activeTasks.delete(taskId);
}

/**
 * Procesa la cola de tareas secuencialmente. 
 * Esta función actúa como el "worker" del pool. Extrae tareas de la cola una por una y las ejecuta de forma bloqueante para el worker.
 */
async function processQueue() {
  // Condición de salida temprana: si ya hay un bucle trabajando o no hay tareas, no hace nada.
  if (isProcessing || queue.length === 0) return;
  
  // Activa la bandera global indicando que el worker está en funcionamiento.
  isProcessing = true;

  // Bucle while: Se mantendrá iterando y procesando mientras haya tareas pendientes en la cola (`queue`).
  // Esto permite que si se agregan tareas durante la ejecución actual, sean procesadas sin tener que lanzar otro worker concurrente.
  while (queue.length > 0) {
    // shift() remueve el primer elemento del array FIFO y lo retorna.
    const currentTask: Task = queue.shift()!;
    currentTask.status = 'processing';
    
    // Añade la tarea al mapa de tareas en ejecución para que otras funciones puedan saber que está corriendo.
    activeTasks.set(currentTask.id!, currentTask);

    // Variable clave `songIdContext`: Define el contexto visual para la UI (Front-end). 
    // Si la tarea es de una sola canción ('single'), emitimos los sockets con ese ID. Si es masiva ('multiple'), enviamos `undefined`.
    const songIdContext: number | undefined = currentTask.scope === 'single' ? currentTask.songIds[0] : undefined;

    // Notificar al cliente vía WebSocket que la tarea comenzó.
    emitTaskExec({
      type: currentTask.type,
      songId: songIdContext,
      message: `Iniciando tarea: ${currentTask.type}`
    });

    try {
      // Ejecución de la lógica inyectada en la interfaz Task. 'await' asegura que la siguiente tarea en la cola no empiece hasta que esta termine o falle.
      await currentTask.execute(currentTask.songIds);
    } catch (err) {
      console.error(`[TaskPool] Error en tarea ${currentTask.type}:`, err);
    } finally {
      // Finally asegura quitar la tarea del mapa activo sin importar si tuvo éxito o lanzó una excepción.
      activeTasks.delete(currentTask.id!);
      
      // Notificar al cliente vía WebSocket que la tarea finalizó.
      emitTaskFinish({
        type: currentTask.type,
        songId: songIdContext,
        message: `Tarea finalizada: ${currentTask.type}`
      });
    }
  }

  // Al vaciarse la cola, se desactiva la bandera de worker. Si entran nuevas tareas después de esto, un nuevo processQueue() se activará.
  isProcessing = false;
}
