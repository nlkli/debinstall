#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

chmod +x ./*.sh

"./base.sh"
"./system.sh"
"./vim.sh"
"./yazi.sh"
"./golang.sh"
"./3proxy.sh"
"./xraycore.sh"

source "./newuser.sh"

abcrepodir=$(dirname "$(realpath "$0")")

su - "$NEW_USERNAME" -c "bash '$abcrepodir/ssh.sh'"
su - "$NEW_USERNAME" -c "bash '$abcrepodir/vim.sh'"
su - "$NEW_USERNAME" -c "bash '$abcrepodir/yazi.sh'"
su - "$NEW_USERNAME" -c "bash '$abcrepodir/golang.sh'"
