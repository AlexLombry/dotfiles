import type {
  Package,
  FileEntry,
  AnyJobEvent,
  InfoResponse,
  JobIdResponse,
  CommandEntry,
  PrerequisiteResult,
  BackupEntry,
} from '../shared/types';

// ── State ────────────────────────────────────────────────────────────────────

let packages:     Package[]   = [];
let selectedPkgs: Set<string> = new Set();
let homeDir:      string      = '';
let isTermOpen:   boolean     = false;

const PKG_ICONS: Partial<Record<string, string>> = {
  zsh: '🐚', git: '🔀', config: '⚙', apps: '📦', work: '💼',
};

// ── Bootstrap ────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', async () => {
  setupTabs();
  setupTerminal();
  setupButtons();
  await loadInfo();
  loadPackages();
  loadActions();
});

// ── API helper ────────────────────────────────────────────────────────────────

async function api<T>(url: string, method = 'GET', body: unknown = null): Promise<T> {
  const init: RequestInit = body
    ? { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }
    : { method };
  const res = await fetch(url, init);
  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText })) as { error?: string };
    throw new Error(err.error ?? res.statusText);
  }
  return res.json() as Promise<T>;
}

// ── DOM helpers ───────────────────────────────────────────────────────────────

function el(tag: string, className?: string, attrs: Record<string, string> = {}): HTMLElement {
  const e = document.createElement(tag);
  if (className) e.className = className;
  for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v);
  return e;
}

function getEl(id: string): HTMLElement {
  const e = document.getElementById(id);
  if (!e) throw new Error(`Missing element: #${id}`);
  return e;
}

// ── Info / header ─────────────────────────────────────────────────────────────

async function loadInfo(): Promise<void> {
  try {
    const info = await api<InfoResponse>('/api/info');
    homeDir = info.homeDir;
    getEl('dotfiles-path').textContent = info.dotfilesDir;
  } catch (e: unknown) {
    console.error('loadInfo:', e);
  }
}

// ── Packages ─────────────────────────────────────────────────────────────────

async function loadPackages(): Promise<void> {
  getEl('packages-grid').innerHTML = '<div class="loading">Scanning packages…</div>';
  try {
    packages = await api<Package[]>('/api/packages');
    renderPackages();
    updateStatusPills();
    updateSetupBanner();
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Unknown error';
    getEl('packages-grid').innerHTML =
      `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
  }
}

function renderPackages(): void {
  const grid = getEl('packages-grid');
  grid.innerHTML = '';
  for (const pkg of packages) grid.appendChild(makePackageCard(pkg));
}

function makePackageCard(pkg: Package): HTMLElement {
  const linked   = pkg.files.filter(f => f.status === 'linked').length;
  const missing  = pkg.files.filter(f => f.status === 'missing').length;
  const conflict = pkg.files.filter(f => f.status === 'conflict').length;
  const broken   = pkg.files.filter(f => f.status === 'broken').length;
  const sel      = selectedPkgs.has(pkg.name);

  const card = el('div', `pkg-card${sel ? ' selected' : ''}`, { 'data-pkg': pkg.name });

  const statsHtml = [
    linked   > 0 ? `<span class="stat stat-linked">${linked} linked</span>`       : '',
    missing  > 0 ? `<span class="stat stat-missing">${missing} missing</span>`    : '',
    conflict > 0 ? `<span class="stat stat-conflict">${conflict} conflict</span>` : '',
    broken   > 0 ? `<span class="stat stat-broken">${broken} broken</span>`       : '',
  ].join('') || `<span class="stat" style="color:var(--overlay0)">${pkg.files.length} files</span>`;

  const filesHtml = pkg.files.map((f: FileEntry) => {
    const destDisplay = homeDir ? f.dest.replace(homeDir, '~') : f.dest;
    return `<div class="file-row">
      <span class="status-dot dot-${f.status}" title="${f.status}"></span>
      <span class="file-rel">${f.rel}</span>
      <span class="file-dest" title="${f.dest}">${destDisplay}</span>
    </div>`;
  }).join('');

  card.innerHTML = `
    <div class="pkg-header">
      <input type="checkbox" class="pkg-cb" ${sel ? 'checked' : ''} title="Select ${pkg.name}">
      <span class="pkg-icon">${PKG_ICONS[pkg.name] ?? '📄'}</span>
      <span class="pkg-name">${pkg.name}</span>
      <div class="pkg-stats">${statsHtml}</div>
      <button class="pkg-expand" title="Show files">▼</button>
    </div>
    <div class="pkg-files">${filesHtml || '<div class="loading">Empty package</div>'}</div>
  `;

  const cb       = card.querySelector('.pkg-cb') as HTMLInputElement;
  const expand   = card.querySelector('.pkg-expand') as HTMLButtonElement;
  const fileList = card.querySelector('.pkg-files') as HTMLElement;

  cb.addEventListener('change', (e: Event) => {
    e.stopPropagation();
    const checked = (e.target as HTMLInputElement).checked;
    checked ? selectedPkgs.add(pkg.name) : selectedPkgs.delete(pkg.name);
    card.classList.toggle('selected', checked);
    syncSelectAll();
  });

  expand.addEventListener('click', (e: Event) => {
    e.stopPropagation();
    const open = fileList.classList.toggle('open');
    expand.textContent = open ? '▲' : '▼';
  });

  return card;
}

function updateStatusPills(): void {
  let linked = 0, missing = 0, conflict = 0;
  for (const pkg of packages) {
    for (const f of pkg.files) {
      if (f.status === 'linked') linked++;
      else if (f.status === 'missing') missing++;
      else conflict++;
    }
  }
  getEl('pill-linked').textContent   = `${linked} linked`;
  getEl('pill-missing').textContent  = `${missing} missing`;
  getEl('pill-conflict').textContent = `${conflict} conflicts`;
}

function updateSetupBanner(): void {
  const total   = packages.reduce((s, p) => s + p.files.length, 0);
  const missing = packages.reduce((s, p) => s + p.files.filter(f => f.status === 'missing').length, 0);
  getEl('setup-banner').classList.toggle('hidden', missing < total * 0.4 || total === 0);
}

function toggleSelectAll(e: Event): void {
  const checked = (e.target as HTMLInputElement).checked;
  packages.forEach(p => checked ? selectedPkgs.add(p.name) : selectedPkgs.delete(p.name));
  renderPackages();
}

function syncSelectAll(): void {
  (getEl('select-all') as HTMLInputElement).checked =
    packages.length > 0 && packages.every(p => selectedPkgs.has(p.name));
}

function getEffectivePkgs(): string[] {
  return selectedPkgs.size > 0 ? [...selectedPkgs] : packages.map(p => p.name);
}

// ── Stow operations ───────────────────────────────────────────────────────────

async function doDryRun(): Promise<void> {
  const pkgs = getEffectivePkgs();
  const { jobId } = await api<JobIdResponse>('/api/stow', 'POST', { packages: pkgs, mode: 'dry-run' });
  streamJob(jobId, `stow --dry-run [${pkgs.join(', ')}]`);
}

async function doBackup(): Promise<void> {
  const pkgs = getEffectivePkgs();
  const conflicts = packages
    .filter(p => pkgs.includes(p.name))
    .flatMap(p => p.files)
    .filter(f => f.status === 'conflict');
  if (conflicts.length === 0) { showToast('No conflicting files found.', 'info'); return; }
  const { jobId } = await api<JobIdResponse>('/api/backup', 'POST', { packages: pkgs });
  streamJob(jobId, `backup [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doInstall(): Promise<void> {
  const pkgs = getEffectivePkgs();
  const conflicts = packages
    .filter(p => pkgs.includes(p.name))
    .flatMap(p => p.files)
    .filter(f => f.status === 'conflict');

  if (conflicts.length > 0) {
    showModal('Conflicts Detected', `${conflicts.length} existing file(s) will block the installation. Choose how to proceed:`, [
      { label: 'Cancel',           cls: 'btn-ghost',   fn: null },
      { label: 'Backup & Install', cls: 'btn-success', fn: () => { void doBackupAndStow(pkgs); } },
      { label: 'Stow Anyway',      cls: 'btn-warning', fn: () => { void stowPkgs(pkgs); } },
    ]);
  } else {
    void stowPkgs(pkgs);
  }
}

async function stowPkgs(pkgs: string[]): Promise<void> {
  const { jobId } = await api<JobIdResponse>('/api/stow', 'POST', { packages: pkgs, mode: 'stow' });
  streamJob(jobId, `stow [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doBackupAndStow(pkgs: string[]): Promise<void> {
  const { jobId } = await api<JobIdResponse>('/api/backup/and-stow', 'POST', { packages: pkgs });
  streamJob(jobId, `backup+stow [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doUnstow(): Promise<void> {
  const pkgs = getEffectivePkgs();
  showModal('Remove Symlinks', `Remove all managed symlinks for: ${pkgs.join(', ')}.\n\nYour dotfiles repo will NOT be modified.`, [
    { label: 'Cancel', cls: 'btn-ghost',  fn: null },
    { label: 'Remove', cls: 'btn-danger', fn: async () => {
      const { jobId } = await api<JobIdResponse>('/api/stow', 'POST', { packages: pkgs, mode: 'unstow' });
      streamJob(jobId, `unstow [${pkgs.join(', ')}]`);
      afterJob(jobId, loadPackages);
    }},
  ]);
}

// ── Quick actions ─────────────────────────────────────────────────────────────

async function loadActions(): Promise<void> {
  try {
    const cmds = await api<CommandEntry[]>('/api/commands');
    renderActions(cmds);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Unknown error';
    getEl('actions-grid').innerHTML =
      `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
  }
}

function renderActions(cmds: CommandEntry[]): void {
  const grid = getEl('actions-grid');
  grid.innerHTML = '';
  for (const cmd of cmds) {
    const card = el('div', 'action-card');
    card.innerHTML = `
      <div class="action-card-header">
        <span class="action-cmd">just ${cmd.cmd}</span>
        <span class="badge ${cmd.safe ? 'badge-safe' : 'badge-caution'}">${cmd.safe ? '✓ safe' : '⚠ changes system'}</span>
      </div>
      <div class="action-label">${cmd.label}</div>
      <div class="action-desc">${cmd.desc}</div>
    `;
    card.addEventListener('click', () => triggerAction(cmd));
    grid.appendChild(card);
  }
}

function triggerAction(cmd: CommandEntry): void {
  if (!cmd.safe) {
    showModal(`Run: just ${cmd.cmd}`, `${cmd.label}\n\n${cmd.desc}`, [
      { label: 'Cancel', cls: 'btn-ghost',   fn: null },
      { label: 'Run',    cls: 'btn-warning', fn: () => { void executeAction(cmd.cmd); } },
    ]);
  } else {
    void executeAction(cmd.cmd);
  }
}

async function executeAction(command: string): Promise<void> {
  try {
    const { jobId } = await api<JobIdResponse>('/api/run', 'POST', { command });
    streamJob(jobId, `just ${command}`);
    if (['stow', 'stow-fresh', 'unstow', 'setup'].includes(command)) {
      afterJob(jobId, loadPackages);
    }
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Unknown error';
    showToast(`Error: ${msg}`, 'error');
  }
}

// ── Backups ───────────────────────────────────────────────────────────────────

async function loadBackups(): Promise<void> {
  const container = getEl('backups-list');
  container.innerHTML = '<div class="loading">Loading…</div>';
  try {
    const list = await api<BackupEntry[]>('/api/backups');
    if (list.length === 0) {
      container.innerHTML = '<div class="loading">No backups found. Backups are created automatically when conflicting files are moved.</div>';
      return;
    }
    const wrap = document.createElement('div');
    wrap.className = 'backup-list';
    for (const b of list) {
      const row = document.createElement('div');
      row.className = 'backup-row';
      row.innerHTML = `
        <div style="flex:1">
          <div class="backup-name">${b.name}</div>
          <div class="backup-count">${b.fileCount} file(s)</div>
        </div>
        <button class="btn btn-secondary btn-sm" data-backup="${b.name}">↩ Rollback</button>
      `;
      (row.querySelector('button') as HTMLButtonElement).addEventListener('click', () => triggerRollback(b.name));
      wrap.appendChild(row);
    }
    container.innerHTML = '';
    container.appendChild(wrap);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Unknown error';
    container.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
  }
}

function triggerRollback(name: string): void {
  showModal('Rollback Backup', `Restore files from backup "${name}"?\n\nThis will remove any symlinks at those paths and copy the original files back.`, [
    { label: 'Cancel',   cls: 'btn-ghost',  fn: null },
    { label: 'Rollback', cls: 'btn-danger', fn: async () => {
      const { jobId } = await api<JobIdResponse>(`/api/backups/${encodeURIComponent(name)}/rollback`, 'POST');
      streamJob(jobId, `rollback ${name}`);
      afterJob(jobId, () => { void loadPackages(); void loadBackups(); });
    }},
  ]);
}

// ── Prerequisites ─────────────────────────────────────────────────────────────

async function loadPrereqs(): Promise<void> {
  const container = getEl('prereqs-list');
  container.innerHTML = '<div class="loading">Checking prerequisites…</div>';
  try {
    const results = await api<PrerequisiteResult[]>('/api/prerequisites');
    const list = document.createElement('div');
    list.className = 'prereq-list';
    for (const r of results) {
      const row = document.createElement('div');
      row.className = 'prereq-row';
      row.innerHTML = `
        <span class="prereq-icon">${r.ok ? '✅' : '❌'}</span>
        <span class="prereq-name">${r.name}</span>
        <span class="prereq-version">${r.version || 'not found'}</span>
      `;
      list.appendChild(row);
    }
    container.innerHTML = '';
    container.appendChild(list);
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : 'Unknown error';
    container.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
  }
}

// ── SSE streaming ─────────────────────────────────────────────────────────────

const jobCallbacks = new Map<string, () => void | Promise<void>>();

function afterJob(jobId: string, fn: () => void | Promise<void>): void {
  jobCallbacks.set(jobId, fn);
}

function streamJob(jobId: string, label: string): void {
  termOpen(label);
  termAppend(`$ ${label}\n`, 't-info');

  const es = new EventSource(`/api/jobs/${jobId}/stream`);

  es.onmessage = (ev: MessageEvent<string>) => {
    const event = JSON.parse(ev.data) as AnyJobEvent;

    if (event.type === 'stdout') {
      termAppend(event.data, 't-stdout');
    } else if (event.type === 'stderr') {
      termAppend(event.data, 't-stderr');
    } else if (event.type === 'exit') {
      const ok = event.data.code === 0;
      termAppend(`\n[exit ${event.data.code}] ${ok ? '✓ Done' : '✗ Failed'}`, ok ? 't-ok' : 't-fail');
      getEl('terminal-status').textContent = `${label} — ${ok ? 'succeeded' : 'failed'} (exit ${event.data.code})`;
      showToast(`${label.slice(0, 40)} — ${ok ? 'Done ✓' : 'Failed ✗'}`, ok ? 'success' : 'error');
      es.close();

      const cb = jobCallbacks.get(jobId);
      if (cb) { jobCallbacks.delete(jobId); setTimeout(() => { void cb(); }, 300); }
    }
  };

  es.onerror = () => {
    termAppend('\n[stream closed]\n', 't-info');
    es.close();
  };
}

// ── Terminal ──────────────────────────────────────────────────────────────────

function setupTerminal(): void {
  const panel    = getEl('terminal-panel');
  const toggle   = getEl('terminal-toggle-btn');
  const header   = getEl('terminal-toggle-area');
  const clearBtn = getEl('terminal-clear');

  header.addEventListener('click', (e: Event) => {
    if (e.target === clearBtn) return;
    isTermOpen = !isTermOpen;
    panel.classList.toggle('collapsed', !isTermOpen);
    toggle.textContent = isTermOpen ? '▼' : '▲';
  });

  clearBtn.addEventListener('click', (e: Event) => {
    e.stopPropagation();
    getEl('terminal-body').innerHTML = '';
    getEl('terminal-status').textContent = '';
  });
}

function termOpen(label: string): void {
  getEl('terminal-job-name').textContent = `— ${label}`;
  isTermOpen = true;
  getEl('terminal-panel').classList.remove('collapsed');
  getEl('terminal-toggle-btn').textContent = '▼';
}

function termAppend(text: string, cls = 't-stdout'): void {
  const body = getEl('terminal-body');
  const span = document.createElement('span');
  span.className = cls;
  span.textContent = text;
  body.appendChild(span);
  body.scrollTop = body.scrollHeight;
}

// ── Tabs ──────────────────────────────────────────────────────────────────────

function setupTabs(): void {
  document.querySelectorAll<HTMLElement>('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(s => s.classList.remove('active'));
      tab.classList.add('active');

      const tabName = tab.dataset['tab'];
      if (tabName) {
        document.getElementById(`tab-${tabName}`)?.classList.add('active');
        if (tabName === 'backups') void loadBackups();
        if (tabName === 'prereqs') void loadPrereqs();
      }
    });
  });
}

// ── Toolbar buttons ───────────────────────────────────────────────────────────

interface ModalAction {
  label: string;
  cls:   string;
  fn:    (() => void | Promise<void>) | null;
}

function setupButtons(): void {
  getEl('refresh-btn').addEventListener('click', () => { void loadPackages(); });
  getEl('select-all').addEventListener('change',  toggleSelectAll);
  getEl('btn-dry-run').addEventListener('click',  () => { void doDryRun(); });
  getEl('btn-backup').addEventListener('click',   () => { void doBackup(); });
  getEl('btn-stow').addEventListener('click',     () => { void doInstall(); });
  getEl('btn-unstow').addEventListener('click',   () => { void doUnstow(); });

  document.addEventListener('keydown', (e: KeyboardEvent) => { if (e.key === 'Escape') closeModal(); });
  getEl('modal').addEventListener('click', (e: Event) => {
    if (e.target === e.currentTarget) closeModal();
  });
}

// ── Modal ─────────────────────────────────────────────────────────────────────

function showModal(title: string, message: string, actions: ModalAction[] = []): void {
  getEl('modal-title').textContent = title;
  getEl('modal-msg').textContent   = message;

  const actionsEl = getEl('modal-actions');
  actionsEl.innerHTML = '';
  for (const a of actions) {
    const btn = document.createElement('button');
    btn.className = `btn btn-sm ${a.cls}`;
    btn.textContent = a.label;
    btn.addEventListener('click', () => { closeModal(); if (a.fn) void a.fn(); });
    actionsEl.appendChild(btn);
  }

  getEl('modal').classList.remove('hidden');
}

function closeModal(): void {
  getEl('modal').classList.add('hidden');
}

// ── Toast ─────────────────────────────────────────────────────────────────────

function showToast(message: string, type: 'info' | 'success' | 'error' = 'info'): void {
  const container = getEl('toasts');
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.animation = 'fadeOut .3s ease forwards';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}
