import { Entity, Column, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from 'typeorm';
import { ModelEntity } from './model.entity';

@Entity('calibracion')
export class CalibrationEntity {
    @PrimaryGeneratedColumn({ name: 'cl_id' })
    id: number;

    @Column({ name: 'cl_ca_id', type: 'int' })
    idSong: string;

    @Column({ name: 'cl_calif_usuario', type: 'int', nullable: true })
    userScore: string;

    @Column({ name: 'cl_ts_prediccion', type: 'numeric', nullable: true })
    tsPrediction: string;

    @Column({ name: 'cl_fecha_calibracion', type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
    calibrationDate: string;

    @Column({ name: 'cl_estatus_calibracion', type: 'text', nullable: true })
    calibrationStatus: string;

    @Column({ name: 'cl_activo', type: 'boolean' })
    active: boolean;

    @ManyToOne(() => ModelEntity)
    @JoinColumn({ name: 'cl_id_modelo' })
    idModel: ModelEntity;

}