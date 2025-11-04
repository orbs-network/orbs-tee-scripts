# ORBS TEE Scripts & Documentation

This repository contains operational scripts and documentation for the ORBS TEE (Trusted Execution Environment) system.

## Repository Structure

```
orbs-tee-scripts/
├── docs/                           # Documentation
│   ├── OPS_MANUAL.md              # Operations manual (service mgmt, logs, debugging)
│   ├── WORKING_ENDPOINTS.md       # API reference with examples
│   ├── SYSTEM_STATUS.md           # Current system status and configuration
│   ├── CLAUDE.md                  # Main project instructions for Claude Code
│   ├── INTEGRATION_TESTING.md     # Integration testing guide
│   ├── snapshots/                 # Historical session snapshots
│   │   ├── http-attestation-working-latest.md
│   │   └── nitro-attestation-latest.md
│   └── [25+ other docs]           # Setup guides, troubleshooting, status reports
│
└── scripts/                        # Operational scripts
    ├── Shell Scripts (.sh)
    │   ├── test-endpoints.sh      # Comprehensive endpoint testing
    │   ├── setup-testing.sh       # Initial setup script
    │   ├── guardian-setup.sh      # Guardian system setup
    │   ├── guardian-install.sh    # Guardian installation
    │   ├── verify-enclave.sh      # Enclave verification
    │   ├── docker-test.sh         # Docker testing
    │   ├── session-tracker.sh     # Session tracking
    │   ├── dev-session.sh         # Development session management
    │   ├── save-state.sh          # State saving
    │   ├── restore-state.sh       # State restoration
    │   └── [more scripts]
    │
    ├── Python Scripts (.py)
    │   ├── test-enclave.py        # Basic enclave testing
    │   ├── test-enclave-full.py   # Full enclave test suite
    │   ├── get_attestation.py     # Attestation retrieval
    │   ├── http-attestation-server.py  # HTTP attestation server
    │   └── vsock-to-unix-bridge.py     # vsocket to Unix socket bridge
    │
    └── Service Files (.service)
        ├── orbs-tee-host.service     # Systemd service for host
        └── orbs-tee-enclave.service  # Systemd service for enclave
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

## Documentation Files

### Core Documentation
- **CLAUDE.md** - Project instructions for Claude Code assistant
- **INTEGRATION_TESTING.md** - Complete integration testing guide
- **OPS_MANUAL.md** - Operations manual for service management
- **WORKING_ENDPOINTS.md** - API reference with curl examples
- **SYSTEM_STATUS.md** - Current system configuration and status

### Setup & Configuration
- **AUTO_DOCUMENTATION_README.md** - Auto-documentation system guide
- **ENABLE_NITRO_ENCLAVES.md** - Enable Nitro Enclaves on EC2
- **AWS_CONSOLE_ENABLE_NITRO.md** - AWS console Nitro setup instructions
- **GUARDIAN_DEPLOYMENT.md** - Guardian system deployment
- **PERMISSIONS.md** - File permissions reference

### Status & Results
- **FINAL_STATUS.md** - Final deployment status
- **TEST_RESULTS.md** - Test execution results
- **ATTESTATION_SUCCESS.md** - Attestation verification success
- **HTTP_ATTESTATION_COMPLETE.md** - HTTP attestation completion
- **HTTPS_SETUP_COMPLETE.md** - HTTPS configuration completion

### Troubleshooting
- **AWS_SECURITY_GROUP_FIX.md** - Security group configuration
- **NITRO_ENCLAVE_NETWORK_FIX.md** - Nitro enclave network issues
- **TROUBLESHOOT_PORT_8080.md** - Port 8080 troubleshooting
- **OPEN_PORT_8080.md** - Instructions to open port 8080

### Reference
- **GITHUB_SUMMARY.md** - GitHub repository summary
- **WHAT_TO_PUSH.md** - Git push checklist
- **WHERE_WE_LEFT_OFF.md** - Session continuation reference
- **RECONNECTION_GUIDE.md** - How to reconnect to the system
- **REMOTE_TESTING.md** - Remote testing procedures

### Historical Snapshots
Located in `docs/snapshots/`:
- Session snapshots with timestamps
- Working configuration records
- Attestation verification records

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
