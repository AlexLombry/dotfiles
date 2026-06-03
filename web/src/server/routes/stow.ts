import { Router } from 'express';
import { PACKAGES, STOW_DIR } from '../config';
import { STOW_FLAGS, isStowMode } from '../commands';
import { createJob, runProc } from '../jobs';
import type { ApiError, JobIdResponse } from '../../shared/types';

const router = Router();

router.post('/', (req, res) => {
  const body = req.body as Record<string, unknown>;
  const pkgs = Array.isArray(body['packages']) ? (body['packages'] as unknown[]) : [];
  const modeRaw = typeof body['mode'] === 'string' ? body['mode'] : 'stow';

  const valid = pkgs.filter((p): p is string =>
    typeof p === 'string' && (PACKAGES as readonly string[]).includes(p)
  );
  if (!valid.length) {
    return void res.status(400).json({ error: 'No valid packages specified' } satisfies ApiError);
  }
  if (!isStowMode(modeRaw)) {
    return void res.status(400).json({ error: `Unknown mode: ${modeRaw}` } satisfies ApiError);
  }

  const flags = STOW_FLAGS[modeRaw];
  const job = createJob(`stow:${modeRaw} [${valid.join(', ')}]`);
  void runProc({ job, cmd: 'stow', args: [...flags, ...valid], cwd: STOW_DIR });
  res.json({ jobId: job.id } satisfies JobIdResponse);
});

export default router;
