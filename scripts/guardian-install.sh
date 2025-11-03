#!/bin/bash

###############################################################################
# ORBS TEE Guardian Installation Script
#
# This script installs and configures the ORBS TEE system for guardians
# including both the enclave (Rust) and host (TypeScript) components.
#
# Usage: sudo ./guardian-install.sh
###############################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════${NC}"
}

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_header "ORBS TEE Guardian Installation"
echo ""

# Get the actual user (not root when using sudo)
ACTUAL_USER=${SUDO_USER:-$USER}
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

print_info "Installing for user: $ACTUAL_USER"
print_info "Home directory: $ACTUAL_HOME"
echo ""

###############################################################################
# Step 1: Update system and install prerequisites
###############################################################################

print_header "Step 1: Installing System Prerequisites"
echo ""

print_info "Updating package lists..."
apt-get update -qq

print_info "Installing build essentials..."
apt-get install -y -qq \
    build-essential \
    pkg-config \
    libssl-dev \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    apt-transport-https

print_status "System prerequisites installed"
echo ""

###############################################################################
# Step 2: Install Rust
###############################################################################

print_header "Step 2: Installing Rust"
echo ""

# Install Rust for the actual user (not root)
if ! sudo -u $ACTUAL_USER bash -c "command -v cargo &> /dev/null"; then
    print_info "Installing Rust toolchain..."
    sudo -u $ACTUAL_USER bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"

    # Source cargo env
    sudo -u $ACTUAL_USER bash -c "source $ACTUAL_HOME/.cargo/env"

    print_status "Rust installed: $(sudo -u $ACTUAL_USER $ACTUAL_HOME/.cargo/bin/cargo --version)"
else
    print_status "Rust already installed: $(sudo -u $ACTUAL_USER $ACTUAL_HOME/.cargo/bin/cargo --version)"
fi

echo ""

###############################################################################
# Step 3: Install Node.js
###############################################################################

print_header "Step 3: Installing Node.js"
echo ""

if ! command -v node &> /dev/null; then
    print_info "Adding NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -

    print_info "Installing Node.js 20..."
    apt-get install -y -qq nodejs

    print_status "Node.js installed: $(node --version)"
    print_status "NPM installed: $(npm --version)"
else
    print_status "Node.js already installed: $(node --version)"
fi

echo ""

###############################################################################
# Step 4: Clone or update repositories
###############################################################################

print_header "Step 4: Setting Up Repositories"
echo ""

INSTALL_DIR="$ACTUAL_HOME/orbs-tee"
mkdir -p $INSTALL_DIR
chown $ACTUAL_USER:$ACTUAL_USER $INSTALL_DIR

cd $INSTALL_DIR

# Clone enclave repo
if [ ! -d "orbs-tee-enclave-nitro" ]; then
    print_info "Cloning orbs-tee-enclave-nitro..."
    sudo -u $ACTUAL_USER git clone https://github.com/orbs-network/orbs-tee-enclave-nitro.git
    print_status "Enclave repository cloned"
else
    print_info "Updating orbs-tee-enclave-nitro..."
    cd orbs-tee-enclave-nitro
    sudo -u $ACTUAL_USER git pull
    cd ..
    print_status "Enclave repository updated"
fi

# Clone host repo
if [ ! -d "orbs-tee-host" ]; then
    print_info "Cloning orbs-tee-host..."
    sudo -u $ACTUAL_USER git clone https://github.com/orbs-network/orbs-tee-host.git
    print_status "Host repository cloned"
else
    print_info "Updating orbs-tee-host..."
    cd orbs-tee-host
    sudo -u $ACTUAL_USER git pull
    cd ..
    print_status "Host repository updated"
fi

echo ""

###############################################################################
# Step 5: Build Enclave
###############################################################################

print_header "Step 5: Building Enclave"
echo ""

cd $INSTALL_DIR/orbs-tee-enclave-nitro

print_info "Running enclave tests..."
sudo -u $ACTUAL_USER $ACTUAL_HOME/.cargo/bin/cargo test --no-default-features --quiet

test_result=$?
if [ $test_result -eq 0 ]; then
    print_status "All enclave tests passed"
else
    print_error "Enclave tests failed"
    exit 1
fi

print_info "Building enclave in release mode..."
sudo -u $ACTUAL_USER $ACTUAL_HOME/.cargo/bin/cargo build --release --no-default-features

print_info "Building price oracle example..."
sudo -u $ACTUAL_USER $ACTUAL_HOME/.cargo/bin/cargo build --release --no-default-features \
    --manifest-path examples/price-oracle/Cargo.toml

print_status "Enclave built successfully"
echo ""

###############################################################################
# Step 6: Setup Host
###############################################################################

print_header "Step 6: Setting Up Host"
echo ""

cd $INSTALL_DIR/orbs-tee-host

print_info "Installing NPM dependencies..."
sudo -u $ACTUAL_USER npm install --silent

print_info "Building TypeScript..."
sudo -u $ACTUAL_USER npm run build

# Create production config
if [ ! -f "config.production.json" ]; then
    print_info "Creating production config..."
    cat > config.production.json << 'EOF'
{
  "vsock": {
    "cid": 3,
    "port": 3000,
    "timeoutMs": 30000,
    "retryAttempts": 5,
    "retryDelayMs": 100
  },
  "l3": {
    "endpoints": [
      "https://guardian1.orbs.network",
      "https://guardian2.orbs.network"
    ],
    "timeoutMs": 30000,
    "retryAttempts": 3
  },
  "api": {
    "host": "0.0.0.0",
    "port": 8080,
    "tlsEnabled": true
  },
  "auth": {
    "enabled": true,
    "rateLimitingEnabled": true
  },
  "logging": {
    "level": "info",
    "format": "json"
  }
}
EOF
    chown $ACTUAL_USER:$ACTUAL_USER config.production.json
    print_status "Production config created"
fi

print_status "Host setup complete"
echo ""

###############################################################################
# Step 7: Create systemd services (optional)
###############################################################################

print_header "Step 7: Creating Systemd Services"
echo ""

# Create host service
cat > /etc/systemd/system/orbs-tee-host.service << EOF
[Unit]
Description=ORBS TEE Host Service
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
WorkingDirectory=$INSTALL_DIR/orbs-tee-host
Environment="NODE_ENV=production"
ExecStart=/usr/bin/node $INSTALL_DIR/orbs-tee-host/dist/index.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

print_status "Created systemd service: orbs-tee-host.service"

# Reload systemd
systemctl daemon-reload

print_info "To enable and start the host service, run:"
print_info "  sudo systemctl enable orbs-tee-host"
print_info "  sudo systemctl start orbs-tee-host"

echo ""

###############################################################################
# Step 8: Create helper scripts
###############################################################################

print_header "Step 8: Creating Helper Scripts"
echo ""

# Create start script
cat > $INSTALL_DIR/start-host.sh << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/orbs-tee-host"
npm start
EOF
chmod +x $INSTALL_DIR/start-host.sh
chown $ACTUAL_USER:$ACTUAL_USER $INSTALL_DIR/start-host.sh

# Create test script
cat > $INSTALL_DIR/test-system.sh << 'EOF'
#!/bin/bash

echo "Testing ORBS TEE System..."
echo ""

# Test enclave
echo "→ Testing enclave..."
cd "$(dirname "$0")/orbs-tee-enclave-nitro"
cargo test --no-default-features --quiet
if [ $? -eq 0 ]; then
    echo "✓ Enclave tests passed"
else
    echo "✗ Enclave tests failed"
    exit 1
fi

# Test host
echo "→ Testing host..."
cd "$(dirname "$0")/orbs-tee-host"
npm test
if [ $? -eq 0 ]; then
    echo "✓ Host tests passed"
else
    echo "✗ Host tests failed"
    exit 1
fi

echo ""
echo "✓ All tests passed!"
EOF
chmod +x $INSTALL_DIR/test-system.sh
chown $ACTUAL_USER:$ACTUAL_USER $INSTALL_DIR/test-system.sh

# Create status script
cat > $INSTALL_DIR/status.sh << 'EOF'
#!/bin/bash

echo "═══════════════════════════════════════════"
echo "  ORBS TEE System Status"
echo "═══════════════════════════════════════════"
echo ""

# Check if host service is running
if systemctl is-active --quiet orbs-tee-host; then
    echo "✓ Host service: RUNNING"
else
    echo "✗ Host service: STOPPED"
fi

# Check if API is responding
if curl -s http://localhost:8080/api/v1/health > /dev/null 2>&1; then
    echo "✓ API endpoint: RESPONDING"

    # Get health status
    health=$(curl -s http://localhost:8080/api/v1/health | jq -r '.status' 2>/dev/null)
    echo "  Status: $health"
else
    echo "✗ API endpoint: NOT RESPONDING"
fi

echo ""
echo "To view logs: sudo journalctl -u orbs-tee-host -f"
echo "To restart: sudo systemctl restart orbs-tee-host"
EOF
chmod +x $INSTALL_DIR/status.sh
chown $ACTUAL_USER:$ACTUAL_USER $INSTALL_DIR/status.sh

print_status "Helper scripts created"
print_info "  $INSTALL_DIR/start-host.sh - Start host manually"
print_info "  $INSTALL_DIR/test-system.sh - Run all tests"
print_info "  $INSTALL_DIR/status.sh - Check system status"

echo ""

###############################################################################
# Installation Complete
###############################################################################

print_header "Installation Complete!"
echo ""
echo "ORBS TEE System has been installed successfully."
echo ""
echo "Installation location: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo ""
echo "1. Review configuration:"
echo "   ${YELLOW}nano $INSTALL_DIR/orbs-tee-host/config.production.json${NC}"
echo ""
echo "2. Test the installation:"
echo "   ${YELLOW}$INSTALL_DIR/test-system.sh${NC}"
echo ""
echo "3. Start the host service:"
echo "   ${YELLOW}sudo systemctl enable orbs-tee-host${NC}"
echo "   ${YELLOW}sudo systemctl start orbs-tee-host${NC}"
echo ""
echo "4. Check status:"
echo "   ${YELLOW}$INSTALL_DIR/status.sh${NC}"
echo ""
echo "5. View logs:"
echo "   ${YELLOW}sudo journalctl -u orbs-tee-host -f${NC}"
echo ""
echo "For AWS Nitro Enclave deployment, see:"
echo "  $INSTALL_DIR/orbs-tee-host/DEPLOYMENT.md"
echo ""
print_status "Installation completed successfully!"
echo ""
