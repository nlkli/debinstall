#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$(whoami)" "$HOME" "$@"
ORIG_USER="${1:-$(whoami)}"
ORIG_HOME="${2:-$HOME}"

export PATH=$PATH:/usr/local/go/bin

if ! command -v go >/dev/null 2>&1; then
	# GO_VERSION=go1.25.3
	# GO_ARCHIVE="$GO_VERSION".linux-amd64.tar.gz

	GO_STABLE_VERSION=$(curl -s https://go.dev/dl/?mode=json | grep -m 1 '"version":' | grep -oP '"version": "\K[^"]+')
	GO_ARCHIVE="$GO_STABLE_VERSION.linux-amd64.tar.gz"

	wget "https://go.dev/dl/${GO_ARCHIVE}" -O "$GO_ARCHIVE"

	if [ -d /usr/local/go ]; then
		rm -rf /usr/local/go
	fi

	rm -rf /usr/local/go 2> /dev/null
	tar -C /usr/local -xzf "$GO_ARCHIVE"
	rm -f "$GO_ARCHIVE"
fi

if ! grep -q "/usr/local/go/bin" "$ORIG_HOME/.profile"; then
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$ORIG_HOME/.profile"
fi
