-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
-- vim.filetype.add {
--   extension = {
--     foo = "fooscript",
--   },
--   filename = {
--     ["Foofile"] = "fooscript",
--   },
--   pattern = {
--     ["~/%.config/foo/.*"] = "fooscript",
--   },
-- }

vim.keymap.del("n", "\\")

-- Ensure tab mapping for window switching works properly
vim.keymap.set("n", "<Tab>", "<C-w><C-w>", { desc = "Switch between windows", noremap = true, silent = true })

-- Set colorscheme (will use the one configured in astroui.lua)
