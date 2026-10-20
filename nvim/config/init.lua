vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("keymaps")

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
})

-- OS-specific overrides live in nvim/<os>/config/os.lua next to this config
-- directory, and are loaded last so they can win over the shared modules.
-- The config directory is a symlink into the repo, so resolve it first.
local os_dir = (vim.env.DOTENV_OS or (jit.os == "OSX" and "macos" or "linux"))
local config_root = vim.uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config")
local os_module = vim.fs.joinpath(config_root, "..", os_dir, "config", "os.lua")
if vim.uv.fs_stat(os_module) then
  dofile(os_module)
end
