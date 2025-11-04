# ORBS TEE System - Setup Summary

## ✅ What Was Installed & Configured

###  Environment Setup (Successfully Completed)

| Component | Version | Status |
|-----------|---------|--------|
| Rust | 1.91.0 | ✅ Installed |
| GCC/Build Tools | Latest | ✅ Installed |
| Node.js | 20.19.5 | ✅ Installed |
| NPM | 10.8.2 | ✅ Installed |

### Enclave (Rust) - READY ✅

- **Location**: `/home/ubuntu/orbs-tee-enclave-nitro`
- **Tests**: 25/25 passing ✅
  - Crypto tests: 12 passing
  - Integration tests: 7 passing
  - Runtime tests: 6 passing
- **Price Oracle Example**: Built successfully ✅
- **Binary**: `examples/price-oracle/target/debug/price-oracle`

### Host (TypeScript) - READY ✅

- **Location**: `/home/ubuntu/orbs-tee-host`
- **Dependencies**: 556 packages installed ✅
- **Build**: TypeScript compiled successfully ✅
- **Configuration**: `config.json` created ✅
- **Mock Enclave**: `examples/mock-enclave.ts` created ✅

---

## 📋 Installation Steps Performed

The following steps were automated in the setup:

### 1. System Prerequisites
```bash
sudo apt-get update
sudo apt-get install -y build-essential pkg-config libssl-dev
```

### 2. Rust Installation
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

### 3. Node.js Installation
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 4. Enclave Build
```bash
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features
cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml
```

### 5. Host Setup
```bash
cd /home/ubuntu/orbs-tee-host
npm install
npm run build
```

---

## 🚀 Quick Start - Testing the System

### Option 1: Test with Mock Enclave (Recommended First Step)

**Terminal 1 - Start Mock Enclave:**
```bash
cd /home/ubuntu/orbs-tee-host
npx ts-node examples/mock-enclave.ts
```

**Terminal 2 - Start Host:**
```bash
cd /home/ubuntu/orbs-tee-host
npm run dev
```

**Terminal 3 - Test Endpoints:**
```bash
# Health check
curl http://localhost:8080/api/v1/health

# Get price from mock enclave
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'

# Get attestation from mock enclave
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_attestation","params":{}}'
```

**Expected Output:**
```json
{
  "id": "...",
  "success": true,
  "data": {
    "symbol": "BTCUSDT",
    "price": "45234.56",
    "timestamp": 1730634000000,
    "source": "mock-enclave"
  },
  "signature": "0xmock..."
}
```

### Option 2: Test with Real Enclave (Unix Socket Mode)

> Note: This requires modifying the enclave to use Unix sockets instead of vsocket

**Terminal 1 - Start Real Enclave:**
```bash
cd /home/ubuntu/orbs-tee-enclave-nitro
# TODO: Configure for Unix socket mode
./examples/price-oracle/target/debug/price-oracle
```

**Terminal 2 - Start Host:**
```bash
cd /home/ubuntu/orbs-tee-host
npm run dev
```

**Terminal 3 - Test with Real Binance Prices:**
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"ETHUSDT"}}'
```

---

## 📁 Files & Scripts Created

### Main Documentation
- `/home/ubuntu/CLAUDE.md` - Workspace overview
- `/home/ubuntu/GUARDIAN_DEPLOYMENT.md` - **Production deployment guide** ⭐
- `/home/ubuntu/INTEGRATION_TESTING.md` - Detailed testing guide
- `/home/ubuntu/SETUP_SUMMARY.md` - This file

### Scripts
- `/home/ubuntu/setup-testing.sh` - Quick testing setup script
- `/home/ubuntu/guardian-install.sh` - **Full guardian installation script** ⭐

### Configuration
- `/home/ubuntu/orbs-tee-host/config.json` - Host configuration
- `/home/ubuntu/orbs-tee-host/examples/mock-enclave.ts` - Mock enclave server

---

## 🔧 For Guardians: Production Installation

### Fresh System Installation

On a new guardian system, run:

```bash
# Run the guardian setup script
sudo /home/ubuntu/guardian-setup.sh
```

The script will:
1. ✅ Install all system prerequisites (Rust, Node.js, build tools)
2. ✅ Build and test the enclave
3. ✅ Setup and build the host
4. ✅ **Create systemd services (auto-start on boot)** ⭐
5. ✅ Start the services
6. ✅ Verify everything works

**Time**: ~5 minutes on first run

### What Gets Configured

**Systemd Services**:
- `orbs-tee-enclave.service` - Price Oracle enclave
- `orbs-tee-host.service` - Host API server

**Features**:
- ✅ Auto-start on system boot
- ✅ Auto-restart on failure (5s delay)
- ✅ Proper dependency management (enclave → host)
- ✅ Runs as ubuntu user (not root)
- ✅ Complete logging to journald

### Post-Installation

After running the installation script, services are **automatically running**:

```bash
# 1. Check status
systemctl status orbs-tee-enclave orbs-tee-host

# 2. Test the system
curl http://localhost:8080/api/v1/health

# 3. Test price request
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'

# 4. View logs
journalctl -u orbs-tee-enclave -f
journalctl -u orbs-tee-host -f

# 5. Review configuration (optional)
nano /home/ubuntu/orbs-tee-host/config.json
```

### Reboot Survivability ✅

Services are configured to survive system reboots:

```bash
# Check auto-start is enabled
systemctl is-enabled orbs-tee-enclave orbs-tee-host
# Output: enabled, enabled

# Reboot the system
sudo reboot

# After reboot, services start automatically
# No manual intervention needed!
```

---

## 🏗️ Architecture

```
┌─────────────┐
│ DApp Client │
└──────┬──────┘
       │ HTTPS POST /api/v1/request
       ↓
┌─────────────────────────┐
│ Host (TypeScript)       │
│ Port: 8080              │
│ - Express API Server    │
│ - Unix Socket Client    │
│ - L3 Client             │
└──────────┬──────────────┘
           │ Unix Socket: /tmp/enclave.sock
           │ Wire: [4-byte length][JSON]
           ↓
┌──────────────────────────┐
│ Enclave (Rust)           │
│ - Price Oracle           │
│ - ECDSA Signing          │
│ - Nitro Attestation      │
└──────────┬───────────────┘
           │ HTTPS
           ↓
┌──────────────────┐
│ Binance API      │
│ Price Data       │
└──────────────────┘
```

---

## 📊 Current Status

| Component | Status | Notes |
|-----------|--------|-------|
| Enclave Build | ✅ Complete | All 25 tests passing |
| Host Build | ✅ Complete | TypeScript compiled |
| Mock Enclave | ✅ Ready | For testing without Nitro |
| Integration Tests | ⚠️ Pending | Ready to run manually |
| Production Deploy | ⚠️ Pending | Requires AWS Nitro |

---

## 🐛 Troubleshooting

### Enclave Tests Fail

```bash
# Make sure you're using --no-default-features on non-Linux
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features -- --nocapture
```

### Host Won't Start

```bash
# Check dependencies
cd /home/ubuntu/orbs-tee-host
npm install

# Check TypeScript compilation
npm run build

# Check logs
npm run dev
```

### Can't Connect to Enclave

```bash
# Check if socket exists
ls -la /tmp/enclave.sock

# Check if mock enclave is running
ps aux | grep mock-enclave

# Verify config points to correct socket path
cat /home/ubuntu/orbs-tee-host/config.json | grep socketPath
```

### Port 8080 Already in Use

```bash
# Find what's using port 8080
sudo lsof -i :8080

# Kill the process
sudo kill -9 <PID>

# Or change port in config.json
nano /home/ubuntu/orbs-tee-host/config.json
```

---

## 🔍 API Endpoints Reference

### GET /api/v1/health
```bash
curl http://localhost:8080/api/v1/health
```
```json
{
  "status": "healthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "uptimeSeconds": 120
}
```

### GET /api/v1/status
```bash
curl http://localhost:8080/api/v1/status
```
```json
{
  "hostVersion": "0.1.0",
  "enclaveConnected": true,
  "enclavePublicKey": "0x04...",
  "requestsProcessed": 42
}
```

### POST /api/v1/request
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```
```json
{
  "id": "uuid",
  "success": true,
  "data": {"symbol": "BTCUSDT", "price": "45123.45"},
  "signature": "0x..."
}
```

### POST /api/v1/attest
```bash
curl -X POST http://localhost:8080/api/v1/attest
```
```json
{
  "status": "submitted",
  "attestationId": "att-uuid",
  "submissionTime": "2024-11-03T11:30:00Z"
}
```

---

## 📚 Additional Resources

- **Enclave Details**: `/home/ubuntu/orbs-tee-enclave-nitro/CLAUDE.md`
- **Host Details**: `/home/ubuntu/orbs-tee-host/CLAUDE.md`
- **Architecture**: `/home/ubuntu/orbs-tee-host/ARCHITECTURE.md`
- **Deployment**: `/home/ubuntu/orbs-tee-host/DEPLOYMENT.md`
- **Integration Testing**: `/home/ubuntu/INTEGRATION_TESTING.md`

---

## ✅ Success Criteria

You'll know everything is working when:

1. ✅ Health endpoint returns `{"status":"healthy","enclaveConnected":true}`
2. ✅ Price request returns real BTC/ETH prices from Binance
3. ✅ Response includes valid ECDSA signature
4. ✅ Signature verification passes
5. ✅ Attestation endpoint returns attestation document
6. ✅ Concurrent requests work smoothly

---

## 🎯 Next Steps

1. **Test Mock Integration** - Run all 3 terminals with mock enclave
2. **Test Real Integration** - Configure enclave for Unix socket and test
3. **Verify Signatures** - Use signature-verification examples
4. **Production Config** - Update config.production.json for your environment
5. **AWS Nitro Deployment** - Follow DEPLOYMENT.md for AWS setup

---

**Setup completed**: 2025-11-03 11:30 UTC
**Platform**: Ubuntu 24.04 (Linux)
**Rust Version**: 1.91.0
**Node Version**: 20.19.5
