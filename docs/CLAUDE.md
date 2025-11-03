# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workspace Overview

This workspace contains the **ORBS TEE System** for AWS Nitro Enclaves - a complete Trusted Execution Environment solution with:

1. **orbs-tee-enclave-nitro** (Rust) - Trusted enclave SDK that holds private keys
2. **orbs-tee-host** (TypeScript) - Untrusted host bridge for DApp communication

## Quick Start - Integration Testing

**🎯 Main Goal**: Get enclave + host communicating via vsocket and test all API endpoints.

**📖 Complete Guide**: See `/home/ubuntu/INTEGRATION_TESTING.md`

### Fast Setup

```bash
# 1. Test Enclave
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features  # Should pass 25 tests

# 2. Setup Host
cd /home/ubuntu/orbs-tee-host
npm install
npm test

# 3. Follow INTEGRATION_TESTING.md for full setup
```

## Project Structure

```
/home/ubuntu/
├── INTEGRATION_TESTING.md      # 👈 START HERE for testing guide
├── CLAUDE.md                    # This file
├── orbs-tee-enclave-nitro/      # Rust enclave (TRUSTED)
│   ├── CLAUDE.md                # Detailed enclave docs
│   ├── src/                     # SDK implementation
│   ├── examples/price-oracle/   # Working example
│   └── tests/                   # 25 integration tests
└── orbs-tee-host/               # TypeScript host (UNTRUSTED)
    ├── CLAUDE.md                # Detailed host docs
    ├── src/                     # Host implementation
    │   ├── api/routes/          # HTTP endpoints
    │   ├── vsock/client.ts      # Enclave communication
    │   └── index.ts             # Entry point
    └── test/                    # Jest tests
```

## Architecture Overview

```
DApp/Client
    ↓ HTTPS
Host (TypeScript) - Port 8080
    ↓ vsocket/Unix socket
Enclave (Rust/Price Oracle)
    ↓ HTTPS to Binance
Returns signed price data
```

## Common Commands

### Enclave (Rust)

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# Test (cross-platform, no Nitro hardware needed)
cargo test --no-default-features

# Build price oracle example
cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml

# Run example (requires vsocket or Unix socket setup)
./examples/price-oracle/target/debug/price-oracle
```

### Host (TypeScript)

```bash
cd /home/ubuntu/orbs-tee-host

# Setup
npm install
npm run build

# Development
npm run dev

# Test
npm test

# Test specific endpoint
curl http://localhost:8080/api/v1/health
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

## API Endpoints (Host)

When host is running on port 8080:

- `GET /api/v1/health` - Health check (enclave connectivity)
- `GET /api/v1/status` - Detailed status (public key, uptime)
- `POST /api/v1/request` - Forward request to enclave (get price, etc.)
- `POST /api/v1/attest` - Trigger attestation submission

## Communication Protocol

Both components use **orbs-tee-protocol** with length-prefixed wire format:

**Wire Format**: `[4-byte length (big-endian u32)][N bytes JSON]`

**Request** (TeeRequest):
```json
{
  "id": "uuid",
  "method": "get_price",
  "params": {"symbol": "BTCUSDT"},
  "timestamp": 1234567890
}
```

**Response** (TeeResponse):
```json
{
  "id": "uuid",
  "success": true,
  "data": {"symbol": "BTCUSDT", "price": "45000.50"},
  "signature": "0x1234...abcd"
}
```

## Testing Strategy

1. **Mock Enclave** - Create TypeScript mock server for initial host testing
2. **Real Enclave (Unix Socket)** - Test with actual Rust enclave on Mac/Linux
3. **Real Enclave (vsocket)** - Test on Linux with vsocket support
4. **AWS Nitro** - Final integration testing on actual Nitro Enclave

See `/home/ubuntu/INTEGRATION_TESTING.md` for detailed steps.

## Current Status

**Enclave**: ✅ Complete, tested, ready to use
- Price oracle example works
- 25 tests passing
- Signature generation working

**Host**: ✅ Code complete, ⚠️ needs npm install & configuration
- All modules implemented
- API routes defined
- Unix socket client ready
- Needs: `npm install` + `config.json` + testing

## Key Design Principles

### Trust Boundary

**Enclave (Trusted)**:
- Holds private keys
- Signs responses
- Generates attestation
- Cannot be compromised without breaking signatures

**Host (Untrusted)**:
- Forwards requests
- Exposes HTTP API
- Can be compromised BUT cannot forge signatures or access keys

### Security

Even if host is fully compromised:
- ❌ Cannot access enclave private keys
- ❌ Cannot forge signatures
- ❌ Cannot modify enclave code
- ✅ Can delay/drop requests (availability only)

## Development Workflow

### Adding New Enclave Methods

1. Edit `examples/price-oracle/src/main.rs`
2. Add new method case in `handle_request()`
3. Implement business logic
4. Return `Response { data, sign: true }`
5. Rebuild: `cargo build --no-default-features`

### Adding New Host Endpoints

1. Edit `src/api/routes/*.ts`
2. Add route handler
3. Call `vsockClient.sendRequest()`
4. Return response to client
5. Test: `npm test`

## Troubleshooting

### "Cannot connect to enclave"
```bash
# Check if enclave is running
ls -la /tmp/enclave.sock

# Check host config
cat /home/ubuntu/orbs-tee-host/config.json
```

### "Tests failing"
```bash
# Enclave: Make sure to use --no-default-features on Mac
cargo test --no-default-features

# Host: Check dependencies
npm install && npm test
```

### "Port 8080 in use"
```bash
lsof -i :8080
kill -9 <PID>
```

## Next Steps

1. **Read** `/home/ubuntu/INTEGRATION_TESTING.md`
2. **Run** enclave tests: `cargo test --no-default-features`
3. **Setup** host: `npm install`
4. **Create** mock enclave for testing
5. **Test** all endpoints
6. **Verify** signatures work correctly

## Documentation

- `/home/ubuntu/INTEGRATION_TESTING.md` - **START HERE** for testing
- `/home/ubuntu/orbs-tee-enclave-nitro/CLAUDE.md` - Enclave details
- `/home/ubuntu/orbs-tee-enclave-nitro/README.md` - Enclave API reference
- `/home/ubuntu/orbs-tee-host/CLAUDE.md` - Host details
- `/home/ubuntu/orbs-tee-host/ARCHITECTURE.md` - System architecture
- `/home/ubuntu/orbs-tee-host/TODO.md` - Development roadmap

## Platform Support

**macOS/Windows (Development)**:
- ✅ Enclave tests with `--no-default-features`
- ✅ Host uses Unix sockets
- ❌ No Nitro attestation (Linux only)

**Linux (Production)**:
- ✅ Full vsocket support
- ✅ Nitro attestation
- ✅ All features enabled

**Current Platform**: Run `uname -a` to check
