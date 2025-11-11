#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$(whoami)" "$HOME" "$@"
ORIGINAL_USER="${1:-$(whoami)}"
ORIGINAL_HOME="${2:-$HOME}"

if ! command -v vim >/dev/null 2>&1; then
	apt install -y vim
fi

if [ ! -f "$ORIGINAL_HOME/.vimrc" ]; then
	cat > "$ORIGINAL_HOME/.vimrc" <<'EOF'
filetype plugin indent on
syntax on
set number
set relativenumber
set hidden
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smartindent
set wrap
set lbr
set so=4
set backspace=indent,eol,start
set encoding=utf8
set noerrorbells
set novisualbell
set noswapfile
EOF
fi
