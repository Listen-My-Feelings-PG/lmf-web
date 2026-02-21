import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonComponent } from '../../_components/button.component';
import { InputComponent } from '../../_components/input.component';
import { ModalComponent } from '../../_components/modal.component';
import { RatingComponent } from '../../_components/rating.component';
import { FileUploadComponent } from '../../_components/file-upload.component';
import { SongService } from '../../_services/song.service';
import { PlayerService } from '../../_services/player.service';
import { HttpService } from '../../_services/http.service';
import { TensorflowService } from '../../_services/tensorflow-v2.service';
import { Playlist, Song } from '../../_models/all.model';

@Component({
  selector: 'app-library',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ButtonComponent,
    InputComponent,
    ModalComponent,
    RatingComponent,
    FileUploadComponent
  ],
  templateUrl: './library.component.html',
  styleUrl: './library.component.scss'
})
export class LibraryComponent implements OnInit {
  // Playlists
  playlists: Playlist[] = [];
  selectedPlaylist: Playlist | null = null;
  globalPlaylist: Playlist | null = null;

  // Songs
  songs: Song[] = [];
  filteredSongs: Song[] = [];
  selectedSong: Song | null = null;
  playingSongId: number = 0;

  // UI State
  searchQuery = '';
  viewMode: 'grid' | 'list' = 'list';
  filterStatus: 'all' | 'train' | 'predict' | 'trained' = 'all';

  // Modals
  playlistModal = {
    visible: false,
    name: '',
    mode: 'new' as 'new' | 'edit',
    playlistId: null as number | null
  };

  uploadModal = {
    visible: false,
    type: 'train' as 'train' | 'predict'
  };

  // Loading states
  loading = {
    playlists: false,
    songs: false,
    upload: false,
    features: false,
    training: false
  };

  constructor(
    public songService: SongService,
    private playerService: PlayerService,
    private http: HttpService,
    private tsService: TensorflowService
  ) { }

  async ngOnInit() {
    await this.loadPlaylists();
    this.playerService.getPlayerEmmitterIdSong().subscribe(
      id => this.playingSongId = id
    );
  }

  async loadPlaylists() {
    this.loading.playlists = true;
    try {
      const res = await this.http.post('playlists/get-all', { all: true }, true).toPromise();
      if (res?.data?.list) {
        this.playlists = res.data.list.map((p: any) =>
          new Playlist(p.name, [], [], null, p.is_global, p.id)
        );
        this.globalPlaylist = this.playlists.find(p => p.isGlobal) || null;

        if (this.globalPlaylist) {
          await this.loadPlaylist(this.globalPlaylist.id!);
        }
      }
    } catch (error) {
      console.error('Error loading playlists:', error);
    } finally {
      this.loading.playlists = false;
    }
  }

  async loadPlaylist(playlistId: number) {
    this.loading.songs = true;
    try {
      const res = await this.http.get(`songs/playlist/${playlistId}`).toPromise();
      if (res?.data) {
        this.songs = res.data.map((s: any) => new Song(s));
        this.filteredSongs = [...this.songs];
        this.selectedPlaylist = this.playlists.find(p => p.id === playlistId) || null;
        this.applyFilters();
      }
    } catch (error) {
      console.error('Error loading songs:', error);
    } finally {
      this.loading.songs = false;
    }
  }

  applyFilters() {
    let filtered = [...this.songs];

    // Filter by search query
    if (this.searchQuery.trim()) {
      const query = this.searchQuery.toLowerCase();
      filtered = filtered.filter(s =>
        s.name.toLowerCase().includes(query)
      );
    }

    // Filter by status
    if (this.filterStatus !== 'all') {
      filtered = filtered.filter(s => s.tsInitStatus === this.filterStatus);
    }

    this.filteredSongs = filtered;
  }

  onSearch(query: string) {
    this.searchQuery = query;
    this.applyFilters();
  }

  onFilterChange(status: 'all' | 'train' | 'predict' | 'trained') {
    this.filterStatus = status;
    this.applyFilters();
  }

  // Playlist actions
  showCreatePlaylistModal() {
    this.playlistModal = {
      visible: true,
      name: '',
      mode: 'new',
      playlistId: null
    };
  }

  showEditPlaylistModal(playlist: Playlist) {
    this.playlistModal = {
      visible: true,
      name: playlist.name,
      mode: 'edit',
      playlistId: playlist.id!
    };
  }

  async savePlaylist() {
    if (!this.playlistModal.name.trim()) return;

    try {
      if (this.playlistModal.mode === 'new') {
        await this.http.post('playlists', { name: this.playlistModal.name }, true).toPromise();
      } else if (this.playlistModal.playlistId) {
        await this.http.put(
          `playlists/${this.playlistModal.playlistId}`,
          { name: this.playlistModal.name },
          true
        ).toPromise();
      }
      await this.loadPlaylists();
      this.playlistModal.visible = false;
    } catch (error) {
      console.error('Error saving playlist:', error);
    }
  }

  async deletePlaylist(playlistId: number) {
    if (confirm('¿Estás seguro de eliminar esta playlist?')) {
      try {
        await this.http.delete(`playlists/${playlistId}`, true).toPromise();
        await this.loadPlaylists();
      } catch (error) {
        console.error('Error deleting playlist:', error);
      }
    }
  }

  // Upload actions
  showUploadModal(type: 'train' | 'predict') {
    this.uploadModal = { visible: true, type };
  }

  async onFilesUpload(files: File[]) {
    if (!this.selectedPlaylist?.id) return;

    this.loading.upload = true;
    try {
      const formData = new FormData();
      files.forEach(file => formData.append('files', file));
      formData.append('playlistId', this.selectedPlaylist.id.toString());
      formData.append('initStatus', this.uploadModal.type);

      // Usar XMLHttpRequest para upload con progreso
      await this.uploadFilesWithProgress(formData);

      this.uploadModal.visible = false;
      await this.loadPlaylist(this.selectedPlaylist.id);
    } catch (error) {
      console.error('Error uploading files:', error);
    } finally {
      this.loading.upload = false;
    }
  }

  private uploadFilesWithProgress(formData: FormData): Promise<void> {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.open('POST', `${this.http.getBaseUrl()}/songs/upload`, true);

      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable) {
          const percentComplete = (event.loaded / event.total) * 100;
          console.log(`Upload progress: ${percentComplete}%`);
        }
      };

      xhr.onload = () => {
        if (xhr.status === 200) {
          resolve();
        } else {
          reject(new Error(`Upload failed: ${xhr.statusText}`));
        }
      };

      xhr.onerror = () => reject(new Error('Upload error'));
      xhr.send(formData);
    });
  }

  // Song actions
  async playSong(song: Song, index: number) {
    this.selectedSong = song;
    this.playerService.loadSong(song, index, this.filteredSongs);
  }

  async updateRating(song: Song, rating: number) {
    try {
      await this.http.put(`songs/${song.id}/rating`, { rating }, true).toPromise();
      song.userRating = rating;
    } catch (error) {
      console.error('Error updating rating:', error);
    }
  }

  async extractFeatures(song: Song) {
    this.loading.features = true;
    try {
      await this.http.post(`songs/${song.id}/extract-features`, {}, true).toPromise();
      await this.loadPlaylist(this.selectedPlaylist!.id!);
    } catch (error) {
      console.error('Error extracting features:', error);
    } finally {
      this.loading.features = false;
    }
  }

  async trainModel() {
    if (!this.selectedPlaylist?.id) return;

    this.loading.training = true;
    try {
      // Obtener canciones para entrenar
      const trainSongs = this.songs.filter(s =>
        s.tsInitStatus === 'train' &&
        s.userRating !== null &&
        s.featuresFile
      );

      if (trainSongs.length === 0) {
        alert('No hay canciones calificadas para entrenar');
        return;
      }

      // Aquí iría la lógica de entrenamiento con TensorFlow
      console.log('Training with', trainSongs.length, 'songs');

    } catch (error) {
      console.error('Error training model:', error);
    } finally {
      this.loading.training = false;
    }
  }

  async deleteSong(song: Song) {
    if (confirm(`¿Eliminar "${song.name}"?`)) {
      try {
        await this.http.delete(`songs/${song.id}`, true).toPromise();
        await this.loadPlaylist(this.selectedPlaylist!.id!);
      } catch (error) {
        console.error('Error deleting song:', error);
      }
    }
  }

  getStatusIcon(song: Song): string {
    if (song.tsStatus === 'trained') return 'fas fa-check-circle text-success';
    if (song.storageStatus === 'uploading') return 'fas fa-spinner fa-spin text-warning';
    if (song.featuresFile) return 'fas fa-wave-square text-info';
    return 'fas fa-music text-white/50';
  }

  getStatusText(song: Song): string {
    if (song.tsStatus === 'trained') return 'Entrenada';
    if (song.storageStatus === 'uploading') return 'Subiendo...';
    if (song.featuresFile) return 'Características extraídas';
    return 'Pendiente';
  }

  getRatedSongsCount(): number {
    return this.songs.filter(s => s.userRating !== null && s.userRating !== undefined).length;
  }
}
