return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        notifier = { enabled = true, timeout = 3000 },
        indent = {
            enabled = true,
            indent = { char = "┊" },
        },
        statuscolumn = { enabled = true },
        dashboard = {
            preset = {
                header = [[

  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
                                                     ]],
                keys = {
                    { icon = " ", key = "e", desc = "New File", action = "<cmd>ene<CR>" },
                    { icon = " ", key = "t", desc = "Toggle File Explorer", action = "<cmd>NvimTreeToggle<CR>" },
                    { icon = "󰱼 ", key = "f", desc = "Find File", action = "<cmd>Telescope find_files<CR>" },
                    { icon = " ", key = "s", desc = "Find Word", action = "<cmd>Telescope live_grep<CR>" },
                    { icon = "󰁯 ", key = "r", desc = "Restore Session", action = "<cmd>SessionRestore<CR>" },
                    { icon = " ", key = "q", desc = "Quit NVIM", action = "<cmd>qa<CR>" },
                },
            },
            sections = {
                { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { section = "startup" },
            },
        },
        lazygit = { enabled = true },
    },
    keys = {
        { "<leader>lg", function() Snacks.lazygit() end,           desc = "LazyGit" },
        { "<leader>gl", function() Snacks.lazygit.log() end,       desc = "LazyGit Log" },
        { "<leader>gf", function() Snacks.lazygit.log_file() end,  desc = "LazyGit Log File" },
    },
}
