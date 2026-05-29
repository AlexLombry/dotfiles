return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  event = "VeryLazy",
  config = function()
    require("nvim-treesitter-textobjects").setup({
      select = { lookahead = true },
      move = { set_jumps = true },
    })

    local select = require("nvim-treesitter-textobjects.select")
    local swap = require("nvim-treesitter-textobjects.swap")
    local move = require("nvim-treesitter-textobjects.move")

    local select_maps = {
      ["a="] = "@assignment.outer",
      ["i="] = "@assignment.inner",
      ["l="] = "@assignment.lhs",
      ["r="] = "@assignment.rhs",
      ["a:"] = "@property.outer",
      ["i:"] = "@property.inner",
      ["l:"] = "@property.lhs",
      ["r:"] = "@property.rhs",
      ["aa"] = "@parameter.outer",
      ["ia"] = "@parameter.inner",
      ["ai"] = "@conditional.outer",
      ["ii"] = "@conditional.inner",
      ["al"] = "@loop.outer",
      ["il"] = "@loop.inner",
      ["af"] = "@call.outer",
      ["if"] = "@call.inner",
      ["am"] = "@function.outer",
      ["im"] = "@function.inner",
      ["ac"] = "@class.outer",
      ["ic"] = "@class.inner",
    }
    for key, query in pairs(select_maps) do
      vim.keymap.set({ "x", "o" }, key, function()
        select.select_textobject(query, "textobjects")
      end)
    end

    vim.keymap.set("n", "<leader>na", function() swap.swap_next("@parameter.inner") end)
    vim.keymap.set("n", "<leader>n:", function() swap.swap_next("@property.outer") end)
    vim.keymap.set("n", "<leader>nm", function() swap.swap_next("@function.outer") end)
    vim.keymap.set("n", "<leader>pa", function() swap.swap_previous("@parameter.inner") end)
    vim.keymap.set("n", "<leader>p:", function() swap.swap_previous("@property.outer") end)
    vim.keymap.set("n", "<leader>pm", function() swap.swap_previous("@function.outer") end)

    local next_start = {
      ["]f"] = "@call.outer",
      ["]m"] = "@function.outer",
      ["]c"] = "@class.outer",
      ["]i"] = "@conditional.outer",
      ["]l"] = "@loop.outer",
    }
    local next_end = {
      ["]F"] = "@call.outer",
      ["]M"] = "@function.outer",
      ["]C"] = "@class.outer",
      ["]I"] = "@conditional.outer",
      ["]L"] = "@loop.outer",
    }
    local prev_start = {
      ["[f"] = "@call.outer",
      ["[m"] = "@function.outer",
      ["[c"] = "@class.outer",
      ["[i"] = "@conditional.outer",
      ["[l"] = "@loop.outer",
    }
    local prev_end = {
      ["[F"] = "@call.outer",
      ["[M"] = "@function.outer",
      ["[C"] = "@class.outer",
      ["[I"] = "@conditional.outer",
      ["[L"] = "@loop.outer",
    }
    for key, query in pairs(next_start) do
      vim.keymap.set({ "n", "x", "o" }, key, function() move.goto_next_start(query, "textobjects") end)
    end
    for key, query in pairs(next_end) do
      vim.keymap.set({ "n", "x", "o" }, key, function() move.goto_next_end(query, "textobjects") end)
    end
    for key, query in pairs(prev_start) do
      vim.keymap.set({ "n", "x", "o" }, key, function() move.goto_previous_start(query, "textobjects") end)
    end
    for key, query in pairs(prev_end) do
      vim.keymap.set({ "n", "x", "o" }, key, function() move.goto_previous_end(query, "textobjects") end)
    end

    vim.keymap.set({ "n", "x", "o" }, "]s", function() move.goto_next_start("@scope", "locals") end)
    vim.keymap.set({ "n", "x", "o" }, "]z", function() move.goto_next_start("@fold", "folds") end)

    local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
    vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
    vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
    vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
  end,
}
