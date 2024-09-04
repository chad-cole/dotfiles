-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>w", vim.cmd.w)
vim.keymap.set("n", "<leader>x", vim.cmd.wq)
vim.keymap.set("n", ";", ":")

vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("v", "<Down>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<Up>", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<Down>", "J")
vim.keymap.set("n", "<Up>", "mzi<CR><Esc>`z")
vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", '"_dP')

vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format()
end)

vim.keymap.set("n", "<M-p>", ":vertical resize +5<CR>", { silent = true })
vim.keymap.set("n", "<M-m>", ":vertical resize -5<CR>", { silent = true })

vim.keymap.set("n", "<leader>cc", ':let @* = expand("%")<CR>', { silent = true })
vim.keymap.set("n", "<leader>c", ':let @+ = expand("%")<CR>', { silent = true })

vim.keymap.set("n", "<M-o>", ":cn<CR>", { silent = true })
vim.keymap.set("n", "<M-i>", ":cp<CR>", { silent = true })

if not os.getenv("$TMUX") then
	vim.keymap.set("n", "<M-h>", ":wincmd h<CR>")
	vim.keymap.set("n", "<M-j>", ":wincmd j<CR>")
	vim.keymap.set("n", "<M-k>", ":wincmd k<CR>")
	vim.keymap.set("n", "<M-l>", ":wincmd l<CR>")
end

vim.keymap.set({ "n", "v" }, "gh", function()
	CopyGithubURL()
end)
vim.keymap.set({ "n", "v" }, "<leader>gh", function()
	CopyGithubURL(true)
end)

vim.keymap.set("n", "<Left>", "zc", { noremap = true })
vim.keymap.set("n", "<Right>", "zo", { noremap = true })
