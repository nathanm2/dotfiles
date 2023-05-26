" Common Global Configs ===============================================
"
" Common vim options used in both vim AND neovim.
"

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

" Ignore case when searching:
set ignorecase

" Enable "smart case", so that Vim intelligently respects case when an upper
" case character appears in the search.
set smartcase

" Show both the current line number and relative line numbers.
set number relativenumber

" Common Key Maps ===============================================

" -- Normal Mode --

" A character to be pressed before some of the following mappings take effect:
"
" To use the SPACEBAR as the leader key you need to first remove the existing
" mapping for SPACE which defaults to moving forward a single key.
nnoremap <SPACE> <Nop>
let mapleader = " "

" Easier window movement mappings:
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" Resize with arrows
"
" NOTE: This feels natural for the top-left window, but a bit surprising when dealing with windows
" on the bottom or the right.
nnoremap <c-up> :resize -2<CR>
nnoremap <c-down> :resize +2<CR>
nnoremap <c-left> :vertical resize -2<CR>
nnoremap <c-right> :vertical resize +2<CR>

" Easily clear the last search result:
nnoremap <leader>c :nohlsearch<cr>

" Easily display the file explorer:
nnoremap <leader>q :Lex 30<cr>

" Navigate between buffers:
nnoremap [b :bnext<CR>
nnoremap ]b :bprevious<CR>

" -- Insert Mode --

" Make 'jk' an escape sequence (convenient shortcut):
inoremap jk <esc>

" Make the current word upper-case:
inoremap UU <esc>gUawea


" -- Visual Mode --

" Stay in indent mode
vnoremap < <gv
vnoremap > >gv
