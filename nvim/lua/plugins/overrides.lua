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
    -- disable the homescreen
    "goolord/alpha-nvim",
    enabled = false,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
        },
      },
    },
  },
  {
    "nvimtools/none-ls.nvim",
    enabled = false,
  },
}
