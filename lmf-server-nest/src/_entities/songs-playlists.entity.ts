import { Entity, PrimaryGeneratedColumn, ManyToOne, JoinColumn } from 'typeorm';
import { SongEntity } from './song.entity';
import { PlaylistEntity } from './playlist.entity';

@Entity('canciones_playlists')
export class SongsPlaylistsEntity {
    @PrimaryGeneratedColumn({ name: 'cp_id' })
    id: number;

    @ManyToOne(() => SongEntity, song => song.songsPlaylists)
    @JoinColumn({ name: 'cp_ca_id' })
    idSong: SongEntity;

    @ManyToOne(() => PlaylistEntity, playlist => playlist.songsPlaylists)
    @JoinColumn({ name: 'cp_pl_id' })
    idPlaylist: PlaylistEntity;
}