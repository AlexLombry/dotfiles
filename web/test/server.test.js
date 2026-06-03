'use strict';

const { describe, test, before, after } = require('node:test');
const assert = require('node:assert/strict');
const fs     = require('node:fs');
const os     = require('node:os');
const path   = require('node:path');

const { shouldIgnore, isEffectivelyLinked, symlinkStatus, scanPackage } = require('../dist/server/index');

// ── shouldIgnore ──────────────────────────────────────────────────────────────

describe('shouldIgnore', () => {
  const IGNORED = [
    '.DS_Store', '.git', '.gitignore', '.gitmodules',
    '.svn', '_darcs', '.hg', 'CVS', 'RCS', '.cvsignore', 'COPYING',
    'file~',          // emacs backup
    '#autosave#',     // emacs autosave
    'README', 'README.md', 'README.txt',
    'LICENSE', 'LICENSE.txt', 'LICENSE.md',
  ];

  const KEPT = [
    '.zshrc', '.zprofile', '.gitconfig', '.gitignore_global',
    'init.lua', 'aliases.zsh', 'config.toml', '.tmux.conf',
    'README2', 'NOT_A_README', 'myLICENSE',
  ];

  for (const name of IGNORED) {
    test(`ignores "${name}"`, () =>
      assert.ok(shouldIgnore(name), `shouldIgnore('${name}') should be true`));
  }

  for (const name of KEPT) {
    test(`keeps "${name}"`, () =>
      assert.ok(!shouldIgnore(name), `shouldIgnore('${name}') should be false`));
  }
});

// ── isEffectivelyLinked ───────────────────────────────────────────────────────

describe('isEffectivelyLinked', () => {
  let tmp;
  before(() => { tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'dfl-eff-')); });
  after(() => { fs.rmSync(tmp, { recursive: true, force: true }); });

  test('returns false when no symlink exists at any level', () => {
    const src  = path.join(tmp, 'stow/zsh/.zshrc');
    const dest = path.join(tmp, 'home/.zshrc');
    assert.strictEqual(isEffectivelyLinked(src, dest), false);
  });

  test('returns true when direct parent dir is a stow tree-folding symlink', () => {
    const stowNvim = path.join(tmp, 'stow/config/.config/nvim');
    const homeConf = path.join(tmp, 'home1/.config');
    const homeNvim = path.join(homeConf, 'nvim');

    fs.mkdirSync(stowNvim, { recursive: true });
    fs.writeFileSync(path.join(stowNvim, 'init.lua'), 'return {}');
    fs.mkdirSync(homeConf, { recursive: true });
    fs.symlinkSync(stowNvim, homeNvim);

    const src  = path.join(stowNvim, 'init.lua');
    const dest = path.join(homeNvim, 'init.lua');
    assert.strictEqual(isEffectivelyLinked(src, dest), true);
  });

  test('returns true for a deeply nested file under a dir symlink', () => {
    const stowNvim = path.join(tmp, 'stow/config2/.config/nvim');
    const stowDeep = path.join(stowNvim, 'lua/plugins');
    const homeConf = path.join(tmp, 'home2/.config');
    const homeNvim = path.join(homeConf, 'nvim');

    fs.mkdirSync(stowDeep, { recursive: true });
    fs.writeFileSync(path.join(stowDeep, 'lsp.lua'), 'return {}');
    fs.mkdirSync(homeConf, { recursive: true });
    fs.symlinkSync(stowNvim, homeNvim);

    const src  = path.join(stowDeep, 'lsp.lua');
    const dest = path.join(homeNvim, 'lua/plugins/lsp.lua');
    assert.strictEqual(isEffectivelyLinked(src, dest), true);
  });

  test('returns false when parent dir symlink points to a different target', () => {
    const stowA = path.join(tmp, 'stow/pkgA/.config/app');
    const stowB = path.join(tmp, 'stow/pkgB/.config/app');
    const homeApp = path.join(tmp, 'home3/.config/app');

    fs.mkdirSync(stowA, { recursive: true });
    fs.mkdirSync(stowB, { recursive: true });
    fs.writeFileSync(path.join(stowA, 'config.toml'), '[a]');
    fs.writeFileSync(path.join(stowB, 'config.toml'), '[b]');
    fs.mkdirSync(path.dirname(homeApp), { recursive: true });
    fs.symlinkSync(stowB, homeApp); // points to B, but src is in A

    const src  = path.join(stowA, 'config.toml');
    const dest = path.join(homeApp, 'config.toml');
    assert.strictEqual(isEffectivelyLinked(src, dest), false);
  });
});

// ── symlinkStatus ─────────────────────────────────────────────────────────────

describe('symlinkStatus', () => {
  let tmp;
  before(() => { tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'dfl-sym-')); });
  after(() => { fs.rmSync(tmp, { recursive: true, force: true }); });

  test('returns "missing" when dest does not exist', () => {
    const src  = path.join(tmp, 'a/stow/zsh/.zshrc');
    const dest = path.join(tmp, 'a/home/.zshrc');
    fs.mkdirSync(path.dirname(src), { recursive: true });
    fs.writeFileSync(src, '# zsh');
    assert.strictEqual(symlinkStatus(src, dest), 'missing');
  });

  test('returns "linked" for a correct file-level symlink', () => {
    const src  = path.join(tmp, 'b/stow/zsh/.zshrc');
    const dest = path.join(tmp, 'b/home/.zshrc');
    fs.mkdirSync(path.dirname(src),  { recursive: true });
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(src, '# zsh');
    fs.symlinkSync(src, dest);
    assert.strictEqual(symlinkStatus(src, dest), 'linked');
  });

  test('returns "conflict" for a file-level symlink pointing elsewhere', () => {
    const src   = path.join(tmp, 'c/stow/zsh/.zshrc');
    const other = path.join(tmp, 'c/other/.zshrc');
    const dest  = path.join(tmp, 'c/home/.zshrc');
    fs.mkdirSync(path.dirname(src),   { recursive: true });
    fs.mkdirSync(path.dirname(other), { recursive: true });
    fs.mkdirSync(path.dirname(dest),  { recursive: true });
    fs.writeFileSync(src,   '# src');
    fs.writeFileSync(other, '# other');
    fs.symlinkSync(other, dest);
    assert.strictEqual(symlinkStatus(src, dest), 'conflict');
  });

  test('returns "conflict" for a real file at dest (not a symlink)', () => {
    const src  = path.join(tmp, 'd/stow/zsh/.zshrc');
    const dest = path.join(tmp, 'd/home/.zshrc');
    fs.mkdirSync(path.dirname(src),  { recursive: true });
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(src,  '# src');
    fs.writeFileSync(dest, '# real file');
    assert.strictEqual(symlinkStatus(src, dest), 'conflict');
  });

  test('returns "linked" when a parent dir is a stow tree-folding symlink', () => {
    const stowNvim = path.join(tmp, 'e/stow/config/.config/nvim');
    const homeConf = path.join(tmp, 'e/home/.config');
    const homeNvim = path.join(homeConf, 'nvim');
    fs.mkdirSync(stowNvim, { recursive: true });
    fs.writeFileSync(path.join(stowNvim, 'init.lua'), 'return {}');
    fs.mkdirSync(homeConf, { recursive: true });
    fs.symlinkSync(stowNvim, homeNvim);

    const src  = path.join(stowNvim, 'init.lua');
    const dest = path.join(homeNvim, 'init.lua');
    assert.strictEqual(symlinkStatus(src, dest), 'linked');
  });

  test('returns "conflict" for a dangling symlink (target path does not exist)', () => {
    const src  = path.join(tmp, 'f/stow/zsh/.zshrc');
    const dest = path.join(tmp, 'f/home/.zshrc');
    fs.mkdirSync(path.dirname(src),  { recursive: true });
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(src, '# zsh');
    fs.symlinkSync('/nonexistent/path/.zshrc', dest); // dangling
    assert.strictEqual(symlinkStatus(src, dest), 'conflict');
  });
});

// ── scanPackage ───────────────────────────────────────────────────────────────

describe('scanPackage', () => {
  test('returns error object for an unknown package name', () => {
    const result = scanPackage('__nonexistent__');
    assert.strictEqual(result.name, '__nonexistent__');
    assert.ok(result.error, 'should have an error field');
    assert.deepStrictEqual(result.files, []);
  });

  test('returns correct shape for the git package', () => {
    const result = scanPackage('git');
    assert.strictEqual(result.name, 'git');
    assert.ok(Array.isArray(result.files));
    assert.ok(result.files.length > 0, 'git package should have files');

    const VALID_STATUSES = new Set(['linked', 'missing', 'conflict', 'broken']);
    for (const f of result.files) {
      assert.ok('rel'    in f, 'file entry should have rel');
      assert.ok('src'    in f, 'file entry should have src');
      assert.ok('dest'   in f, 'file entry should have dest');
      assert.ok('status' in f, 'file entry should have status');
      assert.ok(VALID_STATUSES.has(f.status), `unexpected status: ${f.status}`);
    }
  });

  test('all git package files are linked (repo is fully stowed)', () => {
    const result = scanPackage('git');
    const unlinked = result.files.filter(f => f.status !== 'linked');
    assert.deepStrictEqual(unlinked, [], `Unlinked files: ${unlinked.map(f => f.rel).join(', ')}`);
  });

  test('ignores .DS_Store and .git files during scan', () => {
    const result = scanPackage('git');
    const ignored = result.files.filter(f => f.rel.includes('.DS_Store') || f.rel.includes('/.git/'));
    assert.deepStrictEqual(ignored, []);
  });
});
