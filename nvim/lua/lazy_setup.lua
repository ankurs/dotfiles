require("lazy").setup({
  {
    "AstroNvim/AstroNvim",
    version = "^5", -- Remove version tracking to elect for nightly AstroNvim
    import = "astronvim.plugins",
    opts = { -- AstroNvim options must be set here with the `import` key
      mapleader = "\\", -- This ensures the leader key must be configured before Lazy is set up
      maplocalleader = ",", -- This ensures the localleader key must be configured before Lazy is set up
      icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
      pin_plugins = nil, -- Default will pin plugins when tracking `version` of AstroNvim, set to true/false to override
      update_notifications = true, -- Enable/disable notification about running `:Lazy update` twice to update pinned plugins
    },
  },
  { import = "community" },
  { import = "plugins" },
} --[[@as LazySpec]], {
  -- Configure any other `lazy.nvim` configuration options here
  install = { colorscheme =  { "astrotheme", "habamax", "OceanicNext" } },
  ui = { backdrop = 100 },
  rocks = {
    enabled = true,
    hererocks = true,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins for faster startup
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "zipPlugin",
        "matchit",
        "matchparen",
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "logipat",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
      },
    },
  },
} --[[@as LazyConfig]])
