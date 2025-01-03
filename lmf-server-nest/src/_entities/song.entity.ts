import { Entity, Column, PrimaryGeneratedColumn } from 'typeorm';

@Entity('canciones')
export class SongEntity {
  @PrimaryGeneratedColumn({ name: 'ce_id' })
  id: number;

  @Column({ name: 'ce_nombre', type: 'text' })
  name: string;

  @Column({ name: 'ce_trainstatus', default: 0, type: 'int' })
  trainstatus: number;

  @Column({ name: 'ce_tsfeatures', type: 'text' })
  tsFeatures: string;

  @Column({ name: 'ce_calificacion', default: 0, type: 'int' })
  score: number;

}