#!/usr/bin/env bash

set -e

# arm64
ARCH=x86_64 
GOARCH=linux-amd64
YAZIFILE=yazi-x86_64-unknown-linux-gnu.deb
BTMARCH=1_amd64

apt update && apt upgrade -y

INSTALL_PKGS="sudo curl wget git htop tmux ffmpeg 7zip unzip tar jq fd-find ripgrep tree pkg-config net-tools iputils-ping build-essential ninja-build gettext cmake openssl ssh openssh-server openssh-client ca-certificates"

apt install -y $INSTALL_PKGS

mkdir -p ~/Downloads
mkdir -p ~/Documents
mkdir -p ~/Desktop

cd ~/Downloads

if ! command -v fastfetch >/dev/null 2>&1; then
    wget -O fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
    apt install -y ./fastfetch-linux-amd64.deb
fi

# zsh
apt install -y zsh
chsh -s $(which zsh)

git clone https://github.com/nlkli/dotfiles
cd dotfiles
chmod +x syncout.sh
./syncout.sh

cd ~/Downloads

if ! command -v nvim >/dev/null 2>&1; then
    git clone --depth 1 https://github.com/neovim/neovim
    cd neovim
    make CMAKE_BUILD_TYPE=RelWithDebInfo
    cd build && cpack -G DEB && sudo dpkg -i nvim-linux-$ARCH.deb
    cd ~/Downloads

    apt install -y tree-sitter-cli
fi

# yazi
if ! command -v yazi >/dev/null 2>&1; then
	wget -q -O $YAZIFILE https://github.com/sxyazi/yazi/releases/latest/download/$YAZIFILE
    apt install -y ./$YAZIFILE
fi

# rust
if ! command -v rustc >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    rg -q 'export PATH=$PATH:$HOME/.cargo/bin' ~/.zshrc || \
        echo 'export PATH=$PATH:$HOME/.cargo/bin' >> ~/.zshrc
    export PATH="$HOME/.cargo/bin:$PATH"
    rustup update
fi

# https://github.com/ClementTsang/bottom
if ! command -v btm >/dev/null 2>&1; then
    btmversion=$(curl -s "https://api.github.com/repos/ClementTsang/bottom/releases/latest" | jq -r .tag_name)
    btmfile=bottom_$btmversion-$BTMARCH.deb

    wget -q https://github.com/ClementTsang/bottom/releases/download/$btmversion/$btmfile
    apt install -y ./$btmfile
fi

# FIXME
# golang
if ! command -v go >/dev/null 2>&1; then
    goversion=$(curl -s "https://go.dev/dl/?mode=json" | jq -r '.[0].version')
    gofile=$goversion.$GOARCH.tar.gz

    wget -q "https://go.dev/dl/$gofile"
    rm -rf /usr/local/go && tar -C /usr/local -xzf $gofile

    rg -q 'export PATH=$PATH:/usr/local/go/bin' ~/.zshrc || \
        echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
fi
