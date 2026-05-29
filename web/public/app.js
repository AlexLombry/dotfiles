'use strict';

// ── State ────────────────────────────────────────────────────────────────────
let packages     = [];
let selectedPkgs = new Set();
let homeDir      = '';
let isTermOpen   = false;

const PKG_ICONS = { zsh: '🐚', git: '🔀', config: '⚙', apps: '📦', work: '💼' };

// ── Bootstrap ────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async () => {
  setupTabs();
  setupTerminal();
  setupButtons();
  await loadInfo();
  loadPackages();
  loadActions();
});

// ── Info / header ─────────────────────────────────────────────────────────────
async function loadInfo() {
  try {
    const info = await api('/api/info');
    homeDir = info.homeDir;
    document.getElementById('dotfiles-path').textContent = info.dotfilesDir;
  } catch (e) {
    console.error('loadInfo:', e);
  }
}

// ── Packages ─────────────────────────────────────────────────────────────────
async function loadPackages() {
  document.getElementById('packages-grid').innerHTML = '<div class="loading">Scanning packages…</div>';
  try {
    packages = await api('/api/packages');
    renderPackages();
    updateStatusPills();
    updateSetupBanner();
  } catch (e) {
    document.getElementById('packages-grid').innerHTML =
      `<div class="loading" style="color:var(--red)">Error: ${e.message}</div>`;
  }
}

function renderPackages() {
  const grid = document.getElementById('packages-grid');
  grid.innerHTML = '';
  for (const pkg of packages) grid.appendChild(makePackageCard(pkg));
}

function makePackageCard(pkg) {
  const linked   = pkg.files.filter(f => f.status === 'linked').length;
  const missing  = pkg.files.filter(f => f.status === 'missing').length;
  const conflict = pkg.files.filter(f => f.status === 'conflict').length;
  const broken   = pkg.files.filter(f => f.status === 'broken').length;
  const sel      = selectedPkgs.has(pkg.name);

  const card = el('div', `pkg-card${sel ? ' selected' : ''}`, { 'data-pkg': pkg.name });

  const statsHtml = [
    linked   > 0 ? `<span class="stat stat-linked">${linked} linked</span>`     : '',
    missing  > 0 ? `<span class="stat stat-missing">${missing} missing</span>`  : '',
    conflict > 0 ? `<span class="stat stat-conflict">${conflict} conflict</span>` : '',
    broken   > 0 ? `<span class="stat stat-broken">${broken} broken</span>`     : '',
  ].join('') || `<span class="stat" style="color:var(--overlay0)">${pkg.files.length} files</span>`;

  const filesHtml = pkg.files.map(f => {
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
      <span class="pkg-icon">${PKG_ICONS[pkg.name] || '📄'}</span>
      <span class="pkg-name">${pkg.name}</span>
      <div class="pkg-stats">${statsHtml}</div>
      <button class="pkg-expand" title="Show files">▼</button>
    </div>
    <div class="pkg-files">${filesHtml || '<div class="loading">Empty package</div>'}</div>
  `;

  const cb       = card.querySelector('.pkg-cb');
  const expand   = card.querySelector('.pkg-expand');
  const fileList = card.querySelector('.pkg-files');

  cb.addEventListener('change', e => {
    e.stopPropagation();
    e.target.checked ? selectedPkgs.add(pkg.name) : selectedPkgs.delete(pkg.name);
    card.classList.toggle('selected', e.target.checked);
    syncSelectAll();
  });

  expand.addEventListener('click', e => {
    e.stopPropagation();
    const open = fileList.classList.toggle('open');
    expand.textContent = open ? '▲' : '▼';
  });

  return card;
}

function updateStatusPills() {
  let linked = 0, missing = 0, conflict = 0;
  for (const pkg of packages) {
    for (const f of pkg.files) {
      if (f.status === 'linked') linked++;
      else if (f.status === 'missing') missing++;
      else conflict++;
    }
  }
  document.getElementById('pill-linked').textContent   = `${linked} linked`;
  document.getElementById('pill-missing').textContent  = `${missing} missing`;
  document.getElementById('pill-conflict').textContent = `${conflict} conflicts`;
}

function updateSetupBanner() {
  const total   = packages.reduce((s, p) => s + p.files.length, 0);
  const missing = packages.reduce((s, p) => s + p.files.filter(f => f.status === 'missing').length, 0);
  const banner  = document.getElementById('setup-banner');
  banner.classList.toggle('hidden', missing < total * 0.4 || total === 0);
}

function toggleSelectAll(e) {
  packages.forEach(p => e.target.checked ? selectedPkgs.add(p.name) : selectedPkgs.delete(p.name));
  renderPackages();
}

function syncSelectAll() {
  document.getElementById('select-all').checked = packages.length > 0 && packages.every(p => selectedPkgs.has(p.name));
}

function getEffectivePkgs() {
  return selectedPkgs.size > 0 ? [...selectedPkgs] : packages.map(p => p.name);
}

// ── Stow operations ───────────────────────────────────────────────────────────
async function doDryRun() {
  const pkgs = getEffectivePkgs();
  const { jobId } = await api('/api/stow', 'POST', { packages: pkgs, mode: 'dry-run' });
  streamJob(jobId, `stow --dry-run [${pkgs.join(', ')}]`);
}

async function doBackup() {
  const pkgs = getEffectivePkgs();
  const conflicts = packages.filter(p => pkgs.includes(p.name)).flatMap(p => p.files).filter(f => f.status === 'conflict');
  if (conflicts.length === 0) { showToast('No conflicting files found.', 'info'); return; }
  const { jobId } = await api('/api/backup', 'POST', { packages: pkgs });
  streamJob(jobId, `backup [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doInstall() {
  const pkgs = getEffectivePkgs();
  const conflicts = packages.filter(p => pkgs.includes(p.name)).flatMap(p => p.files).filter(f => f.status === 'conflict');

  if (conflicts.length > 0) {
    showModal('Conflicts Detected', `${conflicts.length} existing file(s) will block the installation. Choose how to proceed:`, [
      { label: 'Cancel',            cls: 'btn-ghost',     fn: null },
      { label: 'Backup & Install',  cls: 'btn-success',   fn: () => doBackupAndStow(pkgs) },
      { label: 'Stow Anyway',       cls: 'btn-warning',   fn: () => stowPkgs(pkgs) },
    ]);
  } else {
    stowPkgs(pkgs);
  }
}

async function stowPkgs(pkgs) {
  const { jobId } = await api('/api/stow', 'POST', { packages: pkgs, mode: 'stow' });
  streamJob(jobId, `stow [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doBackupAndStow(pkgs) {
  const { jobId } = await api('/api/backup-and-stow', 'POST', { packages: pkgs });
  streamJob(jobId, `backup+stow [${pkgs.join(', ')}]`);
  afterJob(jobId, loadPackages);
}

async function doUnstow() {
  const pkgs = getEffectivePkgs();
  showModal('Remove Symlinks', `Remove all managed symlinks for: ${pkgs.join(', ')}.\n\nYour dotfiles repo will NOT be modified.`, [
    { label: 'Cancel',  cls: 'btn-ghost',  fn: null },
    { label: 'Remove',  cls: 'btn-danger', fn: async () => {
      const { jobId } = await api('/api/stow', 'POST', { packages: pkgs, mode: 'unstow' });
      streamJob(jobId, `unstow [${pkgs.join(', ')}]`);
      afterJob(jobId, loadPackages);
    }},
  ]);
}

// ── Quick actions ─────────────────────────────────────────────────────────────
async function loadActions() {
  try {
    const cmds = await api('/api/commands');
    renderActions(cmds);
  } catch (e) {
    document.getElementById('actions-grid').innerHTML =
      `<div class="loading" style="color:var(--red)">Error: ${e.message}</div>`;
  }
}

function renderActions(cmds) {
  const grid = document.getElementById('actions-grid');
  grid.innerHTML = '';
  for (const cmd of cmds) {
    const card = el('div', 'action-card');
    card.innerHTML = `
      <div class="action-card-header">
        <span class="action-cmd">just ${cmd.cmd}</span>
        <span class="badge ${cmd.safe ? 'badge-safe' : 'badge-caution'}">${cmd.safe ? '✓ safe' : '⚠ changes system'}</span>
      </div>
      <div class="action-label">${cmd.label}</div>
      <div class="action-desc">${cmd.desc || ''}</div>
    `;
    card.addEventListener('click', () => triggerAction(cmd));
    grid.appendChild(card);
  }
}

function triggerAction(cmd) {
  if (!cmd.safe) {
    showModal(`Run: just ${cmd.cmd}`, `${cmd.label}\n\n${cmd.desc || ''}`, [
      { label: 'Cancel',  cls: 'btn-ghost',   fn: null },
      { label: 'Run',     cls: 'btn-warning',  fn: () => executeAction(cmd.cmd) },
    ]);
  } else {
    executeAction(cmd.cmd);
  }
}

async function executeAction(command) {
  try {
    const { jobId } = await api('/api/run', 'POST', { command });
    streamJob(jobId, `just ${command}`);
    if (['stow', 'stow-fresh', 'unstow', 'setup'].includes(command)) {
      afterJob(jobId, loadPackages);
    }
  } catch (e) {
    showToast(`Error: ${e.message}`, 'error');
  }
}

// ── Backups ───────────────────────────────────────────────────────────────────
async function loadBackups() {
  const el = document.getElementById('backups-list');
  el.innerHTML = '<div class="loading">Loading…</div>';
  try {
    const list = await api('/api/backups');
    if (list.length === 0) {
      el.innerHTML = '<div class="loading">No backups found. Backups are created automatically when conflicting files are moved.</div>';
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
      row.querySelector('button').addEventListener('click', () => triggerRollback(b.name));
      wrap.appendChild(row);
    }
    el.innerHTML = '';
    el.appendChild(wrap);
  } catch (e) {
    el.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${e.message}</div>`;
  }
}

function triggerRollback(name) {
  showModal('Rollback Backup', `Restore files from backup "${name}"?\n\nThis will remove any symlinks at those paths and copy the original files back.`, [
    { label: 'Cancel',    cls: 'btn-ghost',  fn: null },
    { label: 'Rollback',  cls: 'btn-danger', fn: async () => {
      const { jobId } = await api(`/api/rollback/${encodeURIComponent(name)}`, 'POST');
      streamJob(jobId, `rollback ${name}`);
      afterJob(jobId, () => { loadPackages(); loadBackups(); });
    }},
  ]);
}

// ── Prerequisites ─────────────────────────────────────────────────────────────
async function loadPrereqs() {
  const container = document.getElementById('prereqs-list');
  container.innerHTML = '<div class="loading">Checking prerequisites…</div>';
  try {
    const results = await api('/api/prerequisites');
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
  } catch (e) {
    container.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${e.message}</div>`;
  }
}

// ── SSE streaming ─────────────────────────────────────────────────────────────
const jobCallbacks = new Map(); // jobId → callback fn after completion

function afterJob(jobId, fn) {
  jobCallbacks.set(jobId, fn);
}

function streamJob(jobId, label) {
  termOpen(label);
  termAppend(`$ ${label}\n`, 't-info');

  const es = new EventSource(`/api/jobs/${jobId}/stream`);

  es.onmessage = ev => {
    const event = JSON.parse(ev.data);

    if (event.type === 'stdout') {
      termAppend(event.data, 't-stdout');
    } else if (event.type === 'stderr') {
      termAppend(event.data, 't-stderr');
    } else if (event.type === 'exit') {
      const ok = event.data.code === 0;
      const exitMsg = `\n[exit ${event.data.code}] ${ok ? '✓ Done' : '✗ Failed'}`;
      termAppend(exitMsg, ok ? 't-ok' : 't-fail');
      document.getElementById('terminal-status').textContent =
        `${label} — ${ok ? 'succeeded' : 'failed'} (exit ${event.data.code})`;
      showToast(`${label.slice(0, 40)} — ${ok ? 'Done ✓' : 'Failed ✗'}`, ok ? 'success' : 'error');
      es.close();

      const cb = jobCallbacks.get(jobId);
      if (cb) { jobCallbacks.delete(jobId); setTimeout(cb, 300); }
    }
  };

  es.onerror = () => {
    termAppend('\n[stream closed]\n', 't-info');
    es.close();
  };
}

// ── Terminal ──────────────────────────────────────────────────────────────────
function setupTerminal() {
  const panel   = document.getElementById('terminal-panel');
  const toggle  = document.getElementById('terminal-toggle-btn');
  const header  = document.getElementById('terminal-toggle-area');
  const clearBtn = document.getElementById('terminal-clear');

  header.addEventListener('click', e => {
    if (e.target === clearBtn) return; // clear button has its own handler
    isTermOpen = !isTermOpen;
    panel.classList.toggle('collapsed', !isTermOpen);
    toggle.textContent = isTermOpen ? '▼' : '▲';
  });

  clearBtn.addEventListener('click', e => {
    e.stopPropagation();
    document.getElementById('terminal-body').innerHTML = '';
    document.getElementById('terminal-status').textContent = '';
  });
}

function termOpen(label) {
  document.getElementById('terminal-job-name').textContent = `— ${label}`;
  const panel = document.getElementById('terminal-panel');
  isTermOpen = true;
  panel.classList.remove('collapsed');
  document.getElementById('terminal-toggle-btn').textContent = '▼';
}

function termAppend(text, cls = 't-stdout') {
  const body = document.getElementById('terminal-body');
  const span = document.createElement('span');
  span.className = cls;
  span.textContent = text;
  body.appendChild(span);
  body.scrollTop = body.scrollHeight;
}

// ── Tabs ──────────────────────────────────────────────────────────────────────
function setupTabs() {
  document.querySelectorAll('.tab').forEach(tab => {
    tab.addEventListener('click', () => {
      document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(s => s.classList.remove('active'));
      tab.classList.add('active');
      document.getElementById(`tab-${tab.dataset.tab}`).classList.add('active');

      if (tab.dataset.tab === 'backups') loadBackups();
      if (tab.dataset.tab === 'prereqs') loadPrereqs();
    });
  });
}

// ── Toolbar buttons ───────────────────────────────────────────────────────────
function setupButtons() {
  document.getElementById('refresh-btn').addEventListener('click', loadPackages);
  document.getElementById('select-all').addEventListener('change',  toggleSelectAll);
  document.getElementById('btn-dry-run').addEventListener('click',  doDryRun);
  document.getElementById('btn-backup').addEventListener('click',   doBackup);
  document.getElementById('btn-stow').addEventListener('click',     doInstall);
  document.getElementById('btn-unstow').addEventListener('click',   doUnstow);

  // Modal keyboard / backdrop dismissal
  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeModal(); });
  document.getElementById('modal').addEventListener('click', e => {
    if (e.target === e.currentTarget) closeModal();
  });
}

// ── Modal ─────────────────────────────────────────────────────────────────────

function showModal(title, message, actions = []) {
  document.getElementById('modal-title').textContent = title;
  document.getElementById('modal-msg').textContent   = message;

  const actionsEl = document.getElementById('modal-actions');
  actionsEl.innerHTML = '';
  for (const a of actions) {
    const btn = document.createElement('button');
    btn.className = `btn btn-sm ${a.cls}`;
    btn.textContent = a.label;
    btn.addEventListener('click', () => { closeModal(); if (a.fn) a.fn(); });
    actionsEl.appendChild(btn);
  }

  document.getElementById('modal').classList.remove('hidden');
}

function closeModal() {
  document.getElementById('modal').classList.add('hidden');
}

// ── Toast ─────────────────────────────────────────────────────────────────────
function showToast(message, type = 'info') {
  const container = document.getElementById('toasts');
  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.textContent = message;
  container.appendChild(toast);
  setTimeout(() => {
    toast.style.animation = 'fadeOut .3s ease forwards';
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

// ── API helper ────────────────────────────────────────────────────────────────
async function api(url, method = 'GET', body = null) {
  const res = await fetch(url, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : {},
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || res.statusText);
  }
  return res.json();
}

// ── DOM helper ────────────────────────────────────────────────────────────────
function el(tag, className, attrs = {}) {
  const e = document.createElement(tag);
  if (className) e.className = className;
  for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v);
  return e;
}
