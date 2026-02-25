import { Router } from 'express';
import { rateSongById, serveSongById, getAllSongsScoredByUser } from '../controllers/song.controller';

const router: Router = Router();

router.get('/song-by-id/:idSong', serveSongById);
router.post('/rate/:idSong', rateSongById);
router.get('/scored-by-user', getAllSongsScoredByUser);

export default router;