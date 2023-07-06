vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.g.mapleader = " "

vim.opt.updatetime = 50

vim.opt.autochdir = false

vim.opt.clipboard = 'unnamedplus'

vim.cmd("let g:clipboard = { 'name': 'tmux', 'copy': { '+': ['pbcopy'], '*': ['tmux', 'loadb', '-'], }, 'paste': { '+': ['pbpaste'], '*': ['tmux', 'saveb', '-'], }, 'cache_enabled': 1 }")
