function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup{
  defaults = {
    file_ignore_patterns = {"node_modules", ".git", "out", "build"},
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  }
}
