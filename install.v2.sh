#!/usr/bin/env bash

#TODO

set -e

NEW_USERNAME=""

apt update && apt upgrade -y

INSTALL_PKGS="sudo curl wget git vim gnupg ncurses-term vnstat ufw htop unzip tar file jq fd-find ripgrep tree net-tools iputils-ping build-essential openssl man-db ssh openssh-server openssh-client ca-certificates dnsutils"

apt install -y $INSTALL_PKGS

systemctl enable ssh
systemctl start ssh

systemctl enable man-db
systemctl start man-db

if ! command -v fastfetch >/dev/null 2>&1; then
    wget -O fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
    apt install -y ./fastfetch-linux-amd64.deb
    rm -f fastfetch-linux-amd64.deb
fi

if [ -n "$NEW_USERNAME" ]; then

fi
