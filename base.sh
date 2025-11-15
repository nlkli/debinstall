#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

apt update && apt upgrade -y
apt dist-upgrade -y

INSTALL="vim git curl wget vnstat ufw htop unzip tar file jq fd-find ripgrep tree net-tools traceroute iputils-ping build-essential openssl sudo man-db ssh openssh-server openssh-client ca-certificates dnsutils gnupg"

apt install -y $INSTALL

systemctl enable ssh
systemctl start ssh

systemctl enable man-db
systemctl start man-db

if ! command -v fastfetch >/dev/null 2>&1; then
    wget -O fastfetch-linux-amd64.deb https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.deb
    apt install -y ./fastfetch-linux-amd64.deb
    rm -f fastfetch-linux-amd64.deb
fi

apt update && apt upgrade -y
apt dist-upgrade -y
apt autoremove -y
apt autoclean
