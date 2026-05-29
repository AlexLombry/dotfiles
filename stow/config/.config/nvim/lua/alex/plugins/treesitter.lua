return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            install_dir = vim.fn.stdpath("data") .. "/site",
        })

        require("nvim-treesitter").install({
            "lua", "vim", "vimdoc", "bash",
            "javascript", "typescript", "tsx",
            "svelte", "html", "css", "scss",
            "json", "yaml", "toml",
            "markdown", "markdown_inline",
            "graphql", "python", "prisma",
        })

        vim.api.nvim_create_autocmd("FileType", {
            callback = function()
                local ok = pcall(vim.treesitter.start)
                if ok then
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
