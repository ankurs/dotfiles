-- Sourced by update.sh during `nvim --headless` runs to surface progress.
--
-- :AstroUpdate triggers :MasonToolsUpdate asynchronously, so a plain +qa would
-- cut Mason installs/updates off mid-flight. This file:
--   1. Routes vim.notify to stdout (it's silent in headless mode otherwise).
--   2. Subscribes to mason-tool-installer events for live progress.
--   3. Exposes _G.upd_done, which update.sh waits on before quitting.

local function emit(msg)
  io.stdout:write(tostring(msg) .. "\n")
  io.stdout:flush()
end

vim.notify = function(msg, _, _) emit("[nvim] " .. tostring(msg)) end

_G.upd_done = false
-- astrocore.event("UpdateCompleted", true) prepends "Astro" to the pattern,
-- so the real event name is `AstroUpdateCompleted`.
vim.api.nvim_create_autocmd("User", {
  pattern = "AstroUpdateCompleted",
  once = true,
  callback = function() _G.upd_done = true end,
})

for _, ev in ipairs({
  "MasonToolsStartingInstall",
  "MasonToolsUpdateCompleted",
  "MasonToolsUpdateCompletedSuccess",
  "MasonToolsUpdateCompletedError",
}) do
  vim.api.nvim_create_autocmd("User", {
    pattern = ev,
    callback = function(args)
      emit("[mason] " .. ev .. " " .. vim.inspect(args.data or {}))
    end,
  })
end
