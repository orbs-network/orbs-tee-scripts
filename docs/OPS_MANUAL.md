# ORBS TEE System - Operations Manual

## Quick Status Check

```bash
# Check all services status
sudo systemctl status orbs-tee-host orbs-tee-enclave vsock-proxy-dns vsock-proxy-https

# Check if server is responding
curl http://localhost:8080/api/v1/health
```

---

## System Components

### 1. Host API Server
- **Service:** `orbs-tee-host.service`
- **Port:** 8080 (HTTP)
- **Working Directory:** `/home/ubuntu/orbs-tee-host`
- **Logs:** `sudo journalctl -u orbs-tee-host -f`

### 2. Unix Socket Enclave (Price Oracle)
- **Service:** `orbs-tee-enclave.service`
- **Socket:** `/tmp/enclave.sock`
- **Binary:** `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle-unix/target/debug/price-oracle-unix`
- **Logs:** Check process output or `/tmp/enclave.log`

### 3. Vsock Proxy Services (for Nitro Enclave)
- **DNS Proxy:** `vsock-proxy-dns.service` (port 53)
- **HTTPS Proxy:** `vsock-proxy-https.service` (port 443)

---

## Starting/Stopping Services

### Restart Everything
```bash
sudo systemctl restart orbs-tee-enclave orbs-tee-host
```

### Stop Everything
```bash
sudo systemctl stop orbs-tee-host orbs-tee-enclave
```

### Start Everything
```bash
sudo systemctl start orbs-tee-enclave orbs-tee-host
```

### Individual Service Control
```bash
# Host API server
sudo systemctl restart orbs-tee-host
sudo systemctl status orbs-tee-host
sudo systemctl stop orbs-tee-host

# Unix Socket Enclave
sudo systemctl restart orbs-tee-enclave
sudo systemctl status orbs-tee-enclave
sudo systemctl stop orbs-tee-enclave
```

---

## Viewing Logs

### Host API Server Logs
```bash
# Follow logs in real-time
sudo journalctl -u orbs-tee-host -f

# Last 100 lines
sudo journalctl -u orbs-tee-host -n 100

# Logs since last boot
sudo journalctl -u orbs-tee-host -b

# Filter by time
sudo journalctl -u orbs-tee-host --since "1 hour ago"
```

### Enclave Logs
```bash
# Check Unix socket enclave output
tail -f /tmp/enclave.log

# Or check via systemd
sudo journalctl -u orbs-tee-enclave -f
```

### Vsock Proxy Logs
```bash
sudo journalctl -u vsock-proxy-dns -f
sudo journalctl -u vsock-proxy-https -f
```

---

## Testing Endpoints

### Base URL
- Local: `http://localhost:8080`
- External: `http://35.179.36.200:8080`

### 1. Health Check
```bash
curl http://localhost:8080/api/v1/health
```

Expected: `{"status":"...","enclaveConnected":true,...}`

### 2. Status
```bash
curl http://localhost:8080/api/v1/status
```

### 3. Get Bitcoin Price
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

Expected: Should return real price from Binance with signature

### 4. Get Ethereum Price
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"ETHUSDT"}}'
```

### 5. Get Attestation (Unix socket = mock, Nitro = real)
```bash
curl -X POST http://localhost:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_attestation","params":{"nonce":"test","user_data":"demo"}}'
```

---

## Common Issues & Debugging

### Issue: Server not responding on port 8080

**Check if server is running:**
```bash
sudo systemctl status orbs-tee-host
lsof -i :8080
```

**Restart server:**
```bash
sudo systemctl restart orbs-tee-host
```

**Check logs:**
```bash
sudo journalctl -u orbs-tee-host -n 50
```

---

### Issue: "Cannot connect to enclave" error

**Check if enclave socket exists:**
```bash
ls -la /tmp/enclave.sock
```

**Check if enclave is running:**
```bash
ps aux | grep price-oracle-unix
sudo systemctl status orbs-tee-enclave
```

**Restart enclave:**
```bash
sudo systemctl restart orbs-tee-enclave
sleep 3  # Wait for socket to be created
sudo systemctl restart orbs-tee-host
```

---

### Issue: Price requests failing with network errors

**Check enclave has network access:**
```bash
# For Unix socket enclave, test directly:
curl https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT
```

**Check enclave logs:**
```bash
tail -50 /tmp/enclave.log
```

---

### Issue: Server crashes or restarts frequently

**Check for errors:**
```bash
sudo journalctl -u orbs-tee-host --since "10 minutes ago" | grep -i error
```

**Check memory/resources:**
```bash
free -h
df -h
```

---

## File Locations

### Configuration
- Host config: `/home/ubuntu/orbs-tee-host/config.json`
- Systemd services: `/etc/systemd/system/orbs-tee-*.service`
- Vsock proxy allowlist: `/etc/nitro_enclaves/vsock-proxy.yaml`

### Source Code
- Host (TypeScript): `/home/ubuntu/orbs-tee-host/`
- Enclave (Rust): `/home/ubuntu/orbs-tee-enclave-nitro/`
- Unix socket enclave: `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle-unix/`

### Binaries
- Unix socket enclave: `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle-unix/target/debug/price-oracle-unix`
- Nitro enclave EIF: `/home/ubuntu/price-oracle-v*.eif`

### Logs
- Host logs: `sudo journalctl -u orbs-tee-host`
- Enclave logs: `/tmp/enclave.log` or `sudo journalctl -u orbs-tee-enclave`

---

## Rebuilding Components

### Rebuild Host (TypeScript)
```bash
cd /home/ubuntu/orbs-tee-host
npm run build
sudo systemctl restart orbs-tee-host
```

### Rebuild Unix Socket Enclave
```bash
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo build --no-default-features --manifest-path examples/price-oracle-unix/Cargo.toml
sudo systemctl restart orbs-tee-enclave
```

### Rebuild Nitro Enclave
```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# 1. Build binary
cargo build --release --manifest-path examples/price-oracle/Cargo.toml

# 2. Build Docker image
sudo docker build -f examples/price-oracle/Dockerfile -t price-oracle:latest .

# 3. Create EIF
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli build-enclave \
  --docker-uri price-oracle:latest \
  --output-file /home/ubuntu/price-oracle-new.eif

# 4. Stop old enclave and start new one
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli terminate-enclave --all
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli run-enclave \
  --eif-path /home/ubuntu/price-oracle-new.eif \
  --memory 1024 \
  --cpu-count 2 \
  --enclave-cid 16 \
  --debug-mode
```

---

## Switching Between Unix Socket and Nitro Enclave

### Currently Using: Unix Socket Enclave (has network access)

To switch to Nitro Enclave for real attestation:

**1. Edit `/home/ubuntu/orbs-tee-host/src/index.ts`:**
```typescript
// Change from:
import { UnixSocketClient } from './vsock/client';
const vsockClient = new UnixSocketClient(config.vsock);

// To:
import { VsocketClient } from './vsock/client';
const vsockClient = new VsocketClient(config.vsock);
```

**2. Rebuild and restart:**
```bash
cd /home/ubuntu/orbs-tee-host
npm run build
sudo systemctl restart orbs-tee-host
```

**3. Start Nitro enclave:**
```bash
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli run-enclave \
  --eif-path /home/ubuntu/price-oracle-v3.eif \
  --memory 1024 \
  --cpu-count 2 \
  --enclave-cid 16 \
  --debug-mode
```

---

## Network Architecture

```
External Client (port 8080)
    ↓
Host API Server (TypeScript)
    ↓
Unix Socket (/tmp/enclave.sock)  OR  Vsock (CID 16, port 5000)
    ↓
Price Oracle Enclave (Rust)
    ↓
Binance API (https://api.binance.com)
```

---

## Current Configuration

- **Enclave Type:** Unix Socket (with network access)
- **API Port:** 8080 (HTTP)
- **Enclave Socket:** /tmp/enclave.sock
- **Price Source:** Real-time from Binance API
- **Signatures:** ECDSA secp256k1

---

## Quick Troubleshooting Checklist

1. **Is the host server running?**
   ```bash
   sudo systemctl status orbs-tee-host
   ```

2. **Is the enclave running?**
   ```bash
   ls -la /tmp/enclave.sock
   ps aux | grep price-oracle
   ```

3. **Can I connect to the API?**
   ```bash
   curl http://localhost:8080/api/v1/health
   ```

4. **Are there errors in logs?**
   ```bash
   sudo journalctl -u orbs-tee-host -n 50 | grep -i error
   ```

5. **Is port 8080 open?**
   ```bash
   lsof -i :8080
   ```

If all checks pass but still having issues, restart everything:
```bash
sudo systemctl restart orbs-tee-enclave orbs-tee-host
```

---

## Support

For issues or questions:
- Check logs first: `sudo journalctl -u orbs-tee-host -f`
- Verify all services are running
- Test endpoints manually
- Review this manual for common issues
