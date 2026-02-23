import { Response } from 'express';
import httpErrors from 'http-errors'
export const {
  BadRequest,
  Unauthorized,
  Forbidden,
  NotFound,
  Conflict,
  InternalServerError,
  NotImplemented,
  ServiceUnavailable,
} = httpErrors

export function sendResponse<T = any>(
  res: Response,
  success: boolean,
  data: T | null = null,
  message = '',
  statusCode = 200
): void {
  res.status(statusCode).json({
    success,
    data,
    message,
    timestamp: new Date().toISOString()
  });
}

/**
 * Error response helper usando constructores HTTP
 * @param res - Response object de Express
 * @param message - Mensaje de error personalizado
 * @param HttpErrorConstructor - Constructor de error HTTP (BadRequest, NotFound, InternalServerError, etc.)
 * @param error - Error original (opcional)
 */
export function sendError(
  res: Response,
  message: string,
  HttpErrorConstructor: typeof httpErrors.HttpError,
  error: Error | null = null
): void {
  console.error('Error:', error);

  const httpError = new HttpErrorConstructor(message);

  res.status(httpError.statusCode).json({
    success: false,
    message: httpError.message,
    statusCode: httpError.statusCode,
    error: process.env.NODE_ENV === 'development' ? error?.message : undefined,
    timestamp: new Date().toISOString()
  });
}