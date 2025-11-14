#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$(whoami)" "$HOME" "$@"
ORIGINAL_USER="${1:-$(whoami)}"
ORIGINAL_HOME="${2:-$HOME}"

if ! command -v yazi >/dev/null 2>&1; then
	wget -O yazi.zip https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
	unzip yazi.zip -d yazi-temp
	sudo mv yazi-temp/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
    sudo mv yazi-temp/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
	rm -rf yazi-temp yazi.zip
fi

mkdir -p "$ORIGINAL_HOME/.config/yazi"

if [ ! -f "$ORIGINAL_HOME/.config/yazi/yazi.toml" ]; then
	cat > "$ORIGINAL_HOME/.config/yazi/yazi.toml" <<'EOF'
[mgr]
show_hidden = true
ratio = [1, 2, 4]
linemode = "size"
[opener]
edit = [
    { run = '${EDITOR:-nvim} "$@"', desc = "editor", block = true },
]
open = [
    { run = 'xdg-open "$1"', desc = "open", for = "linux" },
    { run = 'open "$@"', desc = "open", for = "macos" },
]
extract = [
	{ run = 'ya pub extract --list "$@"', desc = "Extract here", for = "unix" },
]
[open]
rules = [
	{ name = "*/", use = "edit" },
    { mime = "text/*", use = "edit" },
    { mime = "{image,audio,video}/*", use = "open" },
    { mime = "application/pdf", use = "open" },
    { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", use = ["extract", "open"] },
    { mime = "inode/empty", use = "edit" },
	{ name = "*", use = [ "edit", "open" ] },
]
EOF
if [ ! -f "$ORIGINAL_HOME/.config/yazi/keymap.toml" ]; then
	cat > "$ORIGINAL_HOME/.config/yazi/keymap.toml" <<'EOF'
[mgr]
append_keymap = [
	{ on = [ "g", "s" ], run = "cd ~/Desktop", desc = "Go ~/Desktop" },
	{ on = [ "g", "p" ], run = "cd ~/Projects", desc = "Go ~/Projects" },
	{ on = [ "g", "o" ], run = "cd ~/Documents", desc = "Go ~/Documents" },
]
EOF
fi
