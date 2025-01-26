import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { CalibrationEntity } from './calibration.entity';
import { PlaylistEntity } from './playlist.entity';

@Entity('modelos')
export class ModelEntity {
	@PrimaryGeneratedColumn({ name: 'mo_id' })
	id: number;

	@Column({ name: 'mo_filename', type: 'text' })
	fileName: string;

	@Column({ name: 'mo_descripcion', type: 'text', nullable: true })
	description: string;

	@Column({ name: 'mo_fecha_creacion', type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
	creationDate: string;

	@Column({ name: 'mo_train_count', type: 'int' })
	trainCount: string;

	@Column({ name: 'mo_global', type: 'boolean' })
	isGlobal: string;

	@OneToMany(() => CalibrationEntity, calibration => calibration.idModel)
	calibrations: CalibrationEntity[];

	@OneToMany(() => PlaylistEntity, playlist => playlist.idModel)
	playlists: PlaylistEntity[];

}