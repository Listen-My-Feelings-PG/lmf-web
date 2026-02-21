import { Router } from 'express';
import * as authController from '../controllers/auth.controller';

const router = Router();

router.post('/login', authController.login);
// router.get('/refresh-token', authController.refreshToken);
// router.get('/logout', authController.logout);

export default router;
