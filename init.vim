call plug#begin('~/.vim/plugged')

" Plebvim lsp Plugins
Plug 'neovim/nvim-lspconfig'
Plug 'glepnir/lspsaga.nvim'
Plug 'tjdevries/nlua.nvim'
Plug 'tjdevries/lsp_extensions.nvim'

" Neovim Tree shitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-treesitter/playground'

" Debugger Plugins
Plug 'puremourning/vimspector'
Plug 'szw/vim-maximizer'

" Nice Plugins
Plug 'windwp/nvim-autopairs'
Plug 'gruvbox-community/gruvbox'
Plug 'junegunn/gv.vim'
Plug 'mbbill/undotree'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-vinegar'
Plug 'tweekmonster/gofmt.vim'
Plug 'vim-utils/vim-man'
Plug 'vuciv/vim-bujo'
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdtree'
Plug 'edkolev/tmuxline.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'mhinz/vim-startify'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'Shopify/shadowenv.vim'
Plug 'Shopify/vim-sorbet'

" Git Plugins
Plug 'tpope/vim-fugitive'
if has('nvim') || has('patch-8.0.902')
  Plug 'mhinz/vim-signify'
else
  Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
endif
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Telescope requirements...
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'onsails/lspkind-nvim'

Plug 'ap/vim-css-color'
Plug 'sbdchd/neoformat'

call plug#end()

lua require'nvim-treesitter.configs'.setup { highlight = { enable = true } }

if executable('rg')
    let g:rg_derive_root='true'
endif

let loaded_matchparen=1
let mapleader = " "

let g:netrw_browse_split=2
let g:netrw_banner=0
let g:netrw_winsize = 25

" Markdown
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
function! g:Open_browser(url)
    silent exe 'silent !open -a "Google Chrome" ' . a:url
endfunction
let g:mkdp_browserfunc = 'g:Open_browser'


" Airline
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'

if !exists('g:airline_symbols')
   let g:airline_symbols = {}
endif
let g:airline_symbols.dirty=' '
let g:airline_symbols.notexists = ' ∄'
let g:airline_symbols.branch = ''

" Signify
let g:signify_sign_add = ''
let g:signify_sign_delete = ''
let g:signify_sign_change = ''

" NERDTree
let NERDTreeIgnore = [ '__pycache__',  '\.DS_STORE$', '\.pyc$', '\.o$', 'node_modules/' ]
let NERDTreeShowHidden=1
let NERDTreeAutoDeleteBuffer=1
let NERDTreeQuitOnOpen=1
let NERDTreeMapUpdir='-'
let NERDTreeMapOpenSplit='s'
let NERDTreeMapOpenVSplit='v'

" Startify
let g:startify_change_to_dir = 0

nnoremap <leader>ghw <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>bs /<C-R>=escape(expand("<cWORD>"), "/")<CR><CR>
nnoremap <leader>u :UndotreeShow<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <leader>E :NERDTreeVCS<CR>
nnoremap <leader>e :NERDTreeFind<CR>
nnoremap <silent> <M-p> :vertical resize +5<CR>
nnoremap <silent> <M-m> :vertical resize -5<CR>

set clipboard+=unnamedplus

" greatest remap ever
vnoremap <leader>p "_dP

" next greatest remap ever : asbjornHaland
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" vim TODO
nmap <Leader>tu <Plug>BujoChecknormal
nmap <Leader>th <Plug>BujoAddnormal
let g:bujo#todo_file_path = $HOME . "/.cache/bujo"

inoremap <C-c> <esc>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

fun! EmptyRegisters()
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
endfun

" ES
com! W w
com! Q q
com! Vs vs
com! Sp sp

nmap <leader>nn :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua require'vim.highlight'.on_yank({timeout = 40})
augroup END

augroup setup
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufEnter,BufWinEnter,TabEnter *.rs :lua require'lsp_extensions'.inlay_hints{}
augroup END
