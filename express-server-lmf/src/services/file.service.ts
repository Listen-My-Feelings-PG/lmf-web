import { Response } from 'express';



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
 * Error response helper
 */
export function sendError(
  res: Response,
  message: string,
  statusCode = 500,
  error: Error | null = null
): void {
  console.error('Error:', error);
  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? error?.message : undefined,
    timestamp: new Date().toISOString()
  });
}
