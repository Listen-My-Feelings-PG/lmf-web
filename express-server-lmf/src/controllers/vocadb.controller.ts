import { Request, Response } from 'express';
import { BadRequest, InternalServerError, Locked, sendError } from '../services/http-response-handler.service';
import { extractVocadbYoutubeLinks } from '../services/vocadb.service';
import { isTaskActive, addTask, removeTask } from '../subprocess/task.pool';
import { emitTaskExec, emitTaskFinish } from '../services/socket.service';

const DEFAULT_RANGE_DAYS = 3;
const MAX_RANGE_DAYS = 31;

function parseInteger(value: unknown): number | null {
  if (typeof value === 'number' && Number.isInteger(value))
    return value;

  if (typeof value === 'string' && value.trim() !== '') {
    const parsed = Number(value);
    return Number.isInteger(parsed) ? parsed : null;
  }

  return null;
}

export async function createVocadbYoutubeLinksReport(req: Request, res: Response): Promise<void> {
  const year = parseInteger(req.body.year);
  const rangeDays = req.body.rangeDays === undefined || req.body.rangeDays === null || req.body.rangeDays === ''
    ? DEFAULT_RANGE_DAYS
    : parseInteger(req.body.rangeDays);

  if (year === null || year < 1900 || year > 2100) {
    sendError(res, 'El año de extracción debe ser un entero entre 1900 y 2100.', BadRequest, null);
    return;
  }

  if (rangeDays === null || rangeDays < 1 || rangeDays > MAX_RANGE_DAYS) {
    sendError(res, `El salto de días debe ser un entero entre 1 y ${MAX_RANGE_DAYS}.`, BadRequest, null);
    return;
  }

  if (isTaskActive('vocadb-youtube-report')) {
    sendError(res, 'Hay un proceso de extracción de links VocaDB activo. Intente más tarde.', Locked, null);
    return;
  }

  const taskId = addTask('vocadb-youtube-report');
  emitTaskExec({ type: 'vocadb-youtube-report', message: 'Iniciando reporte VocaDB' });
  try {
    const result = await extractVocadbYoutubeLinks(year, rangeDays);

    res.status(200).json({
      success: true,
      data: result,
      message: `Reporte VocaDB creado: ${result.report.fileName}`,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    sendError(
      res,
      'Error al extraer links de YouTube desde VocaDB',
      InternalServerError,
      error instanceof Error ? error : null
    );
  } finally {
    removeTask(taskId);
    emitTaskFinish({ type: 'vocadb-youtube-report', message: 'Reporte VocaDB completado' });
  }
}
