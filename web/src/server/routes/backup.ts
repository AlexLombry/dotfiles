import { Router } from 'express';
import fs   from 'node:fs';
import path from 'node:path';
import { PACKAGES, HOME_DIR, BACKUP_BASE, STOW_DIR } from '../config';
import { scanPackage } from '../fs-utils';
import { createJob, runProc, jobEmit, jobFinish, type Job } from '../jobs';
import type { JobIdResponse } from '../../shared/types';

function makeTimestampDir(): string {
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  return path.join(BACKUP_BASE, ts);
}

function filterValid(pkgs: unknown[]): string[] {
  return pkgs.filter((p): p is string =>
    typeof p === 'string' && (PACKAGES as readonly string[]).includes(p)
  );
}

async function backupConflicts(
  job: Job,
  valid: string[],
  backupDir: string,
  removeAfterCopy: boolean,
): Promise<number> {
  let n = 0;
  for (const name of valid) {
    const pkg = scanPackage(name);
    for (const f of pkg.files.filter(f => f.status === 'conflict')) {
      try {
        const dest = path.join(backupDir, path.relative(HOME_DIR, f.dest));
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        fs.copyFileSync(f.dest, dest);
        if (removeAfterCopy) fs.unlinkSync(f.dest);
        jobEmit(job, 'stdout', `  ${removeAfterCopy ? 'moved' : 'backed up'}: ${f.dest}\n`);
        n++;
      } catch (e: unknown) {
        const msg = e instanceof Error ? e.message : String(e);
        jobEmit(job, 'stderr', `  ${removeAfterCopy ? 'error' : 'skip'} ${f.dest}: ${msg}\n`);
      }
    }
  }
  return n;
}

const router = Router();

// Backup conflicting files (copies to backup/, does not remove them)
router.post('/', (req, res) => {
  const body = req.body as Record<string, unknown>;
  const rawPkgs = Array.isArray(body['packages']) ? (body['packages'] as unknown[]) : [...PACKAGES];
  const valid = filterValid(rawPkgs);
  const backupDir = makeTimestampDir();
  const job = createJob(`backup [${valid.join(', ')}]`);

  void (async () => {
    const n = await backupConflicts(job, valid, backupDir, false);
    jobEmit(job, 'stdout',
      n > 0 ? `\n${n} file(s) → ${backupDir}\n` : 'No conflicting files found. Nothing to backup.\n'
    );
    jobFinish(job, 0);
  })();

  res.json({ jobId: job.id } satisfies JobIdResponse);
});

// Backup conflicts then immediately stow (atomic-ish operation)
router.post('/and-stow', (req, res) => {
  const body = req.body as Record<string, unknown>;
  const rawPkgs = Array.isArray(body['packages']) ? (body['packages'] as unknown[]) : [...PACKAGES];
  const valid = filterValid(rawPkgs);
  const backupDir = makeTimestampDir();
  const job = createJob(`backup+stow [${valid.join(', ')}]`);

  void (async () => {
    jobEmit(job, 'stdout', '── Phase 1: Backup conflicts ──────────────────\n');
    const n = await backupConflicts(job, valid, backupDir, true);
    jobEmit(job, 'stdout', n > 0 ? `  ${n} file(s) → ${backupDir}\n\n` : '  No conflicts.\n\n');

    jobEmit(job, 'stdout', '── Phase 2: Apply symlinks ────────────────────\n');
    await runProc({ job, cmd: 'stow', args: ['-v', '-t', HOME_DIR, ...valid], cwd: STOW_DIR });
  })();

  res.json({ jobId: job.id } satisfies JobIdResponse);
});

export { router as backupRouter };
