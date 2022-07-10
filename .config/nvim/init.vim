" ------------------ VIM CONFIG ------------------ "
if !exists('g:vscode')

" --------- Plugins --------- "
call plug#begin()
 Plug 'sheerun/vim-polyglot'                        " Better syntax support
 Plug 'scrooloose/nerdtree'                         " File explorer
 Plug 'akinsho/toggleterm.nvim'                     " Terminal
 Plug 'jiangmiao/auto-pairs'                        " Auto pairs
 Plug 'dracula/vim'                                 " Theme
 Plug 'preservim/nerdcommenter'                     " Comments
 Plug 'mhinz/vim-startify'                          " Startify
 Plug 'neoclide/coc.nvim', {'branch': 'release'}    " Intellisense
    " coc-vimlsp 
    " coc-snippets 
    " coc-discord-rcp 
    " coc-tsserver 
    " coc-pyright 
    " coc-json
    " coc-clangd
    " coc-java
 " Plug 'honza/vim-snippets'                        " Snippets
 Plug 'vim-airline/vim-airline'                     " Airline
 " Plug 'vim-airline/vim-airline-themes'            " Airline themes
 Plug 'norcalli/nvim-colorizer.lua'                 " Colorizer
 Plug 'junegunn/rainbow_parentheses.vim'            " Rainbow parantheses
 Plug 'ryanoasis/vim-devicons'                      " Devicons
 Plug 'junegunn/fzf'                                " fzf
 Plug 'junegunn/fzf.vim'                            " fzf
 Plug 'mhinz/vim-signify'                           " Git diffs
 Plug 'liuchengxu/vim-which-key'
call plug#end()

" --------- Config Files --------- "
source $HOME/.config/nvim/themes/airline.vim            " Airline
source $HOME/.config/nvim/plug-config/coc.vim           " Coc
source $HOME/.config/nvim/plug-config/rainbow.vim       " Rainbow
source $HOME/.config/nvim/plug-config/start-screen.vim  " Startify

" --------- Leader Key --------- "
let mapleader = "\<Space>"
map <Space> <Leader>

" --------- General Settings --------- "
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
set clipboard=unnamedplus               " Copy paste between vim and everything else
set autochdir                           " Your working directory will always be the same as your working directory
set ignorecase                          " case insensitive
set hlsearch                            " highlight search 
set wildoptions+=pum                    " command line tab completions      
au! BufWritePost $MYVIMRC source %      " auto source when writing to init.vm alternatively you can run :source $MYVIMRC
set cc=100                              " set an 100 column border for good coding style
set ttyfast                             " Speed up scrolling in Vim
set signcolumn=auto                     " Show signs in new column
" You can't stop me
cmap w!! w !sudo tee %

" Remember last position in file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" Stop newline continution of comments
autocmd FileType * set formatoptions-=cro

" --------- History Setup --------- "
set undodir=~/.vim/undodir
set undofile

" --------- Color Scheme --------- "
if (has("termguicolors"))
 set termguicolors
endif
syntax enable
colorscheme dracula

" --------- lua Config Files --------- "
lua require'plug-colorizer'
lua require'plug-toggleterm'

" --------- NERDTree Config --------- "
nmap <C-f> :NERDTreeToggle<CR>
" startup
autocmd VimEnter * NERDTree | wincmd p
" close auto if last window
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" --------- fzf Config --------- "
nmap <C-p> :Files<CR>

" --------- Which Key Config --------- "
" Map leader to which_key
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0

" --------- signify Config --------- "
let g:signify_sign_add               = '+'
let g:signify_sign_delete            = '_'
let g:signify_sign_delete_first_line = '‾'
let g:signify_sign_change            = '~'
let g:signify_sign_show_count = 1
let g:signify_sign_show_text = 1

" Jump though hunks
nmap <leader>gj <plug>(signify-next-hunk)
nmap <leader>gk <plug>(signify-prev-hunk)

" --------- Key Bindings --------- "
" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Use alt + hjkl to resize windows
nnoremap <A-k> :resize -2<CR>
nnoremap <A-j> :resize +2<CR>
nnoremap <A-h> :vertical resize +2<CR>
nnoremap <A-l> :vertical resize -2<CR>

" TAB in general mode will move to text buffer
nnoremap <TAB> :bnext<CR>
" SHIFT-TAB will go back
nnoremap <S-TAB> :bprevious<CR>

" Better nav for omnicomplete
inoremap <expr> <c-j> ("\<C-n>")
inoremap <expr> <c-k> ("\<C-p>")

" Alternate way to save
nnoremap <C-s> :w<CR>
" Alternate way to quit
nnoremap <C-Q> :wq!<CR>
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

" Easy CAPS
inoremap <c-u> <ESC>viwUi
nnoremap <c-u> viwU<Esc>

" Better tabbing
vnoremap < <gv
vnoremap > >gv

" move line or visually selected block - alt+j/k
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" Close current buffer without closing vim
nnoremap <leader>q :bp<cr>:bd #<cr>

else
" -------- VSCODE MODE ONLY ---------
source $HOME/.config/nvim/vscode/settings.vim

endif
