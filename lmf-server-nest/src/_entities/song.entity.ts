import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('canciones')
export class SongEntity {
  @PrimaryGeneratedColumn({ name: 'ca_id' })
  id: number;

  @Column({ name: 'ca_nombre', type: 'text' })
  name: string;

  @Column({ name: 'ca_train_level', type: 'int', default: 0 })
  trainlevel: number;

  @Column({ name: 'ca_ts_features', type: 'text', nullable: true })
  tsFeatures: string;

  @Column({ name: 'ca_calif_usuario', type: 'int', nullable: true })
  userScore: number;

  @Column({ name: 'ca_file_size', type: 'int', nullable: true })
  fileSize: number;

  @Column({ name: 'ca_file_name', type: 'text', nullable: true })
  fileName: string;

  @Column({ name: 'ca_ts_prediccion', type: 'numeric', nullable: true })
  tsPrediction: number;

  @Column({ name: 'ca_id_tipodato', type: 'int' })
  idDataType: number;

  @Column({ name: 'ca_activo', type: 'boolean', default: true })
  active: boolean;

}