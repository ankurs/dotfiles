-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      --cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = false, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- sets vim.opt.wrap
        cursorline = true, -- sets vim.opt.cursorline
        clipboard = "unnamedplus", -- sets vim.opt.clipboard
        expandtab = true, -- sets vim.opt.expandtab
        shiftwidth = 4, -- sets vim.opt.shiftwidth
        tabstop = 4, -- sets vim.opt.tabstop
        smartindent = true, -- sets vim.opt.smartindent
        autoindent = true, -- sets vim.opt.autoindent
        hidden = true, -- sets vim.opt.hidden
        ignorecase = true, -- sets vim.opt.ignorecase
        smartcase = true, -- sets vim.opt.smartcase
        incsearch = true, -- sets vim.opt.incsearch
        showmode = false, -- sets vim.opt.showmode
        showcmd = true, -- sets vim.opt.showcmd
        laststatus = 2, -- sets vim.opt.laststatus
        --background = "dark", -- sets vim.opt.background
        termguicolors = true, -- sets vim.opt.termguicolors
        list = true, -- sets vim.opt.list
        scrolloff = 8, -- sets vim.opt.scrolloff
        sidescrolloff = 8, -- sets vim.opt.sidescrolloff
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        --vim.keymap.set("n", "<tab>", "<c-w><c-w>")
        -- vim.keymap.set("n", "<leader><leader>", "<C-^>")
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        ["<Tab>"] = { "<C-w><C-w>", desc = "Switch between windows" },
        ["<Leader><Leader>"] = { "<C-^>", desc = "switch between last two buffers" },
        ["<Leader>e"] = { "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" },
        ["<Leader>rt"] = { "<cmd>AerialToggle<cr>", desc = "Toggle symbols outline" },
        ["<Leader>k"] = { "<Cmd>FzfLua grep_cword<CR>", desc = "Search for word under cursor" },
        ["t"] = { function() require("fzf-lua").files() end, desc = "Search Git files" },
        ["T"] = { function() require("fzf-lua").files({ cmd = "find . -type f" }) end, desc = "Search ALL files (including gitignored)" },

        ["<Leader>fg"] = { "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
        ["<Leader>tt"] = { "<cmd>Neotest run<CR>", desc = "Run test nearest" },
        ["<Leader>tf"] = { "<cmd>Neotest run file<CR>", desc = "Run test file" },
        ["<Leader>ts"] = { "<cmd>Neotest summary<CR>", desc = "Test summary" },
        ["<Leader>to"] = { "<cmd>Neotest output-panel<CR>", desc = "Test output" },
        ["<Leader>tr"] = { "<cmd>Neotest run<CR>", desc = "Run test" },
        ["<Leader>tS"] = { "<cmd>Neotest stop<CR>", desc = "Stop test" },

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- coverage
        ["<Leader>cc"] = { "<cmd>CoverageToggle<cr>", desc = "Toggle coverage" },
        ["<Leader>cs"] = { "<cmd>CoverageSummary<cr>", desc = "Show coverage summary" },
        ["<Leader>cl"] = { "<cmd>CoverageLoad<cr>", desc = "Load Coverage" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
      v = {
        ["<Leader>ca"] = { vim.lsp.buf.range_code_action, desc = "Code action" },
      },
    },
  },
}
