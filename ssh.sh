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

mkdir -p ~/.ssh
chmod 700 ~/.ssh

username=$(whoami)

pubsshkey=$(inputv "Введите публичный SSH-ключ для пользователя $username: ")

echo "$pubsshkey" > ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys

sshport=$(inputport "Введите SSH-порт (от 1024 до 65535): ")

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

cat > /etc/ssh/sshd_config <<EOF
Port $sshport
Protocol 2
PermitRootLogin no
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
LoginGraceTime 90s
MaxAuthTries 3
MaxSessions 3
EOF

sshd -t

systemctl restart ssh || systemctl start ssh

ufw allow ssh
