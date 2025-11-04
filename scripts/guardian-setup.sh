#!/bin/bash
set -e

#############################################################################
# ORBS TEE Guardian Setup Script
#
# This script sets up the complete ORBS TEE system for a guardian node:
# - Installs dependencies (Rust, Node.js)
# - Builds enclave and host
# - Configures systemd services for auto-start on boot
# - Starts the services
#
# Usage: sudo ./guardian-setup.sh
#############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="/home/ubuntu"
ENCLAVE_DIR="$INSTALL_DIR/orbs-tee-enclave-nitro"
HOST_DIR="$INSTALL_DIR/orbs-tee-host"
PRICE_ORACLE_DIR="$ENCLAVE_DIR/examples/price-oracle-unix"
SOCKET_PATH="/tmp/enclave.sock"
SERVICE_USER="ubuntu"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}ORBS TEE Guardian Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

#############################################################################
# Step 1: Check if running as root
#############################################################################
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: Please run as root (use sudo)${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/10] Checking system...${NC}"
echo "Platform: $(uname -a)"
echo "User: $SERVICE_USER"
echo ""

#############################################################################
# Step 2: Install system dependencies
#############################################################################
echo -e "${YELLOW}[2/10] Installing system dependencies...${NC}"
apt-get update -qq || true
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    tmux 2>&1 | grep -E "(Setting up|already)" || true

echo -e "${GREEN}✓ System dependencies installed${NC}"
echo ""

#############################################################################
# Step 3: Install Rust (if not present)
#############################################################################
echo -e "${YELLOW}[3/10] Setting up Rust...${NC}"

if ! sudo -u $SERVICE_USER bash -c 'source /home/ubuntu/.cargo/env 2>/dev/null && command -v rustc' > /dev/null 2>&1; then
    echo "Installing Rust..."
    sudo -u $SERVICE_USER bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'
    sudo -u $SERVICE_USER bash -c 'source /home/ubuntu/.cargo/env && rustup default stable'
else
    echo "Rust already installed"
fi

RUST_VERSION=$(sudo -u $SERVICE_USER bash -c 'source /home/ubuntu/.cargo/env && rustc --version')
echo -e "${GREEN}✓ Rust: $RUST_VERSION${NC}"
echo ""

#############################################################################
# Step 4: Install Node.js (if not present)
#############################################################################
echo -e "${YELLOW}[4/10] Setting up Node.js...${NC}"

if ! command -v node > /dev/null 2>&1; then
    echo "Installing Node.js 20.x..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - > /dev/null 2>&1
    apt-get install -y nodejs 2>&1 | grep -E "(Setting up|already)" || true
else
    echo "Node.js already installed"
fi

NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
echo -e "${GREEN}✓ Node.js: $NODE_VERSION${NC}"
echo -e "${GREEN}✓ npm: $NPM_VERSION${NC}"
echo ""

#############################################################################
# Step 5: Verify code directories exist
#############################################################################
echo -e "${YELLOW}[5/10] Verifying code directories...${NC}"

if [ ! -d "$ENCLAVE_DIR" ]; then
    echo -e "${RED}ERROR: Enclave directory not found: $ENCLAVE_DIR${NC}"
    echo "Please ensure the code is checked out to $INSTALL_DIR"
    exit 1
fi

if [ ! -d "$HOST_DIR" ]; then
    echo -e "${RED}ERROR: Host directory not found: $HOST_DIR${NC}"
    echo "Please ensure the code is checked out to $INSTALL_DIR"
    exit 1
fi

echo -e "${GREEN}✓ Enclave: $ENCLAVE_DIR${NC}"
echo -e "${GREEN}✓ Host: $HOST_DIR${NC}"
echo ""

#############################################################################
# Step 6: Build enclave
#############################################################################
echo -e "${YELLOW}[6/10] Building enclave (price-oracle-unix)...${NC}"

cd "$PRICE_ORACLE_DIR"

# Clean previous builds
sudo -u $SERVICE_USER bash -c "source /home/$SERVICE_USER/.cargo/env && cargo clean" 2>/dev/null || true

# Build
echo "Building (this may take a few minutes)..."
sudo -u $SERVICE_USER bash -c "source /home/$SERVICE_USER/.cargo/env && cargo build --no-default-features"

if [ ! -f "target/debug/price-oracle-unix" ]; then
    echo -e "${RED}ERROR: Build failed - binary not found${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Enclave built: $PRICE_ORACLE_DIR/target/debug/price-oracle-unix${NC}"
echo ""

#############################################################################
# Step 7: Build host
#############################################################################
echo -e "${YELLOW}[7/10] Building host...${NC}"

cd "$HOST_DIR"

# Install dependencies
echo "Installing npm dependencies..."
sudo -u $SERVICE_USER npm install 2>&1 | grep -E "(added|up to date)" || true

# Build TypeScript
echo "Building TypeScript..."
sudo -u $SERVICE_USER npm run build 2>&1 | grep -E "(Successfully|tsc)" || true

# Always create config for guardian setup (overwrites existing)
echo "Creating guardian config.json..."
sudo -u $SERVICE_USER cat > config.json <<'EOF'
{
  "vsock": {
    "cid": 3,
    "port": 3000,
    "timeoutMs": 30000,
    "retryAttempts": 5,
    "retryDelayMs": 100,
    "socketPath": "/tmp/enclave.sock"
  },
  "l3": {
    "endpoint": "http://localhost:3001",
    "timeoutMs": 30000,
    "retryAttempts": 3
  },
  "api": {
    "host": "0.0.0.0",
    "port": 8080,
    "tlsEnabled": false
  },
  "auth": {
    "enabled": false,
    "rateLimitingEnabled": false
  },
  "logging": {
    "level": "info",
    "format": "json"
  }
}
EOF

echo -e "${GREEN}✓ Host built${NC}"
echo -e "${GREEN}✓ Config: $HOST_DIR/config.json${NC}"
echo ""

#############################################################################
# Step 8: Install systemd services
#############################################################################
echo -e "${YELLOW}[8/10] Installing systemd services...${NC}"

# Stop existing services if running
systemctl stop orbs-tee-host.service 2>/dev/null || true
systemctl stop orbs-tee-enclave.service 2>/dev/null || true

# Copy service files
cp "$INSTALL_DIR/orbs-tee-enclave.service" /etc/systemd/system/
cp "$INSTALL_DIR/orbs-tee-host.service" /etc/systemd/system/

# Set permissions
chmod 644 /etc/systemd/system/orbs-tee-enclave.service
chmod 644 /etc/systemd/system/orbs-tee-host.service

# Reload systemd
systemctl daemon-reload

# Enable services (auto-start on boot)
systemctl enable orbs-tee-enclave.service
systemctl enable orbs-tee-host.service

echo -e "${GREEN}✓ Services installed and enabled${NC}"
echo -e "  - orbs-tee-enclave.service"
echo -e "  - orbs-tee-host.service"
echo ""

#############################################################################
# Step 9: Start services
#############################################################################
echo -e "${YELLOW}[9/10] Starting services...${NC}"

# Clean up old socket
rm -f "$SOCKET_PATH"

# Start enclave
echo "Starting enclave..."
systemctl start orbs-tee-enclave.service

# Wait for enclave socket
echo "Waiting for enclave to be ready..."
for i in $(seq 1 30); do
    if [ -S "$SOCKET_PATH" ]; then
        echo -e "${GREEN}✓ Enclave socket ready${NC}"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo -e "${RED}ERROR: Enclave socket not created${NC}"
        journalctl -u orbs-tee-enclave.service -n 50 --no-pager
        exit 1
    fi
done

# Start host
echo "Starting host..."
systemctl start orbs-tee-host.service

# Wait for host to be ready
echo "Waiting for host to be ready..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:8080/api/v1/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Host API ready${NC}"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        echo -e "${RED}ERROR: Host API not responding${NC}"
        journalctl -u orbs-tee-host.service -n 50 --no-pager
        exit 1
    fi
done

echo ""

#############################################################################
# Step 10: Verify and display status
#############################################################################
echo -e "${YELLOW}[10/10] Verifying installation...${NC}"
echo ""

# Get public key from enclave
HEALTH_RESPONSE=$(curl -s http://localhost:8080/api/v1/health 2>/dev/null || echo "{}")
PUBLIC_KEY=$(echo "$HEALTH_RESPONSE" | jq -r '.enclave.publicKey // "unknown"')

# Get public IP
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "unknown")

# Service status
ENCLAVE_STATUS=$(systemctl is-active orbs-tee-enclave.service)
HOST_STATUS=$(systemctl is-active orbs-tee-host.service)

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}INSTALLATION COMPLETE!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Services Status:${NC}"
echo -e "  Enclave: $ENCLAVE_STATUS"
echo -e "  Host:    $HOST_STATUS"
echo ""
echo -e "${GREEN}Enclave Public Key:${NC}"
echo -e "  $PUBLIC_KEY"
echo ""
echo -e "${GREEN}API Access:${NC}"
echo -e "  Local:  http://localhost:8080"
echo -e "  Remote: http://$PUBLIC_IP:8080"
echo ""
echo -e "${GREEN}Quick Test:${NC}"
echo -e "  curl http://localhost:8080/api/v1/health"
echo ""
echo -e "${GREEN}Service Management:${NC}"
echo -e "  systemctl status orbs-tee-enclave"
echo -e "  systemctl status orbs-tee-host"
echo -e "  systemctl restart orbs-tee-enclave"
echo -e "  systemctl restart orbs-tee-host"
echo ""
echo -e "${GREEN}Logs:${NC}"
echo -e "  journalctl -u orbs-tee-enclave -f"
echo -e "  journalctl -u orbs-tee-host -f"
echo ""
echo -e "${YELLOW}Note: Services will auto-start on system boot${NC}"
echo ""

# Save installation info
cat > "$INSTALL_DIR/installation-info.json" <<EOF
{
  "installed_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "public_key": "$PUBLIC_KEY",
  "public_ip": "$PUBLIC_IP",
  "enclave_version": "$(cd $ENCLAVE_DIR && git describe --tags 2>/dev/null || echo 'unknown')",
  "host_version": "$(cd $HOST_DIR && git describe --tags 2>/dev/null || echo 'unknown')",
  "rust_version": "$RUST_VERSION",
  "node_version": "$NODE_VERSION"
}
EOF

chown $SERVICE_USER:$SERVICE_USER "$INSTALL_DIR/installation-info.json"

echo -e "${GREEN}Installation info saved to: installation-info.json${NC}"
echo ""
