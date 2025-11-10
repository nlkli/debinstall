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

sudo timedatectl set-timezone Europe/Moscow

sudo touch /etc/sysctl.conf
grep -q "^net.core.default_qdisc=fq" /etc/sysctl.conf || echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf >/dev/null
grep -q "^net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf || echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf >/dev/null
sudo sysctl -p >/dev/null

if [[ $(swapon --show | wc -l) -eq 0 ]]; then
    swapfilesize=$(inputv "Введите размер файла подкачки (например: 512M, 1G): ")
    sudo fallocate -l "$swapfilesize" /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    grep -q "/swapfile" /etc/fstab || echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab >/dev/null
fi

newhostname=$(inputv "Введите имя хоста: ")
sudo hostnamectl set-hostname "$newhostname"

read -p "Сменить пароль пользователя root? [y/N]: " changepass
if [[ "$changepass" == "y" || "$changepass" == "Y" ]]; then
    sudo passwd
fi

read -p "Настроить правила фаервола UFW? [y/N]: " configureufw
if [[ "$configureufw" == "y" || "$configureufw" == "Y" ]]; then
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing

    startport=$(inputport "Введите начальный порт (1024-65535): ")

    while true; do
        read -p "Введите количество портов для открытия: " portcount
        if ! [[ "$portcount" =~ ^[0-9]+$ ]] || [ "$portcount" -lt 1 ]; then
            echo "Ошибка: Введите положительное число"
            continue
        fi
        endport=$((startport + portcount - 1))
        if [ "$endport" -gt 65535 ]; then
            echo "Ошибка: Диапазон портов превышает максимальный (65535)"
            continue
        fi
        break
    done

    ufw allow $startport:$endport/tcp
    ufw allow $startport:$endport/udp
fi
