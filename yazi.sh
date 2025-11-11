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
[opener]
edit = [
    { run = '${EDITOR:-vim} "$@"', desc = "$EDITOR", block = true },
]
open = [
    { run = 'xdg-open "$1"', desc = "open", for = "linux" },
    { run = 'open "$@"', desc = "open", for = "macos" },
]
[open]
rules = [
	{ mime = "*/", use = "edit" },
    { mime = "text/*", use = "edit" },
	# { name = "*", use = "open" },
]
EOF
fi
