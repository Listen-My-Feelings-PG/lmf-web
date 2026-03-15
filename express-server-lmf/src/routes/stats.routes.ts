import { Router } from 'express';
import { getAllSongsCalibrationsByIdPlaylist } from '../controllers/stats.controller';

const router: Router = Router();
router.get('/songs-in-playlist/:idPlaylist', getAllSongsCalibrationsByIdPlaylist);

export default router;