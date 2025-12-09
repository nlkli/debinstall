#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

validateport() {
    [[ "$1" =~ ^[0-9]+$ ]] && [ "$1" -ge 1024 ] && [ "$1" -le 65535 ]
}

inputport() {
    local port=""
    while ! validateport "$port"; do
        read -p "$1" port
    done
    echo "$port"
}

unzipf="gokapi-linux_amd64"

mkdir -p /opt/gokapi
wget -O gokapi.zip https://github.com/Forceu/Gokapi/releases/latest/download/gokapi-linux_amd64.zip
unzip gokapi.zip
mv "$unzipf" /opt/gokapi/gokapi
rm -f gokapi.zip
chmod +x /opt/gokapi/gokapi

port=$(inputport "Введите порт (1024-65535): ")

/opt/gokapi/gokapi --port "$port" --install-service
systemctl enable --now gokapi
