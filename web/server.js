'use strict';

const express = require('express');
const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const os = require('os');
const { randomUUID } = require('crypto');

const app = express();
const PORT = Number(process.env.PORT) || 3131;

const DOTFILES_DIR = path.resolve(__dirname, '..');
const STOW_DIR = path.join(DOTFILES_DIR, 'stow');
const INSTALL_DIR = path.join(DOTFILES_DIR, 'install');
const HOME_DIR = os.homedir();
const BACKUP_BASE = path.join(DOTFILES_DIR, 'backup');
const PACKAGES = ['zsh', 'git', 'config', 'apps', 'work'];

// Mirrors stow-local-ignore patterns (basenames and VCS dirs)
const IGNORE_EXACT = new Set([
  '.DS_Store', '.git', '.gitignore', '.gitmodules', '.svn', '_darcs', '.hg',
  'CVS', 'RCS', '.cvsignore', 'COPYING',
]);

function shouldIgnore(name) {
  if (IGNORE_EXACT.has(name)) return true;
  if (name.endsWith('~')) return true;           // emacs backup
  if (/^\#.*\#$/.test(name)) return true;        // emacs autosave
  if (/^README(\..+)?$/.test(name)) return true;
  if (/^LICENSE(\..+)?$/.test(name)) return true;
  return false;
}

function* walkDir(dir) {
  let entries;
  try { entries = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const e of entries) {
    if (shouldIgnore(e.name)) continue;
    const full = path.join(dir, e.name);
    if (e.isDirectory()) yield* walkDir(full);
    else yield full;
  }
}

function symlinkStatus(src, dest) {
  let lstat;
  try { lstat = fs.lstatSync(dest); } catch { return 'missing'; }
  if (!lstat.isSymbolicLink()) return 'conflict';
  try {
    // Resolve the symlink target and compare to src
    const target = fs.readlinkSync(dest);
    const resolved = path.resolve(path.dirname(dest), target);
    return resolved === src ? 'linked' : 'conflict';
  } catch { return 'broken'; }
}

function scanPackage(name) {
  const pkgDir = path.join(STOW_DIR, name);
  if (!fs.existsSync(pkgDir)) return { name, files: [], error: 'Package directory not found' };
  const files = [];
  for (const src of walkDir(pkgDir)) {
    const rel = path.relative(pkgDir, src);
    const dest = path.join(HOME_DIR, rel);
    files.push({ rel, src, dest, status: symlinkStatus(src, dest) });
  }
  return { name, files };
}

// ── Job system ───────────────────────────────────────────────────────────────

const jobs = new Map();

function createJob(label) {
  const id = randomUUID();
  const job = { id, label, status: 'running', output: [], listeners: new Set(), startedAt: Date.now() };
  jobs.set(id, job);
  // Evict oldest jobs if over 100
  if (jobs.size > 100) jobs.delete(jobs.keys().next().value);
  return job;
}

function jobEmit(job, type, data) {
  const ev = { type, data, ts: Date.now() };
  job.output.push(ev);
  for (const res of job.listeners) res.write(`data: ${JSON.stringify(ev)}\n\n`);
}

function jobFinish(job, code) {
  job.status = code === 0 ? 'success' : 'failed';
  job.exitCode = code;
  job.finishedAt = Date.now();
  jobEmit(job, 'exit', { code });
  for (const res of job.listeners) res.end();
  job.listeners.clear();
}

function runProc(job, cmd, args, cwd, extraEnv = {}) {
  return new Promise(resolve => {
    const proc = spawn(cmd, args, {
      cwd,
      shell: false,
      env: { ...process.env, ...extraEnv },
    });
    proc.stdout.on('data', d => jobEmit(job, 'stdout', d.toString()));
    proc.stderr.on('data', d => jobEmit(job, 'stderr', d.toString()));
    proc.on('close', code => { jobFinish(job, code ?? 1); resolve(code); });
    proc.on('error', err => {
      jobEmit(job, 'stderr', `spawn error: ${err.message}\n`);
      jobFinish(job, 1);
      resolve(1);
    });
  });
}

// ── Whitelisted just commands ────────────────────────────────────────────────

const JUST_CMDS = {
  check:         { label: 'Check prerequisites',           safe: true,  desc: 'Verify brew, just, stow, and Xcode CLT are installed.' },
  stow:          { label: 'Apply symlinks',                safe: false, desc: 'Symlink all packages to $HOME. Refuses to overwrite existing files.' },
  'stow-fresh':  { label: 'First-time stow (--adopt)',     safe: false, desc: 'Adopt existing $HOME files into the repo. Clean machine only.' },
  'stow-check':  { label: 'Dry-run stow preview',          safe: true,  desc: 'Preview what would be linked without making any changes.' },
  unstow:        { label: 'Remove all symlinks',           safe: false, desc: 'Remove all managed symlinks. Dotfiles repo stays intact.' },
  brew:          { label: 'Install Homebrew bundle',       safe: false, desc: 'Install all packages from install/BrewFile via Homebrew Bundle.' },
  mise:          { label: 'Install language runtimes',     safe: false, desc: 'Install node, python, ruby, and other runtimes via mise.' },
  os:            { label: 'Apply macOS defaults',          safe: false, desc: 'Set macOS system preferences via install/macos.sh.' },
  doctor:        { label: 'Diagnose drift & issues',       safe: true,  desc: 'Check stow conflicts, brew drift, stale caches, compaudit.' },
  'init-shell':  { label: 'Generate shell init files',     safe: false, desc: 'Pre-generate starship/zoxide init scripts for faster startup.' },
  completions:   { label: 'Generate shell completions',    safe: false, desc: 'Regenerate uv/uvx zsh completions.' },
  bench:         { label: 'Benchmark shell startup',       safe: true,  desc: 'Measure zsh startup time across 3 runs.' },
  setup:         { label: 'Full MacBook setup',            safe: false, desc: 'Runs: check → stow-fresh → os → brew → mise → completions → init-shell.' },
  update:        { label: 'Update all packages',           safe: false, desc: 'Run upd8r to update brew, mise, composer, mas, and rust.' },
  'backup-agent':{ label: 'Install backup LaunchAgent',   safe: false, desc: 'Install and load the backup_secure LaunchAgent.' },
};

// ── Routes ───────────────────────────────────────────────────────────────────

app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

app.get('/api/info', (_, res) => res.json({
  dotfilesDir: DOTFILES_DIR,
  stowDir: STOW_DIR,
  homeDir: HOME_DIR,
  packages: PACKAGES,
  backupBase: BACKUP_BASE,
}));

app.get('/api/packages', (_, res) => {
  res.json(PACKAGES.map(scanPackage));
});

app.get('/api/commands', (_, res) => {
  res.json(Object.entries(JUST_CMDS).map(([cmd, meta]) => ({ cmd, ...meta })));
});

app.get('/api/prerequisites', async (_, res) => {
  const checks = [
    { name: 'Homebrew', cmd: 'brew',         args: ['--version'] },
    { name: 'Just',     cmd: 'just',         args: ['--version'] },
    { name: 'GNU Stow', cmd: 'stow',         args: ['--version'] },
    { name: 'Xcode CLT',cmd: 'xcode-select', args: ['-p'] },
    { name: 'Mise',     cmd: 'mise',         args: ['--version'] },
    { name: 'Git',      cmd: 'git',          args: ['--version'] },
    { name: 'Node.js',  cmd: 'node',         args: ['--version'] },
    { name: 'GPG',      cmd: 'gpg',          args: ['--version'] },
  ];
  const results = await Promise.all(checks.map(({ name, cmd, args }) =>
    new Promise(resolve => {
      const p = spawn(cmd, args, { shell: false });
      let out = '';
      p.stdout.on('data', d => out += d.toString());
      p.stderr.on('data', d => out += d.toString());
      p.on('close', code => resolve({ name, ok: code === 0, version: out.trim().split('\n')[0] }));
      p.on('error', () => resolve({ name, ok: false, version: 'not found' }));
    })
  ));
  res.json(results);
});

// Run a whitelisted just command
app.post('/api/run', (req, res) => {
  const { command } = req.body ?? {};
  if (!JUST_CMDS[command]) return res.status(400).json({ error: `Unknown command: ${command}` });
  const job = createJob(`just ${command}`);
  runProc(job, 'just', [command], INSTALL_DIR);
  res.json({ jobId: job.id });
});

// Stow / unstow / dry-run specific packages
app.post('/api/stow', (req, res) => {
  const { packages: pkgs = [], mode = 'stow' } = req.body ?? {};
  const valid = pkgs.filter(p => PACKAGES.includes(p));
  if (!valid.length) return res.status(400).json({ error: 'No valid packages specified' });

  const flagMap = {
    stow:      ['-v', '-t', HOME_DIR],
    'dry-run': ['-n', '-v', '-t', HOME_DIR],
    unstow:    ['-D', '-v', '-t', HOME_DIR],
    adopt:     ['--adopt', '-v', '-t', HOME_DIR],
  };
  if (!flagMap[mode]) return res.status(400).json({ error: `Unknown mode: ${mode}` });

  const job = createJob(`stow:${mode} [${valid.join(', ')}]`);
  runProc(job, 'stow', [...flagMap[mode], ...valid], STOW_DIR);
  res.json({ jobId: job.id });
});

// Backup conflicting files (copies to backup/, does not remove them)
app.post('/api/backup', (req, res) => {
  const { packages: pkgs = PACKAGES } = req.body ?? {};
  const valid = pkgs.filter(p => PACKAGES.includes(p));
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const backupDir = path.join(BACKUP_BASE, ts);
  const job = createJob(`backup [${valid.join(', ')}]`);

  (async () => {
    let n = 0;
    for (const name of valid) {
      const pkg = scanPackage(name);
      const conflicts = pkg.files.filter(f => f.status === 'conflict');
      for (const f of conflicts) {
        try {
          const dest = path.join(backupDir, path.relative(HOME_DIR, f.dest));
          fs.mkdirSync(path.dirname(dest), { recursive: true });
          fs.copyFileSync(f.dest, dest);
          jobEmit(job, 'stdout', `  backed up: ${f.dest}\n`);
          n++;
        } catch (e) {
          jobEmit(job, 'stderr', `  skip ${f.dest}: ${e.message}\n`);
        }
      }
    }
    if (n > 0) {
      jobEmit(job, 'stdout', `\n${n} file(s) → ${backupDir}\n`);
    } else {
      jobEmit(job, 'stdout', 'No conflicting files found. Nothing to backup.\n');
    }
    jobFinish(job, 0);
  })();

  res.json({ jobId: job.id });
});

// Backup conflicts then immediately stow (atomic operation)
app.post('/api/backup-and-stow', (req, res) => {
  const { packages: pkgs = PACKAGES } = req.body ?? {};
  const valid = pkgs.filter(p => PACKAGES.includes(p));
  const ts = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
  const backupDir = path.join(BACKUP_BASE, ts);
  const job = createJob(`backup+stow [${valid.join(', ')}]`);

  (async () => {
    jobEmit(job, 'stdout', '── Phase 1: Backup conflicts ──────────────────\n');
    let n = 0;
    for (const name of valid) {
      const pkg = scanPackage(name);
      for (const f of pkg.files.filter(f => f.status === 'conflict')) {
        try {
          const dest = path.join(backupDir, path.relative(HOME_DIR, f.dest));
          fs.mkdirSync(path.dirname(dest), { recursive: true });
          fs.copyFileSync(f.dest, dest);
          fs.unlinkSync(f.dest);
          jobEmit(job, 'stdout', `  moved: ${f.dest}\n`);
          n++;
        } catch (e) {
          jobEmit(job, 'stderr', `  error: ${f.dest}: ${e.message}\n`);
        }
      }
    }
    jobEmit(job, 'stdout', n > 0 ? `  ${n} file(s) → ${backupDir}\n\n` : '  No conflicts.\n\n');

    jobEmit(job, 'stdout', '── Phase 2: Apply symlinks ────────────────────\n');
    await runProc(job, 'stow', ['-v', '-t', HOME_DIR, ...valid], STOW_DIR);
  })();

  res.json({ jobId: job.id });
});

// List available backups
app.get('/api/backups', (_, res) => {
  try {
    if (!fs.existsSync(BACKUP_BASE)) return res.json([]);
    const dirs = fs.readdirSync(BACKUP_BASE, { withFileTypes: true })
      .filter(e => e.isDirectory())
      .map(e => {
        const dir = path.join(BACKUP_BASE, e.name);
        let count = 0;
        try { for (const _ of walkDir(dir)) count++; } catch {}
        return { name: e.name, fileCount: count };
      })
      .sort((a, b) => b.name.localeCompare(a.name)); // newest first
    res.json(dirs);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Restore a backup (copies files back, removes any symlink at dest first)
app.post('/api/rollback/:backup', (req, res) => {
  const name = path.basename(req.params.backup); // path.basename prevents traversal
  const dir = path.join(BACKUP_BASE, name);
  if (!fs.existsSync(dir)) return res.status(404).json({ error: 'Backup not found' });

  const job = createJob(`rollback ${name}`);
  (async () => {
    let n = 0;
    for (const src of walkDir(dir)) {
      const rel = path.relative(dir, src);
      const dest = path.join(HOME_DIR, rel);
      try {
        fs.mkdirSync(path.dirname(dest), { recursive: true });
        try { fs.unlinkSync(dest); } catch {}
        fs.copyFileSync(src, dest);
        jobEmit(job, 'stdout', `  restored: ${dest}\n`);
        n++;
      } catch (e) {
        jobEmit(job, 'stderr', `  error: ${dest}: ${e.message}\n`);
      }
    }
    jobEmit(job, 'stdout', `\n${n} file(s) restored from ${dir}\n`);
    jobFinish(job, 0);
  })();

  res.json({ jobId: job.id });
});

// SSE stream for a job
app.get('/api/jobs/:id/stream', (req, res) => {
  const job = jobs.get(req.params.id);
  if (!job) return res.status(404).send('Job not found');

  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  // Replay buffered output for late subscribers
  for (const ev of job.output) {
    res.write(`data: ${JSON.stringify(ev)}\n\n`);
  }

  if (job.status !== 'running') return res.end();

  job.listeners.add(res);
  req.on('close', () => job.listeners.delete(res));
});

// Non-streaming job status
app.get('/api/jobs/:id', (req, res) => {
  const job = jobs.get(req.params.id);
  if (!job) return res.status(404).json({ error: 'Not found' });
  const { id, label, status, exitCode, startedAt, finishedAt } = job;
  res.json({ id, label, status, exitCode, startedAt, finishedAt });
});

app.listen(PORT, () => {
  console.log(`\n  Dotfiles Manager  →  http://localhost:${PORT}`);
  console.log(`  Dotfiles root     →  ${DOTFILES_DIR}\n`);
});
