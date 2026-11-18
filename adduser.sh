#!/usr/bin/env bash
set -euo pipefail

# Prompt for username
read -rp "Enter username: " USERNAME

# Validate input
if [[ -z "$USERNAME" ]]; then
    echo "Username cannot be empty." >&2
    exit 1
fi

if id "$USERNAME" &>/dev/null; then
    echo "User '$USERNAME' already exists." >&2
    exit 1
fi

# Create user with home dir
sudo adduser --gecos "" "$USERNAME"

# Add to sudo group
sudo usermod -aG sudo "$USERNAME"

echo "User '$USERNAME' created and added to sudo group."
