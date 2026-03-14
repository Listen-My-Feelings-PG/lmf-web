import { Application } from 'express';
import { Sql } from 'postgres';

/**
 * Configuración de la aplicación
 */
export interface AppConfig {
  app: Application;
  psql: Sql;
  paths: AppPaths;
}

/**
 * Rutas de archivos de la aplicación
 */
export interface AppPaths {
  audio: string;
  features: string;
  models: string;
}

/**
 * Respuesta estándar de la API
 */
export interface ApiResponse<T = any> {
  success: boolean;
  message?: string;
  data?: T;
  error?: boolean;
  details?: string;
}

/**
 * Información de archivo
 */
export interface FileInfo {
  path: string;
  size: number;
  name: string;
  extension: string;
}

/**
 * Log level types
 */
export type LogLevel = 'info' | 'error' | 'warn' | 'debug';

export type UserScore = 0 | 1 | 2 | 3 | null;
