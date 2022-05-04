require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
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
