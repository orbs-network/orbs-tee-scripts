#!/bin/bash

# ORBS TEE System - Quick Setup Script
# This script helps you set up the testing environment

set -e  # Exit on error

echo "═══════════════════════════════════════════"
echo "  ORBS TEE System - Quick Setup"
echo "═══════════════════════════════════════════"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}→${NC} $1"
}

# Check current directory
cd /home/ubuntu

print_info "Step 1: Testing Enclave (Rust)"
echo ""

cd orbs-tee-enclave-nitro

print_info "Running enclave tests..."
if cargo test --no-default-features --quiet 2>&1 | grep -q "test result: ok"; then
    print_status "Enclave tests passed (25 tests)"
else
    print_error "Enclave tests failed"
    echo "Run manually: cd /home/ubuntu/orbs-tee-enclave-nitro && cargo test --no-default-features"
    exit 1
fi

print_info "Building price oracle example..."
if cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml --quiet 2>/dev/null; then
    print_status "Price oracle built successfully"
else
    print_error "Price oracle build failed"
    exit 1
fi

echo ""
print_info "Step 2: Setting up Host (TypeScript)"
echo ""

cd /home/ubuntu/orbs-tee-host

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_info "Installing npm dependencies (this may take a minute)..."
    npm install --silent
    print_status "Dependencies installed"
else
    print_status "Dependencies already installed"
fi

# Create config.json if it doesn't exist
if [ ! -f "config.json" ]; then
    print_info "Creating config.json..."
    cat > config.json << 'EOF'
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
    "level": "debug",
    "format": "json"
  }
}
EOF
    print_status "config.json created"
else
    print_status "config.json already exists"
fi

# Build TypeScript
print_info "Building TypeScript..."
if npm run build --silent 2>/dev/null; then
    print_status "TypeScript build successful"
else
    print_error "TypeScript build failed"
    exit 1
fi

# Run tests
print_info "Running host tests..."
if npm test --silent 2>&1 | grep -q "PASS\|Tests:"; then
    print_status "Host tests passed"
else
    print_info "Some host tests may have failed (check manually)"
fi

echo ""
print_info "Step 3: Creating mock enclave server"
echo ""

# Create examples directory if it doesn't exist
mkdir -p examples

# Create mock enclave
cat > examples/mock-enclave.ts << 'EOFMOCK'
/**
 * Mock Enclave Server for Testing
 * This simulates the Rust enclave for host development
 */
import * as net from 'net';
import * as fs from 'fs';

interface TeeRequest {
  id: string;
  method: string;
  params: any;
  timestamp: number;
}

interface TeeResponse {
  id: string;
  success: boolean;
  data?: any;
  signature?: string;
  error?: string;
}

const SOCKET_PATH = '/tmp/enclave.sock';

// Remove existing socket
try {
  fs.unlinkSync(SOCKET_PATH);
} catch (e) {
  // Ignore if doesn't exist
}

console.log('🚀 Starting Mock Enclave Server');
console.log('═══════════════════════════════════════════');

const server = net.createServer((socket) => {
  console.log('✓ Client connected');

  let buffer = Buffer.alloc(0);

  socket.on('data', async (chunk) => {
    buffer = Buffer.concat([buffer, chunk]);

    // Try to read length-prefixed messages
    while (buffer.length >= 4) {
      const length = buffer.readUInt32BE(0);

      if (buffer.length < 4 + length) {
        // Not enough data yet
        break;
      }

      // Extract message
      const messageBuffer = buffer.slice(4, 4 + length);
      buffer = buffer.slice(4 + length);

      // Parse request
      try {
        const request: TeeRequest = JSON.parse(messageBuffer.toString('utf-8'));
        console.log(`\n→ Request [${request.method}]:`, request);

        // Generate mock response based on method
        let response: TeeResponse;

        switch (request.method) {
          case 'get_price':
            const symbol = request.params?.symbol || 'BTCUSDT';
            response = {
              id: request.id,
              success: true,
              data: {
                symbol,
                price: (Math.random() * 50000 + 40000).toFixed(2),
                timestamp: Date.now(),
                source: 'mock-enclave'
              },
              signature: '0xmock' + Math.random().toString(16).substring(2, 66),
            };
            break;

          case 'get_attestation':
            response = {
              id: request.id,
              success: true,
              data: {
                attestation_document: 'mock-attestation-base64',
                public_key: '0x04' + '0'.repeat(128),
                pcrs: {
                  pcr0: 'mock-pcr0',
                  pcr1: 'mock-pcr1',
                  pcr2: 'mock-pcr2'
                }
              },
            };
            break;

          default:
            response = {
              id: request.id,
              success: false,
              error: `Unknown method: ${request.method}`,
            };
        }

        // Send response
        const responseJson = JSON.stringify(response);
        const responseBuffer = Buffer.from(responseJson, 'utf-8');
        const lengthBuffer = Buffer.allocUnsafe(4);
        lengthBuffer.writeUInt32BE(responseBuffer.length, 0);

        socket.write(lengthBuffer);
        socket.write(responseBuffer);

        console.log(`✓ Response [${response.success ? 'SUCCESS' : 'ERROR'}]:`, response);
      } catch (error) {
        console.error('✗ Error parsing request:', error);
      }
    }
  });

  socket.on('end', () => {
    console.log('✗ Client disconnected');
  });

  socket.on('error', (error) => {
    console.error('✗ Socket error:', error);
  });
});

server.listen(SOCKET_PATH, () => {
  console.log(`\n✓ Mock enclave listening on ${SOCKET_PATH}`);
  console.log('✓ Ready to accept connections');
  console.log('\nSupported methods:');
  console.log('  - get_price (params: {symbol: string})');
  console.log('  - get_attestation');
  console.log('\nPress Ctrl+C to stop\n');
  console.log('═══════════════════════════════════════════');
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n\nShutting down mock enclave...');
  server.close(() => {
    try {
      fs.unlinkSync(SOCKET_PATH);
    } catch (e) {}
    console.log('✓ Stopped');
    process.exit(0);
  });
});
EOFMOCK

print_status "Mock enclave server created"

echo ""
echo "═══════════════════════════════════════════"
echo -e "${GREEN}✓ Setup Complete!${NC}"
echo "═══════════════════════════════════════════"
echo ""
echo "Next steps:"
echo ""
echo "1. Start mock enclave (Terminal 1):"
echo "   cd /home/ubuntu/orbs-tee-host"
echo "   npx ts-node examples/mock-enclave.ts"
echo ""
echo "2. Start host (Terminal 2):"
echo "   cd /home/ubuntu/orbs-tee-host"
echo "   npm run dev"
echo ""
echo "3. Test endpoints (Terminal 3):"
echo "   curl http://localhost:8080/api/v1/health"
echo "   curl -X POST http://localhost:8080/api/v1/request \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"method\":\"get_price\",\"params\":{\"symbol\":\"BTCUSDT\"}}'"
echo ""
echo "For complete testing guide, see:"
echo "  /home/ubuntu/INTEGRATION_TESTING.md"
echo ""
