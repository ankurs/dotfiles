---@type LazySpec
return {
  -- customize dashboard options
  {
    -- tagbar
    "preservim/tagbar",
  },
  {
    "flazz/vim-colorschemes",
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
      open_files_do_not_replace_types = { "terminal", "trouble", "qf", "aerial", "neotest-summary" }, -- when opening files, do not use windows containing these filetypes or buftypes
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
      require("coverage").setup {
        auto_reload = true,
        commands = true,
        highlights = {
          -- customize highlight groups created by the plugin
          covered = { fg = "#AAEE00" }, -- supports style, fg, bg, sp (see :h highlight-gui)
          uncovered = { fg = "#FF0000" },
        },
        signs = {
          -- use your own highlight groups or text markers
          covered = { hl = "CoverageCovered", text = "⎷" },
          uncovered = { hl = "CoverageUncovered", text = "x" },
        },
        lang = {
          go = {
            coverage_file = "cover.out",
          },
        },
      }
    end,
  },
}
