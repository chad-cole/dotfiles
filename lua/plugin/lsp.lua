local nvim_lsp = require('lspconfig')

require('lspkind').init({
    -- with_text = true,
    symbol_map = {
    --   Text = '',
        Method = '',
        Function = 'ƒ',
    --   Constructor = '',
    --   Variable = '',
        Class = '',
    --   Interface = 'ﰮ',
    --   Module = '',
    --   Property = '',
    --   Unit = '',
    --   Value = '',
    --   Enum = '了',
    --   Keyword = '',
    --   Snippet = '﬌',
    --   Color = '',
    --   File = '',
    --   Folder = '',
    --   EnumMember = '',
    --   Constant = '',
    --   Struct = ''
    },
})

local servers = {
    -- 'pyls',
    -- 'gopls',
    'tsserver',
    'sorbet'
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
  }
end

nvim_lsp['sorbet'].setup{
    cmd = {"bin/bundle", "exec", "srb", "tc", "--lsp"};
}
