---@type LazySpec
return {
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-go", config = function() end },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-go"(require("astrocore").plugin_opts "neotest-go"))
    end,
  },
  {
    "stevearc/conform.nvim",
  },
  {
    "leoluz/nvim-dap-go",
  },
}
