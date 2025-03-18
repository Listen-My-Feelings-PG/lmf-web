import { Entity, Column, PrimaryGeneratedColumn, OneToMany, ManyToOne, JoinColumn } from 'typeorm';
import { SongsPlaylistsEntity } from './songs-playlists.entity';
import { ModelEntity } from './model.entity';

@Entity('playlists')
export class PlaylistEntity {
    @PrimaryGeneratedColumn({ name: 'pl_id' })
    id: number;

    @Column({ name: 'pl_nombre', type: 'text', nullable: true })
    name: string;

    @Column({ name: 'pl_activo', type: 'boolean', default: true })
    active: boolean;

    @Column({ name: 'pl_fecha_creacion', type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
    creationDate: string;

    @Column({ name: 'pl_global', type: 'boolean', default: false })
    isGlobal: boolean;

    @ManyToOne(() => ModelEntity)
    @JoinColumn({ name: 'pl_id_modelo' })
    idModel: ModelEntity;

    @OneToMany(() => SongsPlaylistsEntity, songsPlaylist => songsPlaylist.idPlaylist)
    songsPlaylists: SongsPlaylistsEntity[];

}