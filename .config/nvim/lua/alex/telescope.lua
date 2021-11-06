function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')

telescope.setup{
  defaults = {
    pickers = {
      find_files = {
        hidden = true
      },
    },
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
  }
}
