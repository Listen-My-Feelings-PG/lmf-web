import { Entity, Column, PrimaryGeneratedColumn, OneToMany, ManyToOne } from 'typeorm';
import { SongsPlaylistsEntity } from './songs-playlists.entity';
import { DataTypeEntity } from './data-type.entity';

@Entity('canciones')
export class SongEntity {
  @PrimaryGeneratedColumn({ name: 'ca_id' })
  id: number;

  @Column({ name: 'ca_nombre', type: 'text' })
  name: string;

  @ManyToOne(() => DataTypeEntity)
  @Column({ name: 'ca_id_tipodato', type: 'int' })
  idDataType: number;

  @Column({ name: 'ca_ts_status', type: 'text', nullable: true })
  tsStatus: string | null;

  @Column({ name: 'ca_ts_init_status', type: 'text' })
  tsInitStatus: string;

  @OneToMany(() => SongsPlaylistsEntity, songsPlaylists => songsPlaylists.idSong)
  songsPlaylists: SongsPlaylistsEntity[];

  @Column({ name: 'ca_activo', type: 'boolean', default: true })
  active: boolean;

  @Column({ name: 'ca_train_level_global', type: 'int', default: 0 })
  trainLevelGlobal: number;

  @Column({ name: 'ca_ts_features', type: 'text', nullable: true })
  tsFeatures: string | null;

  @Column({ name: 'ca_calif_usuario', type: 'int', nullable: true })
  userScore: number | null;

  @Column({ name: 'ca_file_size', type: 'int', nullable: true })
  fileSize: number | null;

  @Column({ name: 'ca_file_name', type: 'text', nullable: true })
  fileName: string | null;

  @Column({ name: 'ca_ts_prediccion', type: 'numeric', nullable: true })
  tsPrediction: number | null;

}