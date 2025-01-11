import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('canciones')
export class SongEntity {
  @PrimaryGeneratedColumn({ name: 'ca_id' })
  id: number;

  @Column({ name: 'ca_nombre', type: 'text' })
  name: string;

  @Column({ name: 'ca_trainlevel', type: 'int', default: 0 })
  trainlevel: number;

  @Column({ name: 'ca_tsfeatures', type: 'text', nullable: true })
  tsFeatures: string;

  @Column({ name: 'ca_calif_usuario', type: 'int', nullable: true })
  userScore: number;

  @Column({ name: 'ca_filesize', type: 'int', nullable: true })
  fileSize: number;

  @Column({ name: 'ca_filename', type: 'text', nullable: true })
  fileName: string;

  @Column({ name: 'ca_calif_ts', type: 'int', nullable: true })
  tsScore: number;

  @Column({ name: 'ca_id_tipo_dato', type: 'int' })
  idDataType: number;

}