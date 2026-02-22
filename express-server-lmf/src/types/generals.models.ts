export interface Song {
  id: number;
  fileName: string;
  userScore?: number;
  fileSize: number;
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
