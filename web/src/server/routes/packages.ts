import { Router } from 'express';
import { PACKAGES } from '../config';
import { scanPackage } from '../fs-utils';

const router = Router();

router.get('/', (_req, res) => {
  res.json(PACKAGES.map(scanPackage));
});

export default router;
