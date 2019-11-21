if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}

Plug 'airblade/vim-gitgutter'

" Rust syntax highlighting
Plug 'rust-lang/rust.vim'

" tsx syntax highlighting
Plug 'ianks/vim-tsx'
" typescript syntax highlighting
Plug 'leafgarland/typescript-vim'

Plug 'skywind3000/asyncrun.vim'
call plug#end()

" --- Colors ---
highlight Pmenu ctermbg=gray

" enable comments in json files for jsonc support
autocmd FileType json syntax match Comment +\/\/.\+$+

nnoremap <leader>v :source $MYVIMRC<CR>

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

" Allow cursor to move to top and bottom of file
" And ensure z-t moves line all the way to top of file
set scrolloff=0

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
set hlsearch
set wildmenu

" Clear search highlighting until next search
nmap <leader><leader> :nohlsearch<CR>

command -nargs=1 Watch augroup watch | exe "autocmd BufWritePost * AsyncRun <args>" | augroup END
command NoWatch autocmd! watch
nnoremap <leader>w :Watch 
nnoremap <leader>nw :NoWatch<CR>

function CloseTerminal()
	" Closes the terminal if it is open
	if bufwinnr('bin/bash') > 0
		execute "bd! " . bufnr('bin/bash')
	endif
endfunction

function OpenQuickFix()
	" Opens the quick fix window vertically split
	" while maintaining cursor position.
	" Store the original window number
    let l:winnr = winnr()

	execute "vert botright copen"
	" Set quickfix width
	execute &columns * 1/2 . "wincmd |"

    " If focus changed, jump to the last window
    if l:winnr !=# winnr()
        wincmd p
    endif
endfunction

nnoremap <leader>q :cclose <bar> :call CloseTerminal() <bar> call OpenQuickFix()<CR>
nnoremap <leader>t :cclose <bar> :call CloseTerminal() <bar> vert botright term<CR>

nnoremap [q :cprev<CR>
nnoremap ]q :cnext<CR>
