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
" Settings used in all file types.
"

" Make 'jk' an escape sequence:
inoremap jk <esc>

" Enable 24-bit color support in the terminal:
set termguicolors

" Previously, I used the following mappings to copy, cut, and paste
" to the CLIPBOARD buffer (+):
"
" noremap <F1> "+y
" noremap <F2> "+d
" noremap <F3> "+p
"
" However, there appears to be a much better way: simply adding 'unnamedplus' to the
" clipboard setting causes vim to use the CLIPBOARD buffer instead of the
" UNNAMED buffer!
set clipboard+=unnamedplus

" A character to be pressed before some of the following mappings take effect:
let mapleader = " "

" Easier window movement mappings:
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>


" Easily clear the last search result:
nnoremap <leader>c :nohlsearch<cr>

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

" Enable "smart case":
set smartcase
