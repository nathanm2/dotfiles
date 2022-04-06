" Debugging Tips =============================================================
"
" List your scripts:
"     :scriptnames
"
" Run VIM without any scripts:
"     $ nvim -u NONE -U NONE
"
" Source plugins individually:
"     :so path/to/script

" Global Configs =============================================================
" 
" Settings used for all files.
" 

" Make 'jk' an escape sequence.
inoremap jk <esc>

" Enable 24-bit color support in the terminal:
set termguicolors

" Color scheme:
colorscheme default

" A character to be pressed before some of the following mappings take effect:
let mapleader = "-"

" Make it easier to this file by defining two mappings:
"   - One to edit the init.vim file.
"   - One to source the init.vim file.
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" <Tab> behavior in normal mode:
"   Part 1: longest:full => Complete till longest common string and show menu.
"   Part 2: full => Cycle through menu fields.
"
" Note: wildmode=longest,list follows bash shell conventions.
"
set wildmode=longest:full,full

" Enable mouse support in the terminal:
"   a=all, n=normal, v=visual, i=insert
set mouse=a

" Make it easier to navigate between splits:
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" Clear the last search results:
:nnoremap <leader>c :nohlsearch<cr>
