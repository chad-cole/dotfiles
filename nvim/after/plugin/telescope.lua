require("telescope").setup {
  defaults = { file_ignore_patterns = {"node_modules", "sorbet"} },
  pickers = {
    buffers = {
      show_all_buffers = true,
      sort_lastused = true,
      mappings = {
        n = {
          ["d"] = "delete_buffer",
        }
      }
    }
  }
}

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', function()
  builtin.live_grep({ file_ignore_patterns = {"test"} })
end)
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>vs', builtin.treesitter, {})
vim.keymap.set('n', '<leader>gs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > "), file_ignore_patterns = {"test"} })
end)
vim.keymap.set('n', '<leader>gst', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set('n', '<leader>fg', function()
  local p = io.popen('git diff --name-only main...; git diff --name-only; git ls-files --others --exclude-standard')
  local files = {}
  for file in p:lines() do
    table.insert(files, file)
  end
  p:close()

  builtin.live_grep({ search_dirs = files })
end, {})
