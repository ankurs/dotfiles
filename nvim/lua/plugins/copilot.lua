return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "BufReadPost",
  opts = {
    panel = {
      enabled = true,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
    },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      keymap = {
        accept = "<C-J>", -- handled by completion engine
        next = "<C-l>",
        prev = "<C-k>",
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        options = {
          g = {
            -- set the ai_accept function
            ai_accept = function()
              if require("copilot.suggestion").is_visible() then
                require("copilot.suggestion").accept()
                return true
              end
            end,
          },
        },
      },
    },
  },
}
