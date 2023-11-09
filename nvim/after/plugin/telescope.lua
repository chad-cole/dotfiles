local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>gs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>fg', function()
  local p = io.popen('git diff --name-only main...; git diff --name-only; git ls-files --others --exclude-standard')
  local files = {}
  for file in p:lines() do
    table.insert(files, file)
  end
  p:close()

  require('telescope.builtin').live_grep({ search_dirs = files })
end, {})
