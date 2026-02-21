/**
 * Tipos para los modelos de base de datos
 */

/**
 * Interfaz para Canción
 */
export interface Song {
  id: number;
  name: string;
  user_rating?: number;
  file_size: number;
  file_name: string;
  train_level?: number;
  data_type_id?: number;
  active: boolean;
  features_file?: string;
  prediction?: string;
  init_status?: string;
  status?: string;
  id_data_type?: number;
}

/**
 * Interfaz para crear una nueva canción
 */
export interface CreateSongInput {
  name: string;
  file_size: number;
  file_name: string;
  init_status?: string;
  data_type_id?: number;
}

/**
 * Interfaz para Playlist
 */
export interface Playlist {
  id: number;
  nombre: string;
  descripcion?: string;
  tipo?: string;
  activo: boolean;
  created_at?: Date;
  updated_at?: Date;
}

/**
 * Interfaz para crear un nuevo playlist
 */
export interface CreatePlaylistInput {
  nombre: string;
  descripcion?: string;
  tipo?: string;
}

/**
 * Interfaz para Modelo de ML
 */
export interface MLModel {
  id: number;
  nombre: string;
  descripcion?: string;
  archivo: string;
  version?: string;
  activo: boolean;
  created_at?: Date;
  updated_at?: Date;
}

/**
 * Interfaz para crear un nuevo modelo
 */
export interface CreateMLModelInput {
  nombre: string;
  descripcion?: string;
  archivo: string;
  version?: string;
}
