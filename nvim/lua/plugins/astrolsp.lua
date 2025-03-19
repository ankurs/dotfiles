-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  version = false,
  branch = "v3",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
      virtual_text = true, -- enable/disable virtual text on start
      code_actions = true, -- enable/disable code actions on start
      code_lens = true, -- enable/disable code lens on start
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {},
    -- customize language server configuration options passed to `lspconfig`
    ---@diagnostic disable: missing-fields
    config = {
      -- clangd = { capabilities = { offsetEncoding = "utf-8" } },
      gopls = {
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
              shadow = true,
              nilness = true,
              unusedwrite = true,
              deadcode = true,
              unusedexports = false,
              nonewvars = true,
              nofieldsmismatch = true,
              novetshadow = true,
              unhandled = true,
              staticcheck = true,
              misspell = true,
            },
            codelenses = {
              generate = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              gc_details = true,
              fillstruct = true,
              add_dependency = true,
              trace = true,
              test_with_coverage = true,
              test_with_bench = true,
              test_with_examples = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              constantValues = true,
              methodSets = true,
              nilness = true,
              parameterTypes = true,
              receiverTypes = true,
              unparam = true,
              variableValues = true,
            },
            staticcheck = true, -- integrate Staticcheck for extra linting
            completeUnimported = true, -- auto-complete unimported packages
            usePlaceholders = true, -- use placeholders for function parameters
            matcher = "fuzzy", -- use fuzzy matching for completion
            symbolMatcher = "fuzzy", -- use fuzzy matching for symbols
            gofumpt = true, -- use gofumpt for formatting
          },
        },
      },
    },
    -- customize how language servers are attached
    handlers = {
      -- a function without a key is simply the default handler, functions take two parameters, the server name and the configured options table for that server
      -- function(server, opts) require("lspconfig")[server].setup(opts) end

      -- the key is the server that is being setup with `lspconfig`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
      -- pyright = function(_, opts) require("lspconfig").pyright.setup(opts) end -- or a custom handler function can be passed
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.refresh { bufnr = args.buf } end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        -- a `cond` key can provided as the string of a server capability to be required to attach, or a function with `client` and `bufnr` parameters from the `on_attach` that returns a boolean
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uY"] = {
          function() require("astrolsp.toggles").buffer_semantic_tokens() end,
          desc = "Toggle LSP semantic highlight (buffer)",
          cond = function(client)
            return client.supports_method "textDocument/semanticTokens/full" and vim.lsp.semantic_tokens ~= nil
          end,
        },
        --- LSP mappings
        ["K"] = {
          vim.lsp.buf.hover,
          cond = function(client) return client.server_capabilities.hoverProvider end,
          desc = "Hover Documentation",
        },
        ["<Leader>df"] = { vim.lsp.buf.definition, desc = "Go to definition" },
        ["<Leader>rn"] = { vim.lsp.buf.rename, desc = "Rename symbol" },
        ["<Leader>ca"] = { vim.lsp.buf.code_action, desc = "Code action" },
        ["<Leader>h"] = { vim.lsp.buf.hover, desc = "Hover" },
        ["<Leader>ds"] = { vim.lsp.buf.document_symbol, desc = "Document symbol" },
        ["<Leader>ws"] = { vim.lsp.buf.workspace_symbol, desc = "Workspace symbol" },
        ["<Leader>di"] = { vim.lsp.buf.implementation, desc = "Implementation" },
        ["<Leader>td"] = { vim.lsp.buf.type_definition, desc = "Type definition" },
        ["<Leader>rf"] = { vim.lsp.buf.references, desc = "References" },
        ["<Leader>sd"] = { vim.lsp.diagnostic.show_line_diagnostics, desc = "Show line diagnostics" },
        ["<Leader>pd"] = { vim.lsp.diagnostic.goto_prev, desc = "Go to previous diagnostic" },
        ["<Leader>nd"] = { vim.lsp.diagnostic.goto_next, desc = "Go to next diagnostic" },
        ["<Leader>cl"] = { vim.lsp.diagnostic.set_loclist, desc = "Set loclist" },
        ["<Leader>cc"] = { vim.lsp.diagnostic.get_count, desc = "Get diagnostic count" },
      },
    },
    -- A custom `on_attach` function to be run after the default `on_attach` function
    -- takes two parameters `client` and `bufnr`  (`:h lspconfig-setup`)
    on_attach = function(client, bufnr)
      -- this would disable semanticTokensProvider for all clients
      -- client.server_capabilities.semanticTokensProvider = nil
    end,
  },
}
