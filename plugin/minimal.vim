fun! TurnOnGuides()
    set rnu
    set nu
    set signcolumn=yes
    set colorcolumn=120
endfun

fun! TurnOffGuides()
    set nornu
    set nonu
    set signcolumn=no
    set colorcolumn=800
endfun

nnoremap <leader>ao :call TurnOnGuides()<cr>
nnoremap <leader>ae :call TurnOffGuides()<cr>

augroup MY_MINIMAL
    autocmd!
    autocmd FileType *\(^\(netrw\|help\)\)\@<! :call TurnOnGuides()
    autocmd FileType netrw,help :call TurnOffGuides()
augroup END

" Remove Trailing Whitespace
autocmd BufWritePre * %s/\s\+$//e

augroup TERMINAL_MINIMAL
    autocmd!
    autocmd TermOpen * startinsert
    autocmd TermOpen * :call TurnOffGuides()
    autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
    autocmd FocusGained,BufEnter,BufWinEnter,WinEnter term://* startinsert
augroup END

augroup GRAPHQL
    au!
    autocmd BufNewFile,BufRead,BufWinEnter,WinEnter *.graphql set ft=graphql
augroup END
