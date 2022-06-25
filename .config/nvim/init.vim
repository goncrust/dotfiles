

"           Plugins
call plug#begin()
 " Better syntax support
 Plug 'sheerun/vim-polyglot'
 " File explorer
 Plug 'scrooloose/nerdtree'
 " Terminal
 Plug 'akinsho/toggleterm.nvim'
 " Auto pairs
 Plug 'jiangmiao/auto-pairs'
 " Theme
 Plug 'dracula/vim'
 " Comments
 Plug 'preservim/nerdcommenter'
 " Startify
 Plug 'mhinz/vim-startify'
 " Intellisense
 Plug 'neoclide/coc.nvim', {'branch': 'release'}
 " Snippets
 Plug 'honza/vim-snippets'
 " Discord status
 " Plug 'aurieh/discord.nvim', {'do': ':UpdateRemotePlugins'}
 Plug 'vim-airline/vim-airline'
 " Plug 'vim-airline/vim-airline-themes'
 " Colorizer
 Plug 'norcalli/nvim-colorizer.lua' 
 " Rainbow parantheses
 Plug 'junegunn/rainbow_parentheses.vim'
 " Devicons
 Plug 'ryanoasis/vim-devicons'
 " fzf
 Plug 'junegunn/fzf' 
 Plug 'junegunn/fzf.vim' 
 call plug#end()


"           Coc Config
source $HOME/.config/nvim/plug-config/coc.vim
" coc-vimlsp coc-snippets coc-discord-rcp coc-tsserver coc-pyright coc-json
" coc-clangd coc-java

"           Airline Config
source $HOME/.config/nvim/themes/airline.vim

"           Rainbow Config
source $HOME/.config/nvim/plug-config/rainbow.vim

"           Startify Config
source $HOME/.config/nvim/plug-config/start-screen.vim


"           General Settings
let g:mapleader = "\<Space>"            " Set leader key
syntax on                               " Enables syntax highlighing
filetype plugin indent on               " allow auto-indenting depending on file type
set hidden                              " Required to keep multiple buffers open multiple buffers
set nowrap                              " Display long lines as just one line
set encoding=utf-8                      " The encoding displayed
set pumheight=10                        " Makes popup menu smaller
set fileencoding=utf-8                  " The encoding written to file
set ruler                               " Show the cursor position all the time
set cmdheight=2                         " More space for displaying messages
set iskeyword+=-                      	" treat dash separated words as a word text object"
set mouse=a                             " Enable your mouse
set splitbelow                          " Horizontal splits will automatically be below
set splitright                          " Vertical splits will automatically be to the right
set t_Co=256                            " Support 256 colors
set conceallevel=0                      " So that I can see `` in markdown files
set tabstop=4                           " number of columns occupied by a tab 
set softtabstop=4                       " see multiple spaces as tabstops so <BS> does the right thing
set shiftwidth=4                        " width for autoindents
set smarttab                            " Makes tabbing smarter will realize you have 2 vs 4
set expandtab                           " Converts tabs to spaces
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent
set laststatus=0                        " Always display the status line
set number relativenumber               " add line numbers
set cursorline                          " Enable highlighting of the current line
set background=dark                     " tell vim what the background color looks like
set showtabline=2                       " Always show tabs
set noshowmode                          " We don't need to see things like -- INSERT -- anymore
set nobackup                            " This is recommended by coc
set nowritebackup                       " This is recommended by coc
set updatetime=300                      " Faster completion
set timeoutlen=500                      " By default timeoutlen is 1000 ms
set formatoptions-=cro                  " Stop newline continution of comments
set clipboard=unnamedplus               " Copy paste between vim and everything else
set autochdir                           " Your working directory will always be the same as your working directory
set ignorecase                          " case insensitive
set hlsearch                            " highlight search 
set wildoptions+=pum                    " command line tab completions      
au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
set cc=100                              " set an 100 column border for good coding style
set ttyfast                             " Speed up scrolling in Vim
" You can't stop me
cmap w!! w !sudo tee %


"           Color Scheme
 if (has("termguicolors"))
 set termguicolors
 endif
 syntax enable
colorscheme dracula

"           Lua Configs
lua require'plug-colorizer'
lua require'plug-toggleterm'


"           KeyBindings
" Better nav for omnicomplete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" Use alt + hjkl to resize windows
nnoremap <A-k> :resize -2<CR>
nnoremap <A-j> :resize +2<CR>
nnoremap <A-h> :vertical resize +2<CR>
nnoremap <A-l> :vertical resize -2<CR>

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Alternate way to save
nnoremap <C-s> :w<CR>
" Alternate way to quit
nnoremap <C-Q> :wq!<CR>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" move line or visually selected block - alt+j/k
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" NERDTree
nmap <C-f> :NERDTreeToggle<CR>
" startup
autocmd VimEnter * NERDTree | wincmd p
" close auto if last window
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" fzf
nmap <C-p> :Files<CR>

"           History
set undodir=~/.vim/undodir
set undofile

