-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- Automatically install lazy.nvim if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim..")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  print("lazy.nvim installed successfully.")
end
vim.opt.rtp:prepend(lazypath)

-- Load core configurations
require("core.options")
require("core.keymaps")

-- Load plugins using lazy.nvim
require("lazy").setup("plugins")

-- custom commands
vim.api.nvim_create_user_command("UninstallPlugins", function()
  require("utils.functions").uninstall_plugins()
end, {})
