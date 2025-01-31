import { Entity, Column, PrimaryGeneratedColumn, OneToMany } from 'typeorm';
import { SongEntity } from './song.entity';

@Entity('tipos_datos')
export class DataTypeEntity {
    @PrimaryGeneratedColumn({ name: 'td_id' })
    id: number;

    @Column({ name: 'td_tipo', type: 'text', nullable: true })
    name: 'file' | 'link';

    @Column({ name: 'td_tipo_modelo', type: 'text', nullable: true })
    typeModel: 'tensorflow';

    @Column({ name: 'td_descripcion', type: 'text', nullable: true })
    description: string;

    @Column({ name: 'td_activo', type: 'boolean' })
    active: boolean;

    @OneToMany(() => SongEntity, child => child.idDataType)
    songs: SongEntity[];

}