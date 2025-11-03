# ORBS TEE Integration Testing Guide

This guide helps you set up and test the complete ORBS TEE system: enclave (Rust) + host (TypeScript) communication via vsocket.

## Goal

Test the end-to-end flow:
```
HTTP Client → Host (TypeScript) → vsocket → Enclave (Rust/Price Oracle)
                                              ↓
HTTP Client ← Host ← vsocket ← Signed Price Response
```

## Current Status

### ✅ Enclave (Rust) - Ready
- Location: `/home/ubuntu/orbs-tee-enclave-nitro`
- Price Oracle example: Fully implemented
- Tests: 25 passing tests
- Cross-platform: Works on Mac/Linux with `--no-default-features`

### ⚠️ Host (TypeScript) - Needs Setup
- Location: `/home/ubuntu/orbs-tee-host`
- Code: Implemented (vsock client, API routes, etc.)
- Dependencies: Need `npm install`
- Config: Needs configuration file

## Step-by-Step Setup

### Step 1: Test Enclave (Price Oracle)

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# Run all tests to verify enclave works
cargo test --no-default-features

# Build the price oracle example
cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml

# The binary will be at:
# examples/price-oracle/target/debug/price-oracle
```

**Expected Output**: All 25 tests pass ✅

### Step 2: Setup Host (TypeScript)

```bash
cd /home/ubuntu/orbs-tee-host

# Install dependencies
npm install

# Create config file
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

# Build TypeScript
npm run build

# Run tests
npm test
```

### Step 3: Test Communication (Mock Enclave)

Since we're on a platform without vsocket (or for initial testing), we need to create a mock enclave server that the host can communicate with.

**Option A: Create Mock Enclave Server**

```bash
cd /home/ubuntu/orbs-tee-host

# Create mock enclave for testing
cat > examples/mock-enclave.ts << 'EOF'
import * as net from 'net';
import { TeeRequest, TeeResponse } from './src/types';

const SOCKET_PATH = '/tmp/enclave.sock';

// Remove existing socket
try {
  require('fs').unlinkSync(SOCKET_PATH);
} catch (e) {
  // Ignore if doesn't exist
}

const server = net.createServer((socket) => {
  console.log('Client connected');

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
      const request: TeeRequest = JSON.parse(messageBuffer.toString('utf-8'));
      console.log('Received request:', request);

      // Mock response
      const response: TeeResponse = {
        id: request.id,
        success: true,
        data: {
          symbol: request.params?.symbol || 'BTCUSDT',
          price: '45000.50',
          timestamp: Date.now(),
          source: 'mock'
        },
        signature: 'mock-signature-0x1234567890abcdef',
      };

      // Send response
      const responseJson = JSON.stringify(response);
      const responseBuffer = Buffer.from(responseJson, 'utf-8');
      const lengthBuffer = Buffer.allocUnsafe(4);
      lengthBuffer.writeUInt32BE(responseBuffer.length, 0);

      socket.write(lengthBuffer);
      socket.write(responseBuffer);

      console.log('Sent response:', response);
    }
  });

  socket.on('end', () => {
    console.log('Client disconnected');
  });
});

server.listen(SOCKET_PATH, () => {
  console.log(`Mock enclave listening on ${SOCKET_PATH}`);
});
EOF

# Run mock enclave (in one terminal)
npx ts-node examples/mock-enclave.ts
```

**In another terminal:**

```bash
cd /home/ubuntu/orbs-tee-host

# Run host
npm run dev
```

**In a third terminal, test the API:**

```bash
# Health check
curl http://localhost:8080/api/v1/health

# Status
curl http://localhost:8080/api/v1/status

# Request price
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get_price",
    "params": {
      "symbol": "BTCUSDT"
    }
  }'

# Request attestation
curl -X POST http://localhost:8080/api/v1/attest
```

### Step 4: Test with Real Enclave (Unix Socket Mode)

To test with the actual Rust enclave, we need to modify the enclave to use Unix sockets instead of vsocket (for Mac development).

**Option A: Build Enclave with Unix Socket Support**

The enclave needs to support Unix sockets for Mac testing. Check if there's a feature flag or configuration for this.

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# Check Cargo.toml for features
cat Cargo.toml

# Run with no-default-features to avoid vsocket
cargo run --no-default-features --manifest-path examples/price-oracle/Cargo.toml
```

**Option B: Docker Linux Environment**

Use Docker to create a Linux environment where vsocket can work:

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# Build Docker image with Linux
docker build -t orbs-tee-enclave .

# Run enclave in Docker
docker run -d --name enclave \
  -v /tmp:/tmp \
  orbs-tee-enclave

# Run host (connects via Unix socket)
cd /home/ubuntu/orbs-tee-host
npm run dev
```

## Testing Checklist

### ✅ Phase 1: Basic Connectivity
- [ ] Host starts successfully
- [ ] Host can bind to port 8080
- [ ] Health endpoint returns 200 OK
- [ ] Status endpoint returns host information

### ✅ Phase 2: Mock Enclave Communication
- [ ] Mock enclave listens on Unix socket
- [ ] Host connects to mock enclave
- [ ] Host can send requests to mock enclave
- [ ] Host receives responses from mock enclave
- [ ] POST /api/v1/request returns mock data

### ✅ Phase 3: Real Enclave Communication
- [ ] Real enclave runs (price-oracle)
- [ ] Enclave listens on Unix socket
- [ ] Host connects to real enclave
- [ ] GET /api/v1/status shows "enclaveConnected: true"
- [ ] POST /api/v1/request returns real price from Binance
- [ ] Response includes valid signature

### ✅ Phase 4: API Endpoints Testing
- [ ] GET /api/v1/health - Returns healthy status
- [ ] GET /api/v1/status - Returns detailed status
- [ ] POST /api/v1/request - Forwards to enclave
- [ ] POST /api/v1/attest - Triggers attestation (mock for now)

### ✅ Phase 5: Error Handling
- [ ] Invalid method returns error
- [ ] Invalid params returns error
- [ ] Enclave disconnection is handled gracefully
- [ ] Timeout scenarios work correctly

### ✅ Phase 6: Signature Verification
- [ ] Response includes signature field
- [ ] Signature is hex-encoded
- [ ] Public key is available in response or status
- [ ] Signature can be verified (see below)

## Signature Verification Example

Once you get a signed response from the enclave, verify it:

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro/examples/signature-verification

# Install dependencies
npm install

# Create test file
cat > test-verify.js << 'EOF'
const { verifyJSONSignature } = require('./verify');

// Get these from actual response
const data = {"symbol":"BTCUSDT","price":"45000.50","timestamp":1234567890,"source":"binance"};
const signature = "ACTUAL_SIGNATURE_FROM_RESPONSE";
const publicKey = "ACTUAL_PUBLIC_KEY_FROM_ENCLAVE";

const valid = verifyJSONSignature(data, signature, publicKey);
console.log('Signature valid:', valid);
EOF

# Run verification
node test-verify.js
```

## Troubleshooting

### Host won't start

```bash
# Check dependencies
cd /home/ubuntu/orbs-tee-host
npm install

# Check TypeScript compilation
npm run build

# Check logs
npm run dev
```

### Connection refused

```bash
# Check if enclave is running
ls -la /tmp/enclave.sock

# Check if host config points to correct socket
cat config.json | grep socketPath

# Test socket directly
nc -U /tmp/enclave.sock
```

### Tests failing

```bash
# Enclave tests
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features -- --nocapture

# Host tests
cd /home/ubuntu/orbs-tee-host
npm test -- --verbose
```

### Port already in use

```bash
# Find process using port 8080
lsof -i :8080

# Kill it
kill -9 <PID>

# Or change port in config.json
```

## Next Steps

1. **Get basic connectivity working** - Host + Mock Enclave
2. **Connect to real enclave** - Modify enclave for Unix socket or use Docker
3. **Test all endpoints** - Health, Status, Request, Attest
4. **Verify signatures** - Ensure cryptographic signatures are valid
5. **Load testing** - Test with multiple concurrent requests
6. **AWS Nitro testing** - Deploy to actual AWS Nitro Enclave environment

## Files Modified/Created

During this testing, you may need to modify:

- `/home/ubuntu/orbs-tee-host/config.json` - Configuration
- `/home/ubuntu/orbs-tee-host/examples/mock-enclave.ts` - Mock server
- `/home/ubuntu/orbs-tee-host/src/vsock/client.ts` - Socket path
- `/home/ubuntu/orbs-tee-enclave-nitro/src/vsock.rs` - Unix socket support (if needed)

## Architecture Reference

```
┌─────────────────┐
│  HTTP Client    │
│  (curl/browser) │
└────────┬────────┘
         │ HTTP POST /api/v1/request
         │ {"method": "get_price", "params": {"symbol": "BTCUSDT"}}
         ↓
┌─────────────────────────┐
│  Host (TypeScript)      │
│  Port: 8080             │
│  - API Server (Express) │
│  - Vsock Client         │
└──────────┬──────────────┘
           │ Unix Socket: /tmp/enclave.sock
           │ Wire Protocol: [4-byte length][JSON]
           │ {"id":"uuid","method":"get_price","params":{...},"timestamp":...}
           ↓
┌──────────────────────────────┐
│  Enclave (Rust)              │
│  - Price Oracle              │
│  - EnclaveRuntime            │
│  - KeyManager (ECDSA)        │
│  - Binance API Client        │
└──────────┬───────────────────┘
           │
           │ HTTPS to api.binance.com
           ↓
┌──────────────────┐
│  Binance API     │
│  Price Data      │
└──────────┬───────┘
           │
           ↓
           {"symbol":"BTCUSDT","price":"45123.45"}
           │
           ↓
┌──────────────────────────────┐
│  Enclave Signs Response      │
│  - SHA-256 hash              │
│  - ECDSA signature           │
│  - secp256k1 curve           │
└──────────┬───────────────────┘
           │
           │ {"id":"uuid","success":true,"data":{...},"signature":"0x..."}
           ↓
┌─────────────────────────┐
│  Host                   │
│  Returns to client      │
└──────────┬──────────────┘
           │
           ↓
┌─────────────────┐
│  HTTP Response  │
│  200 OK         │
│  + Signed Data  │
└─────────────────┘
```

## Commands Quick Reference

```bash
# Enclave
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features
cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml

# Host
cd /home/ubuntu/orbs-tee-host
npm install
npm run build
npm run dev

# Mock Enclave
cd /home/ubuntu/orbs-tee-host
npx ts-node examples/mock-enclave.ts

# Test API
curl http://localhost:8080/api/v1/health
curl -X POST http://localhost:8080/api/v1/request -H "Content-Type: application/json" -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

## Success Criteria

You'll know the integration is working when:

✅ Host starts without errors
✅ Health endpoint returns `{"status":"healthy","enclaveConnected":true}`
✅ Price request returns actual BTC price from Binance
✅ Response includes valid ECDSA signature
✅ Signature verification passes
✅ Concurrent requests work smoothly
✅ Error handling works (invalid methods, network errors, etc.)

---

**Current Platform**: Check with `uname -a`
**Recommended First Test**: Mock enclave → Real enclave → AWS Nitro
