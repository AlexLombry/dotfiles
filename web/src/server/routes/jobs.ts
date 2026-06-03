import { Router } from 'express';
import { getJob, getJobSummary } from '../jobs';
import type { ApiError } from '../../shared/types';

const router = Router();

router.get('/:id/stream', (req, res) => {
  const job = getJob(req.params['id'] ?? '');
  if (!job) return void res.status(404).send('Job not found');

  res.setHeader('Content-Type',  'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection',    'keep-alive');
  res.flushHeaders();

  for (const ev of job.output) {
    res.write(`data: ${JSON.stringify(ev)}\n\n`);
  }

  if (job.status !== 'running') return void res.end();

  job.listeners.add(res);
  req.on('close', () => job.listeners.delete(res));
});

router.get('/:id', (req, res) => {
  const job = getJob(req.params['id'] ?? '');
  if (!job) return void res.status(404).json({ error: 'Not found' } satisfies ApiError);
  res.json(getJobSummary(job));
});

export default router;
