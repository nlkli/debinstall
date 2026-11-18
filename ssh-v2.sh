#!/usr/bin/env bash
set -euo pipefail

# Prompt for SSH port (default 22)
read -rp "Enter SSH port [22]: " SSH_PORT
SSH_PORT="${SSH_PORT:-22}"

# Validate port is numeric
if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]]; then
    echo "Invalid port." >&2
    exit 1
fi

# Prompt for target user
read -rp "Enter username to add SSH key for: " TARGET_USER

if ! id "$TARGET_USER" &>/dev/null; then
    echo "User '$TARGET_USER' does not exist." >&2
    exit 1
fi

# Prompt for public key
read -rp "Paste public key: " PUBKEY
if [[ -z "$PUBKEY" ]]; then
    echo "Public key cannot be empty." >&2
    exit 1
fi

# Add public key to user's authorized_keys
USER_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
sudo mkdir -p "$USER_HOME/.ssh"
echo "$PUBKEY" | sudo tee -a "$USER_HOME/.ssh/authorized_keys" >/dev/null
sudo chown -R "$TARGET_USER:$TARGET_USER" "$USER_HOME/.ssh"
sudo chmod 700 "$USER_HOME/.ssh"
sudo chmod 600 "$USER_HOME/.ssh/authorized_keys"

# Backup and write minimal industry-standard sshd_config
sudo cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak.$(date +%s)"

sudo tee /etc/ssh/sshd_config >/dev/null <<EOF
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
PermitEmptyPasswords no
MaxAuthTries 3
X11Forwarding no
AllowTcpForwarding no
ClientAliveInterval 300
ClientAliveCountMax 2
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# Validate config before restarting
sudo sshd -t

# Restart SSH
sudo systemctl restart ssh

echo "SSH configured on port $SSH_PORT. Key added for '$TARGET_USER'. Keep current session open and test in a new terminal before closing."
