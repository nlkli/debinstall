#!/usr/bin/env bash
set -euo pipefail

# Install zsh on Debian
sudo apt-get update
sudo apt-get install -y zsh

# Add zsh to /etc/shells if missing
ZSH_PATH="$(command -v zsh)"
grep -qx "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells

# Set zsh as default shell for current user
sudo chsh -s "$ZSH_PATH" "$USER"

echo "zsh installed. Default shell for $USER set to $ZSH_PATH. Re-login to apply."
