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

Plug 'JoshMcguigan/estream', { 'do': 'bash install.sh v0.1.2' }

" Map <c-arrow> to resize splits
Plug 'breuckelen/vim-resize'

" Install fzf cli tool and vim plugin
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()

" --- Colors ---
highlight Pmenu ctermbg=gray

" enable comments in json files for jsonc support
autocmd FileType json syntax match Comment +\/\/.\+$+

" configure yaml
autocmd BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=0# indentkeys-=<:>

nnoremap <leader>v :source $MYVIMRC<CR>

" For vim-resize plugin
let g:resize_count = 1
tnoremap <silent> <c-left> <C-\><C-N>:CmdResizeLeft<CR>i
tnoremap <silent> <c-down> <C-\><C-N>:CmdResizeDown<CR>i
tnoremap <silent> <c-up> <C-\><C-N>:CmdResizeUp<CR>i
tnoremap <silent> <c-right> <C-\><C-N>:CmdResizeRight<CR>i

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
" Set global error format to match estream output
set errorformat=%f\|%l\|%c,%f\|%l\|,%f\|\|
" Use global error format with asyncrun
let g:asyncrun_local = 0

" Pipe any async command through estream to format it as expected
" by the errorformat setting above
" example: `:Async cargo test`
command -nargs=1 Async execute "AsyncRun <args> |& $VIM_HOME/plugged/estream/bin/estream"
nnoremap <leader>a :Async 
nnoremap <leader>s :AsyncStop<CR>

" Create a file watcher, primarily used with Async using the mapping below
command -nargs=1 Watch augroup watch | exe "autocmd! BufWritePost * <args>" | augroup END
command NoWatch autocmd! watch

" Use to run a command on every file save, pipe it through estream
" and view it in the quickfix window.
" example: `:Watch Async cargo test`
nnoremap <leader>w :Watch Async 
nnoremap <leader>nw :NoWatch<CR>

function HideTerminal()
	" Hides the terminal if it is open
	" Hiding is preferred to closing the terminal so that
	" the terminal session persists
	if bufwinnr('bin/bash') > 0
		execute bufwinnr('bin/bash') . "hide"
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
			" Set kill, so when Vim wants to exit or otherwise
			" kill the terminal window, it knows how. This resolves
			" E497 when trying to quit Vim while the terminal window
			" is still open.
			vert botright term ++kill=term
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

nnoremap [q :cprev<CR>
nnoremap ]q :cnext<CR>

" --- fzf customizations ---
" enable preview
command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=? -complete=dir GFiles
    \ call fzf#vim#gitfiles(<q-args>, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

" fuzzy find files
nnoremap <C-p> :GFiles<CR>
" fuzzy find in contents of current buffer
nnoremap <C-l> :BLines<CR>
" fuzzy find in contents of all files in project
nnoremap <C-m> :Rg<CR>
