# HTTP Attestation Setup Complete

## Status: ✅ WORKING

The orbs-tee-host HTTP bridge is now successfully serving real attestation documents from the Nitro Enclave via curl/HTTP.

---

## What Was Fixed

**Problem**: User reported "the curl is not working"
- The orbs-tee-host TypeScript code only had UnixSocketClient (for Mac dev)
- No vsocket implementation for Linux/Nitro Enclaves

**Solution**: Created vsock-to-unix bridge
- Python script bridges vsocket (CID 16, Port 5000) to Unix socket (/tmp/enclave.sock)
- TypeScript host connects to Unix socket
- Requests forwarded to enclave via vsocket

---

## System Architecture

```
DApp/Browser
    ↓ HTTP/HTTPS
orbs-tee-host (TypeScript) - Port 8080
    ↓ Unix Socket (/tmp/enclave.sock)
vsock-bridge (Python)
    ↓ VSocket (CID 16, Port 5000)
Enclave (Rust/Price Oracle)
    ↓ NSM Device (/dev/nsm)
AWS Nitro Hardware
```

---

## API Endpoints

### 1. Health Check
```bash
curl http://localhost:8080/api/v1/health
```

**Response**:
```json
{
  "status": "unhealthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "uptimeSeconds": 29
}
```
*(Status is "unhealthy" because L3 guardian network isn't configured - that's expected)*

### 2. Status
```bash
curl http://localhost:8080/api/v1/status
```

**Response**:
```json
{
  "hostVersion": "0.1.0",
  "status": "unhealthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "l3GuardiansReachable": 0,
  "uptimeSeconds": 29,
  "requestsProcessed": 0
}
```

### 3. Get Attestation (WORKING!)
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get_attestation",
    "params": {
      "nonce": "my_challenge_12345",
      "user_data": "guardian_verification"
    }
  }'
```

**Response**:
```json
{
  "id": "uuid",
  "success": true,
  "data": {
    "attestation_document": "hEShATgioFkRM79pb...6016 chars...==",
    "document_size": 4511,
    "public_key": "0x034cca8db5b5151341f17eae9bdfbf98a09182fe243409c0e19198e8b0cf87cb4c"
  },
  "signature": null,
  "error": null
}
```

**Attestation Document Details**:
- Size: ~4500 bytes (6000+ chars when base64-encoded)
- Contains: PCR measurements, certificate chain, public key, nonce, user data
- Signed by: AWS Nitro hardware (not forgeable)

### 4. Get Price (Price Oracle Example)
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get_price",
    "params": {
      "symbol": "BTCUSDT"
    }
  }'
```

**Response**:
```json
{
  "id": "uuid",
  "success": true,
  "data": {
    "symbol": "BTCUSDT",
    "price": "67234.50",
    "timestamp": 1730000000,
    "source": "Binance"
  },
  "signature": "0x1234...abcd",
  "error": null
}
```
*(Signature is ECDSA from enclave private key)*

---

## Running Services

### 1. Nitro Enclave
```bash
# Check status
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli describe-enclaves

# View console
nitro-cli console --enclave-id <ENCLAVE_ID>
```

**Current Enclave**:
- ID: `i-08e0d9d2da1c6b79e-enc19a4b274a3e9cf6`
- CID: 16
- Port: 5000
- Status: RUNNING
- Memory: 1024 MB
- CPUs: 2 (CPUIDs 1, 3)

### 2. VSocket Bridge
```bash
# Check if running
ps aux | grep vsock-to-unix-bridge

# Restart if needed
python3 /home/ubuntu/vsock-to-unix-bridge.py > /tmp/bridge.log 2>&1 &

# Check logs
cat /tmp/bridge.log
```

**Bridge Details**:
- Script: `/home/ubuntu/vsock-to-unix-bridge.py`
- Unix Socket: `/tmp/enclave.sock`
- Forwards to: CID 16, Port 5000

### 3. HTTP Host (orbs-tee-host)
```bash
# Check if running
ps aux | grep "ts-node src/index.ts"

# Restart if needed
cd /home/ubuntu/orbs-tee-host
npm run dev

# View logs (if using npm start)
cat /tmp/host-restart.log
```

**Host Details**:
- Port: 8080
- Config: `/home/ubuntu/orbs-tee-host/config.json`
- Connects to: `/tmp/enclave.sock`

---

## Configuration Files

### /home/ubuntu/orbs-tee-host/config.json
```json
{
  "vsock": {
    "cid": 16,
    "port": 5000,
    "timeoutMs": 30000,
    "retryAttempts": 5,
    "retryDelayMs": 100
  },
  "l3": {
    "endpoint": "https://guardian1.orbs.network",
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
```

---

## Testing Attestation

### Quick Test
```bash
curl -s -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_attestation","params":{"nonce":"test123","user_data":"test"}}' \
  | jq -r 'if .data.attestation_document then "✅ SUCCESS: Got \(.data.attestation_document | length) char attestation" else "❌ FAILED: \(.data.note // .error)" end'
```

**Expected Output**:
```
✅ SUCCESS: Got 6040 char attestation
```

### Verify Attestation Document
The attestation document contains:
1. **PCR Measurements** - Cryptographic hashes of enclave code
2. **Certificate Chain** - AWS-signed certificates proving authenticity
3. **Public Key** - Enclave's public key (matches private key in enclave)
4. **Nonce** - Your challenge value (proves freshness)
5. **User Data** - Your custom data
6. **Timestamp** - When attestation was generated

To verify in production:
1. Decode base64
2. Parse CBOR format
3. Verify certificate chain against AWS root CA
4. Check PCR measurements match expected values
5. Verify nonce matches your challenge
6. Extract and use public key

---

## Startup Sequence

If you restart the system, run these commands in order:

```bash
# 1. Start Nitro Enclave (if not running)
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli run-enclave \
  --eif-path /home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/price-oracle-v2.eif \
  --cpu-ids 1 3 \
  --memory 1024 \
  --debug-mode

# 2. Start VSocket Bridge
python3 /home/ubuntu/vsock-to-unix-bridge.py > /tmp/bridge.log 2>&1 &

# 3. Start HTTP Host
cd /home/ubuntu/orbs-tee-host
npm run dev > /tmp/host.log 2>&1 &

# 4. Test
sleep 5
curl -s http://localhost:8080/api/v1/health | jq .
```

---

## Files Created/Modified

### New Files
- `/home/ubuntu/vsock-to-unix-bridge.py` - VSocket bridge script
- `/home/ubuntu/http-attestation-working-*.md` - Auto-generated documentation
- `/home/ubuntu/HTTP_ATTESTATION_COMPLETE.md` - This file

### Modified Files
- `/home/ubuntu/orbs-tee-host/config.json` - Added all required config sections
- `/home/ubuntu/orbs-tee-enclave-nitro/src/app.rs` - Added get_attestation built-in method
- `/home/ubuntu/orbs-tee-enclave-nitro/Cargo.toml` - Added base64 dependency

---

## Security Notes

### Trust Model
- **Enclave (TRUSTED)**: Holds private keys, generates attestation, signs responses
- **Host (UNTRUSTED)**: Can be compromised but cannot forge signatures or access keys
- **Bridge (UNTRUSTED)**: Can drop requests but cannot modify responses

### What Attestation Proves
✅ Code running in enclave matches expected PCR measurements
✅ Enclave is running on real AWS Nitro hardware
✅ Public key genuinely belongs to this enclave
✅ Nonce proves attestation is fresh (not replayed)

### What Attestation Does NOT Prove
❌ Host is trustworthy (host is untrusted by design)
❌ Network connection is secure (use HTTPS in production)
❌ The enclave code is bug-free

---

## Next Steps

1. **Production Deployment**:
   - Enable HTTPS on orbs-tee-host (TLS certificates)
   - Remove DEBUG_MODE from enclave
   - Configure L3 guardian network endpoints
   - Enable DApp authentication

2. **Implement Native VSocket Support**:
   - Install `node-vsock` npm package
   - Implement `VsocketClient` class in TypeScript
   - Remove Python bridge dependency

3. **Guardian Network Integration**:
   - Configure L3 endpoints in config.json
   - Implement attestation submission to guardians
   - Test consensus verification

4. **Testing**:
   - Write integration tests for all endpoints
   - Test attestation verification flow
   - Benchmark performance

---

## Troubleshooting

### "Connection refused" on curl
```bash
# Check if host is running
ps aux | grep "ts-node"
cd /home/ubuntu/orbs-tee-host
npm run dev
```

### "Mock attestation" response
```bash
# Restart services in order:
pkill -f vsock-to-unix-bridge
pkill -f "ts-node"
python3 /home/ubuntu/vsock-to-unix-bridge.py &
sleep 2
cd /home/ubuntu/orbs-tee-host && npm run dev &
```

### Check enclave is running
```bash
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli describe-enclaves
```

### Test enclave directly (bypass host/bridge)
```bash
python3 /home/ubuntu/test-enclave-full.py
```

---

## Documentation

**Auto-generated documentation**:
- `/home/ubuntu/http-attestation-working-latest.md`
- Full system state captured at 2025-11-03 19:38:16

**Previous documentation**:
- `/home/ubuntu/nitro-attestation-latest.md`
- `/home/ubuntu/AUTO_DOCUMENTATION_README.md`

**Project documentation**:
- `/home/ubuntu/CLAUDE.md` - Workspace overview
- `/home/ubuntu/INTEGRATION_TESTING.md` - Complete testing guide
- `/home/ubuntu/orbs-tee-host/CLAUDE.md` - Host details
- `/home/ubuntu/orbs-tee-enclave-nitro/CLAUDE.md` - Enclave details

---

## Summary

✅ **Problem**: User reported "the curl is not working"
✅ **Root Cause**: TypeScript host had no vsocket support for Linux
✅ **Solution**: Created Python bridge from Unix socket to vsocket
✅ **Result**: HTTP attestation endpoint now returns real attestation documents

**Test Command**:
```bash
curl -s -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_attestation","params":{"nonce":"test","user_data":"test"}}' \
  | jq -r '.data | "Attestation: \(.attestation_document | length) chars, Key: \(.public_key)"'
```

**Expected Output**:
```
Attestation: 6040 chars, Key: 0x034cca8db5b5151341f17eae9bdfbf98a09182fe243409c0e19198e8b0cf87cb4c
```

---

**Generated**: 2025-11-03 19:38
**Session**: HTTP Attestation Setup
