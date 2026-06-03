import { Router } from 'express';
import fs   from 'node:fs';
import path from 'node:path';
import { BACKUP_BASE, HOME_DIR } from '../config';
import { walkDir } from '../fs-utils';
import { createJob, jobEmit, jobFinish } from '../jobs';
import type { BackupEntry, ApiError, JobIdResponse } from '../../shared/types';

const router = Router();

router.get('/', (_req, res) => {
  try {
    if (!fs.existsSync(BACKUP_BASE)) return void res.json([]);
    const entries: BackupEntry[] = fs.readdirSync(BACKUP_BASE, { withFileTypes: true })
      .filter(e => e.isDirectory())
      .map(e => {
        let fileCount = 0;
        for (const _ of walkDir(path.join(BACKUP_BASE, e.name))) fileCount++;
        return { name: e.name, fileCount };
      })
      .sort((a, b) => b.name.localeCompare(a.name));
    res.json(entries);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Internal server error';
    res.status(500).json({ error: msg } satisfies ApiError);
  }
});

router.post('/:backup/rollback', (req, res) => {
  const name = path.basename(req.params['backup'] ?? '');
  const dir  = path.join(BACKUP_BASE, name);
  if (!fs.existsSync(dir)) {
    return void res.status(404).json({ error: 'Backup not found' } satisfies ApiError);
  }

  const job = createJob(`rollback ${name}`);

  void (async () => {
    let n = 0;
    for (const src of walkDir(dir)) {
      const rel  = path.relative(dir, src);
      const dest = path.join(HOME_DIR, rel);
      try {
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        try { fs.unlinkSync(dest); } catch {}
        fs.copyFileSync(src, dest);
        jobEmit(job, 'stdout', `  restored: ${dest}\n`);
        n++;
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : String(e);
        jobEmit(job, 'stderr', `  error: ${dest}: ${msg}\n`);
      }
    }
    jobEmit(job, 'stdout', `\n${n} file(s) restored from ${dir}\n`);
    jobFinish(job, 0);
  })();

  res.json({ jobId: job.id } satisfies JobIdResponse);
});

export default router;
