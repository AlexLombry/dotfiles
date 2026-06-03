import { Router } from 'express';
import { spawn } from 'node:child_process';
import type { PrerequisiteResult } from '../../shared/types';

interface CheckSpec {
  name: string;
  cmd:  string;
  args: string[];
}

const CHECKS: CheckSpec[] = [
  { name: 'Homebrew',  cmd: 'brew',         args: ['--version'] },
  { name: 'Just',      cmd: 'just',         args: ['--version'] },
  { name: 'GNU Stow',  cmd: 'stow',         args: ['--version'] },
  { name: 'Xcode CLT', cmd: 'xcode-select', args: ['-p'] },
  { name: 'Mise',      cmd: 'mise',         args: ['--version'] },
  { name: 'Git',       cmd: 'git',          args: ['--version'] },
  { name: 'Node.js',   cmd: 'node',         args: ['--version'] },
  { name: 'GPG',       cmd: 'gpg',          args: ['--version'] },
];

function checkTool({ name, cmd, args }: CheckSpec): Promise<PrerequisiteResult> {
  return new Promise(resolve => {
    const p = spawn(cmd, args, { shell: false });
    let out = '';
    p.stdout.on('data', (d: Buffer) => { out += d.toString(); });
    p.stderr.on('data', (d: Buffer) => { out += d.toString(); });
    p.on('close', (code: number | null) => {
      resolve({ name, ok: code === 0, version: out.trim().split('\n')[0] ?? 'unknown' });
    });
    p.on('error', () => resolve({ name, ok: false, version: 'not found' }));
  });
}

const router = Router();

router.get('/', async (_req, res) => {
  const results = await Promise.all(CHECKS.map(checkTool));
  res.json(results);
});

export default router;
