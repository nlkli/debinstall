#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

if ! systemctl list-unit-files --type=service | grep -q 3proxy.service; then
    git clone --depth 1 https://github.com/nikita55612/ProxyHub
	cd ProxyHub
	chmod +x install.sh
	./install.sh
	cd ..
else
	systemctl restart proxyhub.service || systemctl start proxyhub.service
fi
