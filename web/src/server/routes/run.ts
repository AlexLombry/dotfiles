import { Router } from 'express';
import { JUST_CMDS } from '../commands';
import { INSTALL_DIR } from '../config';
import { createJob, runProc } from '../jobs';
import type { ApiError, JobIdResponse } from '../../shared/types';

const router = Router();

router.post('/', (req, res) => {
  const command: unknown = (req.body as Record<string, unknown>)['command'];
  if (typeof command !== 'string' || !JUST_CMDS[command]) {
    return void res.status(400).json({ error: `Unknown command: ${String(command)}` } satisfies ApiError);
  }
  const job = createJob(`just ${command}`);
  void runProc({ job, cmd: 'just', args: [command], cwd: INSTALL_DIR });
  res.json({ jobId: job.id } satisfies JobIdResponse);
});

export default router;
