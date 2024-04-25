nmap <cr> :
nmap <space> <leader>
vmap <space> <leader>
set nocompatible
set showmatch
set ignorecase
set smartcase
set incsearch
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smarttab
set backspace=indent,eol,start
set title
set titlestring=%t%(\ %M%)
set titlelen=36
set number
set nrformats-=octal
set formatoptions+=j
set list
set listchars=trail:~,tab:»⋅,nbsp:␣
set iskeyword+=-
set nowrap
set mouse=a
set cursorline
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set ruler
set clipboard+=unnamedplus
set ttyfast
set termguicolors
set t_Co=256
set background=dark
set signcolumn=yes
set scrolloff=1
set sidescroll=1
set sidescrolloff=2
set splitright
set splitbelow
set display+=lastline
set wildoptions+=fuzzy
set undofile
set noswapfile
set backupdir=~/.cache/vim
set complete-=i
set completeopt=menuone,noselect
set updatetime=250
set timeout
set timeoutlen=300
set ttimeout
set ttimeoutlen=10
set autoread
set history=1000
set tabpagemax=50
set hidden
filetype plugin on
filetype plugin indent on
syntax enable
lua require("init")
