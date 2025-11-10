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

hostname=$(hostname)

serverip=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)

proxyversion=0.9.5

if ! command -v 3proxy >/dev/null 2>&1; then
    wget -O 3proxy.tar.gz https://github.com/z3APA3A/3proxy/archive/$proxyversion.tar.gz

    tar -xzf 3proxy.tar.gz
    mv 3proxy-${proxyversion} 3proxy
    rm 3proxy.tar.gz

    cd 3proxy
    make -f Makefile.Linux
    cd ..

    mkdir -p /etc/3proxy /var/log/3proxy

    if [ -f 3proxy/src/3proxy ]; then
        cp 3proxy/src/3proxy /usr/local/bin/
    elif [ -f 3proxy/bin/3proxy ]; then
        cp 3proxy/bin/3proxy /usr/local/bin/
    else
        echo "Бинарник 3proxy не найден после сборки"
        exit 1
    fi

    rm -rf 3proxy
fi

if [ ! -f "/etc/3proxy/3proxy.cfg" ]; then
    cat > /etc/3proxy/3proxy.cfg <<EOF
nscache 65536
auth strong
EOF
fi

3proxylinksfile=/etc/3proxy/links

n=0
while true; do
    read -p "Добавить http proxy пользователей на новом порту? (y/n): " addmore
    [[ "$addmore" =~ ^[yY]$ ]] || break

    port=$(inputport "Введите порт (1024-65535): ")

    local userscount=""
    while ! [[ "$userscount" =~ ^[0-9]+$ ]] || [ "$userscount" -le 0 ]; do
        userscount=$(inputv "Введите количество пользователей для добавления: ")
    done

    for ((i=1; i<=userscount; i++)); do
        n=$((n+1))
        username="${hostname}user$n"
        password=$(openssl rand -base64 12 | tr -d '/+' | cut -c1-12)
        echo "users $username:CL:$password" >> /etc/3proxy/3proxy.cfg
        echo "http://$username:$password@$serverip:$port" >> "$3proxylinksfile"
    done

    cat >> /etc/3proxy/3proxy.cfg <<EOF
allow *
proxy -n -p$port -a
flush
EOF
done

while true; do
    read -p "Добавить socks proxy пользователей на новом порту? (y/n): " addmore
    [[ "$addmore" =~ ^[yY]$ ]] || break

    port=$(inputport "Введите порт (1024-65535): ")

    local userscount=""
    while ! [[ "$userscount" =~ ^[0-9]+$ ]] || [ "$userscount" -le 0 ]; do
        userscount=$(inputv "Введите количество пользователей для добавления: ")
    done

    for ((i=1; i<=userscount; i++)); do
        n=$((n+1))
        username="${hostname}user$n"
        password=$(openssl rand -base64 12 | tr -d '/+' | cut -c1-12)
        echo "users $username:CL:$password" >> /etc/3proxy/3proxy.cfg
		echo "socks5://$username:$password@$serverip:$port" >> "$3proxylinksfile"
    done

    cat >> /etc/3proxy/3proxy.cfg <<EOF
allow *
socks -p$port
flush
EOF
done

chmod 600 /etc/3proxy/3proxy.cfg

if ! systemctl list-unit-files --type=service | grep -q 3proxy.service; then
    cat > /etc/systemd/system/3proxy.service <<EOF
[Unit]
Description=3proxy Proxy Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/3proxy /etc/3proxy/3proxy.cfg
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable 3proxy
fi

systemctl restart 3proxy || systemctl start 3proxy
