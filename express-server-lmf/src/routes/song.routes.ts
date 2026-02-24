import { Router } from 'express';
import { rateSongById, serveSongById } from '../controllers/song.controller';

const router: Router = Router();

router.get('/song-by-id/:idSong', serveSongById);
router.post('/rate/:idSong', rateSongById);
export default router;