set nocompatible            " disable compatibility to old-time vi
" set showmatch               " show matching
set ignorecase              " case insensitive
" set mouse=v                 " middle-click paste with
set hlsearch                " highlight search 
" set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab 
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number relativenumber          " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=100                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
" filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
" set spell                 " enable spell check (may need to download language package)
" set noswapfile            " disable creating swap file
" set backupdir=~/.cache/vim " Directory to store backup files.
set smartindent

call plug#begin()
 " Better syntax support
 Plug 'sheerun/vim-polyglot'
 " Theme
 Plug 'dracula/vim'
 " File explorer
 Plug 'scrooloose/nerdtree'
 Plug 'ryanoasis/vim-devicons'
 " Comments
 Plug 'preservim/nerdcommenter'
 " Auto pairs
 Plug 'jiangmiao/auto-pairs'
 " Startify
 Plug 'mhinz/vim-startify'
 " Intellisense
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 " Discord status
 " Plug 'aurieh/discord.nvim', {'do': ':UpdateRemotePlugins'}
 Plug 'vim-airline/vim-airline'
call plug#end()

" color schemes
 if (has("termguicolors"))
 set termguicolors
 endif
 syntax enable
 " colorscheme evening
colorscheme dracula

" open new split panes to right and below
set splitright
set splitbelow

" move line or visually selected block - alt+j/k
inoremap ¬Ø <Esc>:m .+1<CR>==gi
inoremap ‚Äû <Esc>:m .-2<CR>==gi
vnoremap ¬Ø :m '>+1<CR>gv=gv
vnoremap ‚Äû :m '<-2<CR>gv=gv

" move between panes to left/bottom/top/right
 nnoremap <C-h> <C-w>h
 nnoremap <C-j> <C-w>j
 nnoremap <C-k> <C-w>k
 nnoremap <C-l> <C-w>l

" history
set undodir=~/.vim/undodir
set undofile

" coc
source $HOME/.config/nvim/plug-config/coc.vim
" coc-vimlsp coc-snippets coc-discord-rcp coc-tsserver coc-pyright coc-json
