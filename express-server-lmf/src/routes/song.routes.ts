import { Router } from 'express';
import { serveSongById } from '../controllers/song.controller';

const router: Router = Router();

router.get('/song-by-id/:idSong', serveSongById);

export default router;