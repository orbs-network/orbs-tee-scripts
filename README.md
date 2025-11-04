# ORBS TEE Scripts & Documentation

This repository contains operational scripts and documentation for the ORBS TEE (Trusted Execution Environment) system.

## Repository Structure

```
orbs-tee-scripts/
├── docs/                    # Documentation
│   ├── OPS_MANUAL.md       # Operations manual (service mgmt, logs, debugging)
│   ├── WORKING_ENDPOINTS.md # API reference with examples
│   ├── SYSTEM_STATUS.md    # Current system status and configuration
│   └── ...
└── scripts/                 # Operational scripts
    ├── test-endpoints.sh   # Comprehensive endpoint testing
    ├── setup-testing.sh    # Initial setup script
    └── ...
```

## Quick Start

### Test All Endpoints

```bash
cd /home/ubuntu/orbs-tee-scripts
./scripts/test-endpoints.sh
```

Run in verbose mode:
```bash
VERBOSE=true ./scripts/test-endpoints.sh
```

### Operations Manual

For service management, troubleshooting, and debugging:
```bash
cat docs/OPS_MANUAL.md
```

### Check System Status

```bash
cat docs/SYSTEM_STATUS.md
```

### View Working Endpoints

```bash
cat docs/WORKING_ENDPOINTS.md
```

## Documentation

### Operations
- **[OPS_MANUAL.md](docs/OPS_MANUAL.md)** - Complete operations guide
  - Service management (start/stop/restart)
  - Viewing logs
  - Troubleshooting common issues
  - Rebuilding components
  - Switching between Unix socket and Nitro enclave

### API Reference
- **[WORKING_ENDPOINTS.md](docs/WORKING_ENDPOINTS.md)** - API endpoint documentation
  - Health and status checks
  - Cryptocurrency price endpoints
  - Attestation endpoints
  - Example curl commands
  - Expected responses

### System Status
- **[SYSTEM_STATUS.md](docs/SYSTEM_STATUS.md)** - Current system status
  - Configuration summary
  - Test results
  - Performance metrics
  - Quick reference commands

## Scripts

### test-endpoints.sh

Comprehensive automated testing script with 10 test scenarios:

1. Health Check
2. Status Check
3. Bitcoin Price (BTCUSDT)
4. Ethereum Price (ETHUSDT)
5. Binance Coin Price (BNBUSDT)
6. Solana Price (SOLUSDT)
7. Get Attestation
8. Stability Test (5 consecutive requests)
9. Response Time Test
10. Signature Verification

**Features:**
- Color-coded output (green=pass, red=fail)
- JSON validation
- HTTP status checking
- Field existence validation
- Summary statistics
- Verbose mode option

## Current System Status

✅ **All systems operational**
- Server running on port 8080
- Unix socket enclave with network access
- Real-time price feeds from Binance
- Cryptographic signatures on all responses
- 100% test success rate

## Related Repositories

- **[orbs-tee-host](https://github.com/orbs-network/orbs-tee-host)** - TypeScript host API server
- **[orbs-tee-enclave-nitro](https://github.com/orbs-network/orbs-tee-enclave-nitro)** - Rust enclave SDK

## Support

For operational issues:
1. Check logs: `sudo journalctl -u orbs-tee-host -f`
2. Verify services: `sudo systemctl status orbs-tee-host orbs-tee-enclave`
3. Run tests: `./scripts/test-endpoints.sh`
4. Review OPS_MANUAL.md for troubleshooting

---

**Last Updated:** 2025-11-04  
**Status:** Production Ready
