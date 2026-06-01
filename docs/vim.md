# Neovim Keymaps

Leader key: `,`

## LSP

| Key | Action |
|---|---|
| `gR` | Show references (Telescope) |
| `gD` | Go to declaration |
| `gd` | Show definitions (Telescope) |
| `gi` | Show implementations (Telescope) |
| `gt` | Show type definitions (Telescope) |
| `<leader>ca` | Code actions |
| `<leader>rn` | Rename symbol |
| `<leader>D` | Buffer diagnostics (Telescope) |
| `<leader>d` | Line diagnostics (float) |
| `[d` / `]d` | Previous / next diagnostic |
| `K` | Hover documentation |
| `<leader>rs` | Restart LSP |

## Completion (blink.cmp)

| Key | Action |
|---|---|
| `<C-Space>` | Show completions |
| `<C-e>` | Close completion |
| `<CR>` | Accept |
| `<C-k>` / `<C-j>` | Previous / next item |
| `<Tab>` / `<S-Tab>` | Next / previous item + snippet jump |
| `<C-b>` / `<C-f>` | Scroll documentation |

Signature help shows automatically when typing function arguments.

## Git (snacks.nvim)

| Key | Action |
|---|---|
| `<leader>lg` | Open LazyGit |
| `<leader>gl` | LazyGit repo log |
| `<leader>gf` | LazyGit log for current file |

## Dashboard

Keys active on the start screen:

| Key | Action |
|---|---|
| `e` | New file |
| `t` | Toggle file explorer |
| `f` | Find file |
| `s` | Find word |
| `r` | Restore session |
| `q` | Quit |

## Telescope

| Key | Action |
|---|---|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fs` | Live grep |
| `<leader>fc` | Find word under cursor |
| `<leader>ft` | Find todos |

## File Explorer (nvim-tree)

| Key | Action |
|---|---|
| `<leader>ee` | Toggle explorer |
| `<leader>ef` | Focus current file in explorer |
| `<leader>ec` | Collapse explorer |
| `<leader>er` | Refresh explorer |

## Window Management

| Key | Action |
|---|---|
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<leader>se` | Equalize splits |
| `<leader>sx` | Close split |
| `<leader>sm` | Toggle maximize |

## Tabs

| Key | Action |
|---|---|
| `<leader>to` | New tab |
| `<leader>tx` | Close tab |
| `<leader>tn` / `<leader>tp` | Next / previous tab |
| `<leader>tf` | Open buffer in new tab |

## Troubleshooting

### `tree-sitter` not found when installing parsers

**Error:**
```
[nvim-treesitter/install/typescript] error: Error during "tree-sitter build":
ENOENT: no such file or directory (cmd): 'tree-sitter'
```

**Cause:** nvim-treesitter v1 compiles parsers using the `tree-sitter` CLI. The
Homebrew `tree-sitter` formula is the C library only — it does not ship the CLI
binary. The CLI must be installed separately via npm.

**Fix:**
```bash
npm install -g tree-sitter-cli
```

mise reshims automatically after install, so the binary is immediately available
as `~/.local/share/mise/shims/tree-sitter`. Re-open Neovim and run `:TSUpdate`
to rebuild any failed parsers.

**Note:** if you switch Node versions in mise, re-run the command above — the
global npm package is tied to the active Node version.
