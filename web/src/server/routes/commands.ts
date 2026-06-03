import { Router } from 'express';
import { getCommandEntries } from '../commands';

const router = Router();

router.get('/', (_req, res) => {
  res.json(getCommandEntries());
});

export default router;
