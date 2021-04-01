nnoremap <M-Up> :call AfPPAlternate()<CR>
nnoremap <M-q> :call ToggleQFList(1)<CR>
nnoremap <M-l> :call ToggleQFList(0)<CR>

let g:my_qf_l = 0
let g:my_qf_g = 0

fun! ToggleQFList(global)
    if g:my_qf == 1
        if a:global
            let g:my_qf_g = 0
            cclose
        else
            let g:my_qf_l = 0
            lclose
        endif
    else
        if a:global
            let g:my_qf_g = 0
            cclose
        else
            let g:my_qf_l = 0
            lclose
        endif
    endif
endfun

imap jk <Esc>
tmap jk <Esc>

if exists('$TMUX')
    nnoremap <C-h> :wincmd h<CR>
    nnoremap <C-j> :wincmd j<CR>
    nnoremap <C-k> :wincmd k<CR>
    nnoremap <C-l> :wincmd l<CR>
    tnoremap <C-h> <C-\><C-N>:wincmd h<CR>
    tnoremap <C-j> <C-\><C-N>:wincmd j<CR>
    tnoremap <C-k> <C-\><C-N>:wincmd k<CR>
    tnoremap <C-l> <C-\><C-N>:wincmd l<CR>
else
    nnoremap <M-h> :wincmd h<CR>
    nnoremap <M-j> :wincmd j<CR>
    nnoremap <M-k> :wincmd k<CR>
    nnoremap <M-l> :wincmd l<CR>
    tnoremap <M-h> <C-\><C-N>:wincmd h<CR>
    tnoremap <M-j> <C-\><C-N>:wincmd j<CR>
    tnoremap <M-k> <C-\><C-N>:wincmd k<CR>
    tnoremap <M-l> <C-\><C-N>:wincmd l<CR>
endif
