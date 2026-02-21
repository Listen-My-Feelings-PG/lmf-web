import { LogLevel } from '../types';

const DB_QUERY_TIMEOUT = 30000; // 30 segundos

/**
 * Logger personalizado
 */
export function logger(level: LogLevel, msg: string, data?: any): void {
  setImmediate(() => {
    process.nextTick(() => {
      switch (level) {
        case 'info':
          console.info(msg, data || '');
          break;
        case 'error':
          console.error(msg, data || '');
          break;
        case 'warn':
          console.warn(msg, data || '');
          break;
        default:
          console.info(msg, data || '');
      }
    });
  });
}

/**
 * Ejecutar consulta con timeout
 */
export function queryExec<T = any>(
  psql: Promise<T>,
  cb: (data: T | number) => void,
  timeout: number = DB_QUERY_TIMEOUT
): void {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error(`Query timeout after ${timeout}ms`)), timeout);
  });

  Promise.race([psql, timeoutPromise])
    .then((data) => cb(data))
    .catch((error: Error) => {
      if (error.message.includes('timeout')) {
        logger('error', 'Query timeout - posible bloqueo de base de datos', {
          timeout,
          error: error.message
        });
      } else {
        logger('error', 'Error al obtener respuesta de psql', error);
      }
      return cb(500);
    });
}
