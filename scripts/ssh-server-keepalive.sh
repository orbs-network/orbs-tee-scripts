#!/bin/bash
# Configure SSH server to keep connections alive
# Run this with: sudo ./ssh-server-keepalive.sh

set -e

echo "Configuring SSH server keepalive settings..."

# Backup current config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)

# Configure SSH server to send keepalive packets
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 120/' /etc/ssh/sshd_config
sudo sed -i 's/#TCPKeepAlive yes/TCPKeepAlive yes/' /etc/ssh/sshd_config

# If the lines don't exist, append them
if ! grep -q "^ClientAliveInterval" /etc/ssh/sshd_config; then
    echo "ClientAliveInterval 60" | sudo tee -a /etc/ssh/sshd_config
fi

if ! grep -q "^ClientAliveCountMax" /etc/ssh/sshd_config; then
    echo "ClientAliveCountMax 120" | sudo tee -a /etc/ssh/sshd_config
fi

if ! grep -q "^TCPKeepAlive" /etc/ssh/sshd_config; then
    echo "TCPKeepAlive yes" | sudo tee -a /etc/ssh/sshd_config
fi

echo "Testing SSH configuration..."
sudo sshd -t

echo "Restarting SSH service..."
sudo systemctl restart sshd

echo "✅ SSH server keepalive configured!"
echo "   - Sends keepalive every 60 seconds"
echo "   - Allows up to 120 missed responses (2 hours)"
echo ""
echo "Your SSH session should now stay alive much longer."
