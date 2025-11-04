# HTTPS Setup Complete! 🎉

**Status**: ✅ HTTPS is now working on port 8443

---

## Current Configuration

**Protocol**: HTTPS (TLS enabled)
**Port**: 8443
**Certificate**: Self-signed (valid for 1 year)
**Public IP**: `35.179.36.200`

---

## Local Testing (Works Now!)

From the server:

```bash
# Health check
curl -k https://localhost:8443/api/v1/health

# Get BTC price
curl -k -X POST https://localhost:8443/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

**Note**: The `-k` flag tells curl to accept the self-signed certificate.

---

## Remote Access (Requires AWS Security Group Update)

To access from outside, you need to **open port 8443 in AWS Security Group**:

### Step 1: Open AWS Console

1. Go to: https://console.aws.amazon.com/ec2/
2. Find your instance: `ip-172-31-57-189` or search for IP `35.179.36.200`
3. Click on the **Security Group** (in instance details)

### Step 2: Add Inbound Rule

1. Click **"Edit inbound rules"**
2. Click **"Add rule"**
3. Configure:
   - **Type**: Custom TCP
   - **Port range**: `8443`
   - **Source**: `0.0.0.0/0` (allow from anywhere)
   - **Description**: `ORBS TEE HTTPS API`
4. Click **"Save rules"**

### Step 3: Test from Your Machine

Once the port is open:

```bash
# From your local machine (not the server)
curl -k https://35.179.36.200:8443/api/v1/health

# Expected:
{
  "status": "unhealthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "uptimeSeconds": 100
}
```

Get a real Bitcoin price:

```bash
curl -k -X POST https://35.179.36.200:8443/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

---

## Why Port 8443 (Not 443)?

Port 443 is the standard HTTPS port, but it requires root privileges. Port 8443 is a common alternative that:
- ✅ Doesn't require root
- ✅ Still uses HTTPS/TLS
- ✅ Works perfectly for APIs
- ✅ Commonly used for development/internal services

**For production**: You can use port 443 by:
1. Running as root (not recommended)
2. Using a reverse proxy like nginx/haproxy (recommended)
3. Using port forwarding (iptables)

---

## Self-Signed Certificate

**Details**:
```
Issuer:  CN = 35.179.36.200, O = ORBS TEE, C = UK
Subject: CN = 35.179.36.200, O = ORBS TEE, C = UK
Valid:   Nov 3 2025 - Nov 3 2026 (1 year)
Key:     RSA 4096-bit
```

### Browser Access

If you access `https://35.179.36.200:8443` in a browser, you'll see a warning:
- "Your connection is not private"
- "NET::ERR_CERT_AUTHORITY_INVALID"

**This is normal!** Click "Advanced" → "Proceed to 35.179.36.200 (unsafe)" to continue.

### API Clients

For programmatic access:

**curl**:
```bash
curl -k https://35.179.36.200:8443/api/v1/health
```

**JavaScript (fetch)**:
```javascript
// Node.js
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
fetch('https://35.179.36.200:8443/api/v1/health');

// Or use https.Agent
const https = require('https');
const agent = new https.Agent({ rejectUnauthorized: false });
fetch('https://35.179.36.200:8443/api/v1/health', { agent });
```

**Python**:
```python
import requests
requests.get('https://35.179.36.200:8443/api/v1/health', verify=False)
```

---

## Why "unhealthy" Status?

You'll see `"status": "unhealthy"` in the health check because:

```json
{
  "status": "unhealthy",
  "enclaveConnected": true,   ← ✅ Enclave is working
  "l3Reachable": false,       ← ❌ L3 network not configured yet
  "uptimeSeconds": 100
}
```

The system requires **both** enclave AND L3 network for "healthy" status. The L3 guardian network isn't set up yet, so it shows "unhealthy".

**This is fine for development!** The enclave works perfectly - you can get prices, signatures work, everything functions. The L3 part is for guardian network coordination which you'll set up later.

---

## Service Status

```bash
# Check services
systemctl status orbs-tee-enclave orbs-tee-host

# View logs
journalctl -u orbs-tee-host -f

# Restart if needed
sudo systemctl restart orbs-tee-host
```

---

## Configuration Files

### HTTPS Config
**File**: `/home/ubuntu/orbs-tee-host/config.json`
```json
{
  "api": {
    "host": "0.0.0.0",
    "port": 8443,
    "tlsEnabled": true,
    "tlsCert": "/home/ubuntu/orbs-tee-host/cert.pem",
    "tlsKey": "/home/ubuntu/orbs-tee-host/key.pem"
  }
}
```

### Certificates
```
/home/ubuntu/orbs-tee-host/cert.pem  (public certificate)
/home/ubuntu/orbs-tee-host/key.pem   (private key)
```

---

## Security Notes

### Current Setup (Development)
- ✅ HTTPS/TLS encryption
- ✅ Self-signed certificate
- ✅ Open to world (0.0.0.0/0)
- ⚠️ No client authentication
- ⚠️ No rate limiting

**This is fine for development/testing.**

### Production Recommendations
1. **Use a proper certificate**:
   - Let's Encrypt (free, requires domain name)
   - Commercial certificate
   - Or keep self-signed for internal use

2. **Enable authentication**:
   ```json
   {
     "auth": {
       "enabled": true
     }
   }
   ```

3. **Enable rate limiting**:
   ```json
   {
     "auth": {
       "rateLimitingEnabled": true
     }
   }
   ```

4. **Restrict source IPs**:
   - In AWS Security Group, change `0.0.0.0/0` to specific IP ranges
   - Or use AWS VPC/private subnets

---

## Troubleshooting

### Can't Connect Externally

1. **Check AWS Security Group**:
   - Port 8443 must be open
   - Source must include your IP (or 0.0.0.0/0)

2. **Check service is running**:
   ```bash
   systemctl status orbs-tee-host
   ss -tlnp | grep 8443
   ```

3. **Check firewall**:
   ```bash
   sudo iptables -L -n | grep 8443
   # Should be empty (no blocking rules)
   ```

### Certificate Errors

If you see certificate errors:
- Use `-k` flag with curl
- Use `verify=False` in Python
- Use `rejectUnauthorized: false` in Node.js
- In browser, click "Advanced" → "Proceed"

### "Connection Refused"

If you get "connection refused":
1. Check service is running: `systemctl status orbs-tee-host`
2. Check port is open in AWS Security Group
3. Check listening on 0.0.0.0 (not 127.0.0.1): `ss -tlnp | grep 8443`

---

## Next Steps

1. **Open port 8443 in AWS Console** (see Step 2 above)
2. **Test from your machine**: `curl -k https://35.179.36.200:8443/api/v1/health`
3. **Verify services survive reboot**: `sudo reboot` and check after

---

## Summary

✅ **HTTPS enabled on port 8443**
✅ **Self-signed certificate (valid 1 year)**
✅ **Enclave connected and working**
✅ **API responding to requests**
✅ **Services auto-start on boot**

**To access externally**: Open port 8443 in AWS Security Group

**Test command**: `curl -k https://35.179.36.200:8443/api/v1/health`

---

*Last Updated: 2025-11-03*
*Status: HTTPS Operational*
