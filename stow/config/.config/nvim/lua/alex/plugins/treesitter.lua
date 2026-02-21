return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- install parsers you want
        require("nvim-treesitter").install({ "lua", "vim", "vimdoc", "javascript" })
    end,
}
