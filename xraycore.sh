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

if ! command -v xray >/dev/null 2>&1; then
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
fi

hostname=$(hostname)

serverip=$(curl -s ifconfig.me || curl -s ipinfo.io/ip)

xrayconfigpath=/usr/local/etc/xray/config.json
xraylinksfile=/usr/local/etc/xray/links

if [ ! -f "$xraylinksfile" ]; then
	cat > "$xrayconfigpath" <<EOF
{
  "log": {
    "loglevel": "none"
  },
  "inbounds": [],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF
fi

n=0

new_vless_reality_inbound() {
    local port=$1
    local desthost=$2
    local keys=$(xray x25519)
    local privatekey=$(echo "$keys" | awk '/PrivateKey:/ {print $2}')
    local publickey=$(echo "$keys" | awk '/Password:/ {print $2}')

    local inboundjson=$(jq -n \
        --arg port "$port" \
        --arg desthost "$desthost" \
        --arg privatekey "$privatekey" \
        '{
            "listen": "0.0.0.0",
            "port": ($port | tonumber),
            "protocol": "vless",
            "settings": {
                "clients": [],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "tcp",
                "security": "reality",
                "realitySettings": {
                    "dest": ($desthost + ":443"),
                    "xver": 0,
                    "show": false,
                    "serverNames": [$desthost, ("www." + $desthost)],
                    "privateKey": $privatekey,
                    "shortIds": []
                }
            }
        }')

    local userscount=""
    while ! [[ "$userscount" =~ ^[0-9]+$ ]] || [ "$userscount" -le 0 ]; do
        userscount=$(inputv "Введите количество пользователей для добавления: ")
    done

    for ((i=1; i<=userscount; i++)); do
        n=$((n+1))
        local username="${hostname}user$n"
        local uuid=$(xray uuid)
        local shortid=$(openssl rand -hex 4)

        inboundjson=$(echo "$inboundjson" | jq \
            --arg username "$username" \
            --arg uuid "$uuid" \
            --arg shortid "$shortid" \
            '.settings.clients += [{"id": $uuid, "email": $username, "flow": "xtls-rprx-vision"}] |
             .streamSettings.realitySettings.shortIds += [$shortid]')

        local link="vless://${uuid}@${serverip}:${port}?encryption=none&flow=xtls-rprx-vision&security=reality&sni=${desthost}&fp=chrome&pbk=${publickey}&sid=${shortid}&type=tcp#${username}"

		echo "$link" >> "$xraylinksfile"
    done

    echo "$inboundjson"
}

while true; do
    read -p "Добавить подключение для нового порта? (y/n): " addmore
    [[ "$addmore" =~ ^[yY]$ ]] || break

    port=$(inputport "Введите порт (1024-65535): ")
    desthost=$(inputv "Введите desthost (например, github.com): ")

    inboundjson=$(new_vless_reality_inbound "$port" "$desthost")

    jq --argjson inbound "$inboundjson" '.inbounds += [$inbound]' "$xrayconfigpath" > xrayconfig.tmp
	mv xrayconfig.tmp "$xrayconfigpath"
done

cat "$xrayconfigpath"
chmod 600 "$xrayconfigpath"

systemctl restart xray || systemctl start xray
