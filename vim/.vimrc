call plug#begin('~/.vim/plugged')
Plug 'mg979/vim-visual-multi'   " multiple cursors (successor to terryma/vim-multiple-cursors)
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'         " lets . repeat surround/commentary actions
Plug 'tpope/vim-commentary'     " gcc / gc{motion} to toggle comments
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf.vim'
Plug 'morhetz/gruvbox'
call plug#end()
" plug#end() runs `filetype plugin indent on` and `syntax enable` automatically.
" Run :PlugInstall to install, :PlugUpdate to update, :PlugClean to prune.

set termguicolors
set background=dark
silent! colorscheme gruvbox

au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
syntax on
set number
set laststatus=2
nnoremap <A-j> :m+<CR>==
nnoremap <A-k> :m-2<CR>==
inoremap <A-j> <Esc>:m+<CR>==gi
inoremap <A-k> <Esc>:m-2<CR>==gi
vnoremap <A-j> :m'>+<CR>gv=gv
vnoremap <A-k> :m-2<CR>gv=gv
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
