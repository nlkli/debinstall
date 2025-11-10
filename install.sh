#!/bin/bash

set -e

[[ $EUID -eq 0 ]] || exec sudo "$0" "$@"

repodir=$(dirname "$0")

chmod +x "$repodir"/*.sh

"$repodir/base.sh"
"$repodir/system.sh"
"$repodir/vim.sh"
"$repodir/yazi.sh"
"$repodir/golang.sh"
"$repodir/3proxy.sh"
"$repodir/xraycore.sh"

source "$repodir/newuser.sh"
su - "$NEW_USERNAME" -c "
    '$repodir/ssh.sh' &&
    '$repodir/vim.sh' &&
    '$repodir/yazi.sh' &&
    '$repodir/golang.sh'
"
