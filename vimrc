if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'rust-lang/rust.vim'
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
Plug 'airblade/vim-gitgutter'

call plug#end()

" Put gitgutter preview into floating window
let g:gitgutter_preview_win_floating = 1
" Put gitgutter signs under language server signs
let g:gitgutter_sign_priority=0
" don't use default mappings for gitgutter
let g:gitgutter_map_keys = 0

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>h <Plug>(GitGutterPreviewHunk)
nmap <leader>u <Plug>(GitGutterUndoHunk)
nmap <leader>gf :GitGutterFold<CR>

" Smaller updatetime for CursorHold & CursorHoldI, and git gutter
set updatetime=100

" Always show column where git gutter puts diagnostics, to avoid jumpiness
set signcolumn=yes

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

set number relativenumber

" Set the terminal title
set title

" Display tabs as four spaces
set tabstop=4
set shiftwidth=0 " `>` and `<` keys should shift the same distance as tab key
set noexpandtab " don't expand tabs to spaces

set incsearch

" Clear search highlighting until next search
nmap <leader><leader> :nohlsearch<CR>
