#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

inputv() {
    local v=""
    while [[ -z "$v" ]]; do
        read -p "$1" v
    done
    echo "$v"
}

newusername=$(inputv "Введите имя нового пользователя: ")

if ! id "$newusername" &>/dev/null; then
    adduser "$newusername"
    usermod -aG sudo "$newusername"
fi

export NEW_USERNAME="$newusername"
