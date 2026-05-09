import { Router } from 'express';
import { createVocadbYoutubeLinksReport } from '../controllers/vocadb.controller';

const router: Router = Router();

router.post('/youtube-links-report', createVocadbYoutubeLinksReport);

export default router;
