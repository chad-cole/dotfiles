require'nvim-treesitter.configs'.setup {
  ensure_installed = {  "c", "lua", "ruby", "python", "tsx", "typescript", "javascript", "latex", "bash", "css", "dot", "cmake", "graphql", "json", "vim", "yaml"},
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
  },
}

local npairs = require('nvim-autopairs')
local endwise = require('nvim-autopairs.ts-rule').endwise

npairs.setup()
npairs.add_rules({
  endwise('def .*$', 'end', 'ruby', 'method_name')
})
