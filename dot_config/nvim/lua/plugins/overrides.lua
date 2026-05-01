---@type LazySpec
return {
  -- Add OceanicNext colorscheme
  {
    "mhartington/oceanic-next",
    priority = 1000,
  },
  -- customize dashboard options
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        dotfiles = false, -- Show hidden files (like NERDTreeShowHidden=1)
      },
      renderer = {
        highlight_opened_files = "name", -- NERDTreeHighlightCursorline=1
      },
      actions = {
        open_file = {
          quit_on_open = false, -- Don't close tree when opening file
        },
      },
      view = {
        side = "left",
        width = 30,
      },
      on_attach = function(bufnr)
        local api = require('nvim-tree.api')
        
        -- Default mappings
        api.config.mappings.default_on_attach(bufnr)
        
        -- Add custom tab mapping for window switching
        vim.keymap.set('n', '<Tab>', '<C-w><C-w>', { 
          buffer = bufnr, 
          noremap = true, 
          silent = true, 
          desc = 'Switch to next window' 
        })
      end,
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
