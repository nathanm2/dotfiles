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

" Make it easier to edit this file by defining two mappings:
"   - One to edit the init.vim file.
"   - One to source the init.vim file.
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" <Tab> behavior in normal mode:
"   Part 1: longest:full => Complete the longest string and then show
"            remaining options in a pop-up menu.
"   Part 2: full => Cycle through menu fields.
"
" Note: wildmode=longest,list follows bash shell conventions.
"
set wildmode=longest:full,full

" Enable mouse support in the terminal:
"   a=all, n=normal, v=visual, i=insert
set mouse=a

" When splitting a window, put the new window to the right of the current one.
" I find this less disruptive when splitting a window and bringing up Vimwiki.
set splitright

" Make it easier to navigate between splits:
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" Clear the last search results:
:nnoremap <leader>c :nohlsearch<cr>

" Vimwiki Configuration ======================================================

" Define two mappings to split the window and launch Vimwiki within the new
" split.
"
" NOTE: This mapping has been a carefully crafted to ensure that a NUMBER
" issued prior to the mapping be used to specify the wiki index and not the
" size of the split window.
"
:noremap <Leader>wv :<C-U>exe 'vsplit +VimwikiIndex' . v:count1<cr>
:noremap <Leader>wh :<C-U>exec 'split +VimwikiIndex' . v:count1<cr>

" Define two wikis:
"
" Each wiki is configured via a dictionary.  We initially create an empty
" dictionary and then configure with new key/value pairs.

let wiki_dropbox = {}
let wiki_dropbox.path = '~/Dropbox/vimwiki/'

let wiki_local = {}
let wiki_local.path = '~/vimwiki/'

" This registers the two wikis.  It also defines their relative order.
"  1<Leader>ww opens the first wiki in g:vimwiki_list.
"  2<Leader>ww opens the second wiki in g:vimwiki_list.
"  etc.
let g:vimwiki_list = [wiki_dropbox, wiki_local]

