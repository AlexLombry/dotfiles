return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },
    opts = {
        keymap = {
            preset = "default",
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        },
        appearance = {
            nerd_font_variant = "mono",
        },
        completion = {
            accept = { auto_brackets = { enabled = true } },
            documentation = { auto_show = true, auto_show_delay_ms = 200 },
            menu = {
                draw = {
                    treesitter = { "lsp" },
                },
            },
        },
        sources = {
            default = { "lsp", "path", "snippets", "buffer" },
        },
        signature = { enabled = true },
    },
}
