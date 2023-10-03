local lsp = require('lsp-zero')
local cmp = require('cmp')

lsp.preset('recommended')

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {
    'bashls',
    'eslint',
    'graphql',
    'marksman',
    'rust_analyzer',
    'solargraph',
    'sorbet',
    'lua_ls',
    'texlab',
    'tsserver',
    'yamlls',
  },
  handlers = {
    lsp.default_setup,
  },
})

local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<CR>'] = cmp.mapping.confirm({select = false}),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
    local opts = {buffer = bufnr, remap = false}

    vim.keymap.set("n", "vd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = true,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})
