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
nmap <leader>f  <Plug>(coc-fix-current)

set number relativenumber

" Set the terminal title
set title

" Display tabs as four spaces
set tabstop=4
set shiftwidth=0 " `>` and `<` keys should shift the same distance as tab key
set noexpandtab " don't expand tabs to spaces

set incsearch
" Turn on search highlighting, the temporarily disable it for the current search
" This resolves an issue where highlighting is turned on everytime
" vimrc is sourced
set hlsearch
nohlsearch
set wildmenu

" Clear search highlighting until next search
nmap <leader><leader> :nohlsearch<CR>

" Disable python std out buffering when running async
let $PYTHONUNBUFFERED=1
" Use local (compiler specific) error format
let g:asyncrun_local = 1

command -nargs=1 Watch augroup watch | exe "autocmd! BufWritePost * <args>" | augroup END
command NoWatch autocmd! watch
nnoremap <leader>w :Watch AsyncRun -post=call\\ RefreshQuickFix() 
nnoremap <leader>nw :NoWatch<CR>

nnoremap <leader>a :AsyncRun -post=call\ RefreshQuickFix() 
nnoremap <leader>s :AsyncStop<CR>

function HideTerminal()
	" Hides the terminal if it is open
	" Hiding is preferred to closing the terminal so that
	" the terminal session persists
	if bufwinnr('bin/bash') > 0
		execute bufwinnr('bin/bash') . "hide"
	endif
endfunction

function QuitTerminal()
	" Force exits the terminal
	" useful when you want to quit vim without E947
	" or you just want a fresh terminal session
	if bufnr('bin/bash') > 0
		execute "bw! " . bufnr('bin/bash')
	endif
endfunction

function ToggleTerminal()
	if bufwinnr('bin/bash') > 0
		call HideTerminal()
	else
		if bufnr('bin/bash') > 0
			" if an existing terminal buffer exists, but was hidden,
			" it should be re-used
			execute "vert botright sbuffer " . bufnr('bin/bash')
		else
			vert botright term
		endif
	endif
endfunction

function ToggleQuickFix()
	if len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')) > 0
		cclose
	else
		call OpenQuickFix()
	endif
endfunction

function RefreshQuickFix()
	" Call open quickfix if it is already open
	" This is used to re-parse errorformat, which helps because
	" streaming results would otherwise be partially parsed.
	if len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')) > 0
		call OpenQuickFix()
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

nnoremap <leader>t :cclose <bar> :call ToggleTerminal() <CR>
nnoremap <leader>q :call HideTerminal() <bar> call ToggleQuickFix()<CR>

" Toggle terminal hides the terminal buffer rather than removing it, to
" allowing continuing a session. But this causes E947 when quitting vim
" if you don't explicitly close the terminal. This remaps :q to first
" fully exit the terminal to avoid this error.
cnoreabbrev <expr> q getcmdtype() == ":" && getcmdline() == 'q' ? 'call QuitTerminal() \| q' : 'q'
cnoreabbrev <expr> qa getcmdtype() == ":" && getcmdline() == 'qa' ? 'call QuitTerminal() \| qa' : 'qa'

nnoremap [q :cprev<CR>
nnoremap ]q :cnext<CR>
