--local autocmd = vim.api.nvim_create_autocmd

-- settings for Markdown
local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.swapfile = false

opt.smartindent = true

opt.softtabstop = 4
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true

opt.wrap = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
opt.undofile = true

opt.incsearch = true
-- Auto resize panes when resizing nvim window
--autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
