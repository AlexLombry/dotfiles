"use strict";
(() => {
  // src/client/app.ts
  var packages = [];
  var selectedPkgs = /* @__PURE__ */ new Set();
  var homeDir = "";
  var isTermOpen = false;
  var PKG_ICONS = {
    zsh: "\u{1F41A}",
    git: "\u{1F500}",
    config: "\u2699",
    apps: "\u{1F4E6}",
    work: "\u{1F4BC}"
  };
  document.addEventListener("DOMContentLoaded", async () => {
    setupTabs();
    setupTerminal();
    setupButtons();
    await loadInfo();
    loadPackages();
    loadActions();
  });
  async function api(url, method = "GET", body = null) {
    const init = body ? { method, headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) } : { method };
    const res = await fetch(url, init);
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: res.statusText }));
      throw new Error(err.error ?? res.statusText);
    }
    return res.json();
  }
  function el(tag, className, attrs = {}) {
    const e = document.createElement(tag);
    if (className) e.className = className;
    for (const [k, v] of Object.entries(attrs)) e.setAttribute(k, v);
    return e;
  }
  function getEl(id) {
    const e = document.getElementById(id);
    if (!e) throw new Error(`Missing element: #${id}`);
    return e;
  }
  async function loadInfo() {
    try {
      const info = await api("/api/info");
      homeDir = info.homeDir;
      getEl("dotfiles-path").textContent = info.dotfilesDir;
    } catch (e) {
      console.error("loadInfo:", e);
    }
  }
  async function loadPackages() {
    getEl("packages-grid").innerHTML = '<div class="loading">Scanning packages\u2026</div>';
    try {
      packages = await api("/api/packages");
      renderPackages();
      updateStatusPills();
      updateSetupBanner();
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Unknown error";
      getEl("packages-grid").innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
    }
  }
  function renderPackages() {
    const grid = getEl("packages-grid");
    grid.innerHTML = "";
    for (const pkg of packages) grid.appendChild(makePackageCard(pkg));
  }
  function makePackageCard(pkg) {
    const linked = pkg.files.filter((f) => f.status === "linked").length;
    const missing = pkg.files.filter((f) => f.status === "missing").length;
    const conflict = pkg.files.filter((f) => f.status === "conflict").length;
    const broken = pkg.files.filter((f) => f.status === "broken").length;
    const sel = selectedPkgs.has(pkg.name);
    const card = el("div", `pkg-card${sel ? " selected" : ""}`, { "data-pkg": pkg.name });
    const statsHtml = [
      linked > 0 ? `<span class="stat stat-linked">${linked} linked</span>` : "",
      missing > 0 ? `<span class="stat stat-missing">${missing} missing</span>` : "",
      conflict > 0 ? `<span class="stat stat-conflict">${conflict} conflict</span>` : "",
      broken > 0 ? `<span class="stat stat-broken">${broken} broken</span>` : ""
    ].join("") || `<span class="stat" style="color:var(--overlay0)">${pkg.files.length} files</span>`;
    const filesHtml = pkg.files.map((f) => {
      const destDisplay = homeDir ? f.dest.replace(homeDir, "~") : f.dest;
      return `<div class="file-row">
      <span class="status-dot dot-${f.status}" title="${f.status}"></span>
      <span class="file-rel">${f.rel}</span>
      <span class="file-dest" title="${f.dest}">${destDisplay}</span>
    </div>`;
    }).join("");
    card.innerHTML = `
    <div class="pkg-header">
      <input type="checkbox" class="pkg-cb" ${sel ? "checked" : ""} title="Select ${pkg.name}">
      <span class="pkg-icon">${PKG_ICONS[pkg.name] ?? "\u{1F4C4}"}</span>
      <span class="pkg-name">${pkg.name}</span>
      <div class="pkg-stats">${statsHtml}</div>
      <button class="pkg-expand" title="Show files">\u25BC</button>
    </div>
    <div class="pkg-files">${filesHtml || '<div class="loading">Empty package</div>'}</div>
  `;
    const cb = card.querySelector(".pkg-cb");
    const expand = card.querySelector(".pkg-expand");
    const fileList = card.querySelector(".pkg-files");
    cb.addEventListener("change", (e) => {
      e.stopPropagation();
      const checked = e.target.checked;
      checked ? selectedPkgs.add(pkg.name) : selectedPkgs.delete(pkg.name);
      card.classList.toggle("selected", checked);
      syncSelectAll();
    });
    expand.addEventListener("click", (e) => {
      e.stopPropagation();
      const open = fileList.classList.toggle("open");
      expand.textContent = open ? "\u25B2" : "\u25BC";
    });
    return card;
  }
  function updateStatusPills() {
    let linked = 0, missing = 0, conflict = 0;
    for (const pkg of packages) {
      for (const f of pkg.files) {
        if (f.status === "linked") linked++;
        else if (f.status === "missing") missing++;
        else conflict++;
      }
    }
    getEl("pill-linked").textContent = `${linked} linked`;
    getEl("pill-missing").textContent = `${missing} missing`;
    getEl("pill-conflict").textContent = `${conflict} conflicts`;
  }
  function updateSetupBanner() {
    const total = packages.reduce((s, p) => s + p.files.length, 0);
    const missing = packages.reduce((s, p) => s + p.files.filter((f) => f.status === "missing").length, 0);
    getEl("setup-banner").classList.toggle("hidden", missing < total * 0.4 || total === 0);
  }
  function toggleSelectAll(e) {
    const checked = e.target.checked;
    packages.forEach((p) => checked ? selectedPkgs.add(p.name) : selectedPkgs.delete(p.name));
    renderPackages();
  }
  function syncSelectAll() {
    getEl("select-all").checked = packages.length > 0 && packages.every((p) => selectedPkgs.has(p.name));
  }
  function getEffectivePkgs() {
    return selectedPkgs.size > 0 ? [...selectedPkgs] : packages.map((p) => p.name);
  }
  async function doDryRun() {
    const pkgs = getEffectivePkgs();
    const { jobId } = await api("/api/stow", "POST", { packages: pkgs, mode: "dry-run" });
    streamJob(jobId, `stow --dry-run [${pkgs.join(", ")}]`);
  }
  async function doBackup() {
    const pkgs = getEffectivePkgs();
    const conflicts = packages.filter((p) => pkgs.includes(p.name)).flatMap((p) => p.files).filter((f) => f.status === "conflict");
    if (conflicts.length === 0) {
      showToast("No conflicting files found.", "info");
      return;
    }
    const { jobId } = await api("/api/backup", "POST", { packages: pkgs });
    streamJob(jobId, `backup [${pkgs.join(", ")}]`);
    afterJob(jobId, loadPackages);
  }
  async function doInstall() {
    const pkgs = getEffectivePkgs();
    const conflicts = packages.filter((p) => pkgs.includes(p.name)).flatMap((p) => p.files).filter((f) => f.status === "conflict");
    if (conflicts.length > 0) {
      showModal("Conflicts Detected", `${conflicts.length} existing file(s) will block the installation. Choose how to proceed:`, [
        { label: "Cancel", cls: "btn-ghost", fn: null },
        { label: "Backup & Install", cls: "btn-success", fn: () => {
          void doBackupAndStow(pkgs);
        } },
        { label: "Stow Anyway", cls: "btn-warning", fn: () => {
          void stowPkgs(pkgs);
        } }
      ]);
    } else {
      void stowPkgs(pkgs);
    }
  }
  async function stowPkgs(pkgs) {
    const { jobId } = await api("/api/stow", "POST", { packages: pkgs, mode: "stow" });
    streamJob(jobId, `stow [${pkgs.join(", ")}]`);
    afterJob(jobId, loadPackages);
  }
  async function doBackupAndStow(pkgs) {
    const { jobId } = await api("/api/backup/and-stow", "POST", { packages: pkgs });
    streamJob(jobId, `backup+stow [${pkgs.join(", ")}]`);
    afterJob(jobId, loadPackages);
  }
  async function doUnstow() {
    const pkgs = getEffectivePkgs();
    showModal("Remove Symlinks", `Remove all managed symlinks for: ${pkgs.join(", ")}.

Your dotfiles repo will NOT be modified.`, [
      { label: "Cancel", cls: "btn-ghost", fn: null },
      { label: "Remove", cls: "btn-danger", fn: async () => {
        const { jobId } = await api("/api/stow", "POST", { packages: pkgs, mode: "unstow" });
        streamJob(jobId, `unstow [${pkgs.join(", ")}]`);
        afterJob(jobId, loadPackages);
      } }
    ]);
  }
  async function loadActions() {
    try {
      const cmds = await api("/api/commands");
      renderActions(cmds);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Unknown error";
      getEl("actions-grid").innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
    }
  }
  function renderActions(cmds) {
    const grid = getEl("actions-grid");
    grid.innerHTML = "";
    for (const cmd of cmds) {
      const card = el("div", "action-card");
      card.innerHTML = `
      <div class="action-card-header">
        <span class="action-cmd">just ${cmd.cmd}</span>
        <span class="badge ${cmd.safe ? "badge-safe" : "badge-caution"}">${cmd.safe ? "\u2713 safe" : "\u26A0 changes system"}</span>
      </div>
      <div class="action-label">${cmd.label}</div>
      <div class="action-desc">${cmd.desc}</div>
    `;
      card.addEventListener("click", () => triggerAction(cmd));
      grid.appendChild(card);
    }
  }
  function triggerAction(cmd) {
    if (!cmd.safe) {
      showModal(`Run: just ${cmd.cmd}`, `${cmd.label}

${cmd.desc}`, [
        { label: "Cancel", cls: "btn-ghost", fn: null },
        { label: "Run", cls: "btn-warning", fn: () => {
          void executeAction(cmd.cmd);
        } }
      ]);
    } else {
      void executeAction(cmd.cmd);
    }
  }
  async function executeAction(command) {
    try {
      const { jobId } = await api("/api/run", "POST", { command });
      streamJob(jobId, `just ${command}`);
      if (["stow", "stow-fresh", "unstow", "setup"].includes(command)) {
        afterJob(jobId, loadPackages);
      }
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Unknown error";
      showToast(`Error: ${msg}`, "error");
    }
  }
  async function loadBackups() {
    const container = getEl("backups-list");
    container.innerHTML = '<div class="loading">Loading\u2026</div>';
    try {
      const list = await api("/api/backups");
      if (list.length === 0) {
        container.innerHTML = '<div class="loading">No backups found. Backups are created automatically when conflicting files are moved.</div>';
        return;
      }
      const wrap = document.createElement("div");
      wrap.className = "backup-list";
      for (const b of list) {
        const row = document.createElement("div");
        row.className = "backup-row";
        row.innerHTML = `
        <div style="flex:1">
          <div class="backup-name">${b.name}</div>
          <div class="backup-count">${b.fileCount} file(s)</div>
        </div>
        <button class="btn btn-secondary btn-sm" data-backup="${b.name}">\u21A9 Rollback</button>
      `;
        row.querySelector("button").addEventListener("click", () => triggerRollback(b.name));
        wrap.appendChild(row);
      }
      container.innerHTML = "";
      container.appendChild(wrap);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Unknown error";
      container.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
    }
  }
  function triggerRollback(name) {
    showModal("Rollback Backup", `Restore files from backup "${name}"?

This will remove any symlinks at those paths and copy the original files back.`, [
      { label: "Cancel", cls: "btn-ghost", fn: null },
      { label: "Rollback", cls: "btn-danger", fn: async () => {
        const { jobId } = await api(`/api/backups/${encodeURIComponent(name)}/rollback`, "POST");
        streamJob(jobId, `rollback ${name}`);
        afterJob(jobId, () => {
          void loadPackages();
          void loadBackups();
        });
      } }
    ]);
  }
  async function loadPrereqs() {
    const container = getEl("prereqs-list");
    container.innerHTML = '<div class="loading">Checking prerequisites\u2026</div>';
    try {
      const results = await api("/api/prerequisites");
      const list = document.createElement("div");
      list.className = "prereq-list";
      for (const r of results) {
        const row = document.createElement("div");
        row.className = "prereq-row";
        row.innerHTML = `
        <span class="prereq-icon">${r.ok ? "\u2705" : "\u274C"}</span>
        <span class="prereq-name">${r.name}</span>
        <span class="prereq-version">${r.version || "not found"}</span>
      `;
        list.appendChild(row);
      }
      container.innerHTML = "";
      container.appendChild(list);
    } catch (e) {
      const msg = e instanceof Error ? e.message : "Unknown error";
      container.innerHTML = `<div class="loading" style="color:var(--red)">Error: ${msg}</div>`;
    }
  }
  var jobCallbacks = /* @__PURE__ */ new Map();
  function afterJob(jobId, fn) {
    jobCallbacks.set(jobId, fn);
  }
  function streamJob(jobId, label) {
    termOpen(label);
    termAppend(`$ ${label}
`, "t-info");
    const es = new EventSource(`/api/jobs/${jobId}/stream`);
    es.onmessage = (ev) => {
      const event = JSON.parse(ev.data);
      if (event.type === "stdout") {
        termAppend(event.data, "t-stdout");
      } else if (event.type === "stderr") {
        termAppend(event.data, "t-stderr");
      } else if (event.type === "exit") {
        const ok = event.data.code === 0;
        termAppend(`
[exit ${event.data.code}] ${ok ? "\u2713 Done" : "\u2717 Failed"}`, ok ? "t-ok" : "t-fail");
        getEl("terminal-status").textContent = `${label} \u2014 ${ok ? "succeeded" : "failed"} (exit ${event.data.code})`;
        showToast(`${label.slice(0, 40)} \u2014 ${ok ? "Done \u2713" : "Failed \u2717"}`, ok ? "success" : "error");
        es.close();
        const cb = jobCallbacks.get(jobId);
        if (cb) {
          jobCallbacks.delete(jobId);
          setTimeout(() => {
            void cb();
          }, 300);
        }
      }
    };
    es.onerror = () => {
      termAppend("\n[stream closed]\n", "t-info");
      es.close();
    };
  }
  function setupTerminal() {
    const panel = getEl("terminal-panel");
    const toggle = getEl("terminal-toggle-btn");
    const header = getEl("terminal-toggle-area");
    const clearBtn = getEl("terminal-clear");
    header.addEventListener("click", (e) => {
      if (e.target === clearBtn) return;
      isTermOpen = !isTermOpen;
      panel.classList.toggle("collapsed", !isTermOpen);
      toggle.textContent = isTermOpen ? "\u25BC" : "\u25B2";
    });
    clearBtn.addEventListener("click", (e) => {
      e.stopPropagation();
      getEl("terminal-body").innerHTML = "";
      getEl("terminal-status").textContent = "";
    });
  }
  function termOpen(label) {
    getEl("terminal-job-name").textContent = `\u2014 ${label}`;
    isTermOpen = true;
    getEl("terminal-panel").classList.remove("collapsed");
    getEl("terminal-toggle-btn").textContent = "\u25BC";
  }
  function termAppend(text, cls = "t-stdout") {
    const body = getEl("terminal-body");
    const span = document.createElement("span");
    span.className = cls;
    span.textContent = text;
    body.appendChild(span);
    body.scrollTop = body.scrollHeight;
  }
  function setupTabs() {
    document.querySelectorAll(".tab").forEach((tab) => {
      tab.addEventListener("click", () => {
        document.querySelectorAll(".tab").forEach((t) => t.classList.remove("active"));
        document.querySelectorAll(".tab-content").forEach((s) => s.classList.remove("active"));
        tab.classList.add("active");
        const tabName = tab.dataset["tab"];
        if (tabName) {
          document.getElementById(`tab-${tabName}`)?.classList.add("active");
          if (tabName === "backups") void loadBackups();
          if (tabName === "prereqs") void loadPrereqs();
        }
      });
    });
  }
  function setupButtons() {
    getEl("refresh-btn").addEventListener("click", () => {
      void loadPackages();
    });
    getEl("select-all").addEventListener("change", toggleSelectAll);
    getEl("btn-dry-run").addEventListener("click", () => {
      void doDryRun();
    });
    getEl("btn-backup").addEventListener("click", () => {
      void doBackup();
    });
    getEl("btn-stow").addEventListener("click", () => {
      void doInstall();
    });
    getEl("btn-unstow").addEventListener("click", () => {
      void doUnstow();
    });
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") closeModal();
    });
    getEl("modal").addEventListener("click", (e) => {
      if (e.target === e.currentTarget) closeModal();
    });
  }
  function showModal(title, message, actions = []) {
    getEl("modal-title").textContent = title;
    getEl("modal-msg").textContent = message;
    const actionsEl = getEl("modal-actions");
    actionsEl.innerHTML = "";
    for (const a of actions) {
      const btn = document.createElement("button");
      btn.className = `btn btn-sm ${a.cls}`;
      btn.textContent = a.label;
      btn.addEventListener("click", () => {
        closeModal();
        if (a.fn) void a.fn();
      });
      actionsEl.appendChild(btn);
    }
    getEl("modal").classList.remove("hidden");
  }
  function closeModal() {
    getEl("modal").classList.add("hidden");
  }
  function showToast(message, type = "info") {
    const container = getEl("toasts");
    const toast = document.createElement("div");
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => {
      toast.style.animation = "fadeOut .3s ease forwards";
      setTimeout(() => toast.remove(), 300);
    }, 4e3);
  }
})();
