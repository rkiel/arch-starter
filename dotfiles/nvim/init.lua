local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)


-- number           show line numbers
-- relativenumber   keep traditional absolute numbering
-- expandtab        insert spaces instead of tab characters
-- shiftwidth=2     indent by 2 spaces
-- tabstop=2        display tab characters as 2 columns
-- ignorecase       searches are case-insensitive by default
-- smartcase        uppercase in the search makes it case-sensitive
-- wrap=false       don't visually wrap long source lines
-- termguicolors    enable full terminal color support


-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = false

-- Indentation
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

-- Searching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Display
vim.opt.wrap = false
vim.opt.termguicolors = true

-- Plugins
require("lazy").setup("plugins")