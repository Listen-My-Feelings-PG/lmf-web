import { Entity, Column, PrimaryGeneratedColumn, OneToMany, ManyToOne } from 'typeorm';
import { SongsPlaylistsEntity } from './songs-playlists.entity';
import { DataTypeEntity } from './data-type.entity';

@Entity('canciones')
export class SongEntity {
  @PrimaryGeneratedColumn({ name: 'ca_id' })
  id: number;

  @Column({ name: 'ca_nombre', type: 'text' })
  name: string;

  @Column({ name: 'ca_train_level_global', type: 'int', default: 0 })
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

  @ManyToOne(() => DataTypeEntity)
  @Column({ name: 'ca_id_tipodato', type: 'int' })
  idDataType: number;

  @Column({ name: 'ca_activo', type: 'boolean', default: true })
  active: boolean;

  @Column({ name: 'ca_ts_status', type: 'int' })
  tsStatus: number;

  @Column({ name: 'ca_ts_init_status', type: 'text' })
  tsInitStatus: number;

  @OneToMany(() => SongsPlaylistsEntity, songsPlaylists => songsPlaylists.song)
  songsPlaylists: SongsPlaylistsEntity[];

}