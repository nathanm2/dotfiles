" Common Global Configs ===============================================
"
" Common vim options used in both vim AND neovim.
"

" Debug Tips ==========================================================
" 
" Which script changed an option setting:
"   :verbose set textwidth?

" Enable 24-bit color support in the terminal:
set termguicolors

" Common Editor Behavior ==============================================

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


"function! WindowWidth()
"    if &textwidth != 0
"        let &l:winwidth=&textwidth + 5
"    endif
"endfunction

"autocmd WinEnter * :call WindowWidth()

" Common Key Maps ===============================================

" -- Normal Mode --

" The leader key.
"
" Using this for key maps ensures the map won't collide with some
" existing mapping.
"
" To use the SPACEBAR as the leader key you need to first remove the existing
" mapping for SPACE which defaults to moving forward a single key.
nnoremap <SPACE> <Nop>
let mapleader = " "

" Easier window movement mappings:
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
nnoremap <c-h> <c-w>h

" Better movement
"
" gj/gk move to the next display line, which when wrapping is enabled, may not
" correpond to the line number.
nnoremap <silent><expr> j v:count == 0 ? "gj" : "j"
nnoremap <silent><expr> k v:count == 0 ? "gk" : "k"

" Toggle between absolute/relative/none line numbering
nnoremap <silent> <leader>l :call ToggleLineNumberType()<cr>

function! ToggleLineNumberType()
    if &relativenumber && &number
        setlocal norelativenumber
    elseif &number
        setlocal nonumber
    else
        setlocal number relativenumber
    endif
endfunction

" Resize with arrows
"
" NOTE: This feels natural for the top-left window, but a bit surprising when dealing with windows
" on the bottom or the right.
nnoremap <c-up> :resize -2<CR>
nnoremap <c-down> :resize +2<CR>
nnoremap <c-left> :vertical resize -2<CR>
nnoremap <c-right> :vertical resize +2<CR>

" Easily clear the last search result by pressing escape.
nnoremap <esc> <cmd>noh<cr><esc>
inoremap <esc> <cmd>noh<cr><esc>

" Easily toggle the NetRW window
nnoremap <leader>e :Lex 30<cr>

" Navigate between buffers:
nnoremap [b <cmd>exe v:count .. "bprevious"<cr>
nnoremap <s-h> :bprevious<cr>
nnoremap ]b <cmd>exe v:count .. "bnext"<cr>
nnoremap <s-l> :bnext<cr>
nnoremap <leader>bb :e #<cr>

" Navigate the quickfix list
nnoremap [q <cmd>exe v:count .. "cprev"<cr>
nnoremap ]q <cmd>exe v:count .. "cnext"<cr>
nnoremap [Q <cmd>cfirst<cr>
nnoremap ]Q <cmd>clast<cr>


" -- Insert Mode --

" Make 'jk' an escape sequence (convenient shortcut):
inoremap jk <esc>

" Make the current word upper-case:
inoremap UU <esc>gUawea


" -- Visual Mode --

" Stay in indent mode
vnoremap < <gv
vnoremap > >gv

