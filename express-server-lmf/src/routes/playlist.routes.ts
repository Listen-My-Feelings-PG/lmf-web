import { Router } from 'express';
import { getAllPlaylists, getPlaylistContentById } from '../controllers/playlist.controller';

const router: Router = Router();

router.get('/all', getAllPlaylists);
router.get('/content/:idPlaylist', getPlaylistContentById);
export default router;