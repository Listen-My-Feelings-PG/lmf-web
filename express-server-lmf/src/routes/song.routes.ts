import { Router } from 'express';
import { rateSongById, serveSongById, getAllSongsScoredByUserInPlaylists, trainSongsByIds, getSongsForPrediction, predictSongsByIds, tuneSingleSong } from '../controllers/song.controller';

const router: Router = Router();

router.get('/song-by-id/:idSong', serveSongById);
router.post('/rate/:idSong', rateSongById);
router.post('/train-songs-by-ids', trainSongsByIds)
router.get('/scored-by-user/:playlistsIds', getAllSongsScoredByUserInPlaylists);
router.get('/songs-for-prediction/:playlistsIds', getSongsForPrediction);
router.post('/predict-songs-by-ids', predictSongsByIds);
router.post('/tune/:idSong', tuneSingleSong);

export default router;