import { Router } from 'express';
import { DOTFILES_DIR, STOW_DIR, HOME_DIR, PACKAGES, BACKUP_BASE } from '../config';
import type { InfoResponse } from '../../shared/types';

const router = Router();

router.get('/', (_req, res) => {
  res.json({
    dotfilesDir: DOTFILES_DIR,
    stowDir:     STOW_DIR,
    homeDir:     HOME_DIR,
    packages:    [...PACKAGES],
    backupBase:  BACKUP_BASE,
  } satisfies InfoResponse);
});

export default router;
