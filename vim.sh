#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$(whoami)" "$HOME" "$@"
ORIG_USER="${1:-$(whoami)}"
ORIG_HOME="${2:-$HOME}"

if ! command -v vim >/dev/null 2>&1; then
	apt install -y vim
fi

mkdir -p "$ORIG_HOME/.vim/undodir"

if [ ! -f "$ORIG_HOME/.vimrc" ]; then
	cat > "$ORIG_HOME/.vimrc" <<'EOF'
syntax on
filetype plugin indent on
set number
set relativenumber
set termguicolors
set background=dark
colorscheme lunaperche
set hidden
set noswapfile
set encoding=utf-8
set autoread
set undodir=~/.vim/undodir
set undofile
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smartindent
set ignorecase
set smartcase
set incsearch
set nohlsearch
set wrap
set linebreak
set scrolloff=6
set sidescrolloff=4
set mouse=a
set wildmenu
set updatetime=300
set timeoutlen=500
set belloff=all
let g:netrw_banner = 0
let g:netrw_liststyle = 1
let mapleader = " "
nnoremap <leader>y "+y
vnoremap <leader>y "+y
xnoremap <leader>y "+y
nnoremap <leader>p "+p
nnoremap <leader>P "+P
nnoremap <leader>q :quit<CR>
nnoremap <leader>w :write<CR>
nnoremap <leader>e :edit .<CR>
nnoremap <leader>e :edit #<CR>
nnoremap n nzzzv
nnoremap N Nzzzv
EOF
fi
