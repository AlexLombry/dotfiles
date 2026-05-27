return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        -- install parsers you want
        -- require("nvim-treesitter").setup({ "lua", "vim", "vimdoc", "javascript" })
        require("nvim-treesitter.configs").setup({
            ensure_installed = {
                "lua", "vim", "vimdoc", "bash",
                "javascript", "typescript", "tsx",
                "svelte", "html", "css", "scss",
                "json", "yaml", "toml",
                "markdown", "markdown_inline",
                "graphql", "python", "prisma",
            },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}
