# Nitro Enclave Network Access - Problem Analysis & Solution Plan

**Status:** ⚠️ UNRESOLVED
**Date:** 2025-11-04
**Priority:** HIGH - Blocks real attestation functionality

---

## 🎯 The Goal

Get Nitro Enclave working with:
- ✅ Real attestation from NSM device (`/dev/nsm`)
- ✅ Network access to fetch prices from Binance API
- ✅ Both working at the same time

---

## 📊 Current Situation

### What's Working ✅

**Unix Socket Enclave** (Currently Running):
- Path: `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle-unix/target/debug/price-oracle-unix`
- Socket: `/tmp/enclave.sock`
- Network: ✅ Can fetch from Binance API
- Prices: ✅ Real-time BTC, ETH, etc.
- Signatures: ✅ ECDSA secp256k1
- NSM Device: ❌ `/dev/nsm` doesn't exist (not in Nitro enclave)
- Attestation: ❌ Returns error (correct behavior - no mock data)

### What's NOT Working ❌

**Nitro Enclave**:
- EIF Files: `/home/ubuntu/price-oracle-v3.eif` (165MB - latest)
- NSM Device: ✅ `/dev/nsm` exists inside enclave
- Attestation: ✅ Would work with NSM device
- Network: ❌ DNS resolution fails
- Prices: ❌ Cannot fetch from Binance due to network issue

---

## 🔍 The Core Problem

### DNS Resolution Fails Inside Nitro Enclave

**The Chain:**
```
Nitro Enclave Application
    ↓ (wants to resolve api.binance.com)
/etc/resolv.conf (points to 127.0.0.1)
    ↓
socat (forwards DNS via vsock)
    ↓ (vsock CID 3, port 53)
Parent EC2 Instance
    ↓
vsock-proxy-dns service (should forward to real DNS)
    ↓
Internet DNS servers
```

**Somewhere in this chain, it breaks!**

---

## 🧪 Evidence

### 1. Previous Enclave Logs Show NSM Working

From `/var/log/nitro_enclaves/nitro_enclaves.log`:
```
[NSM RNG: returning rand bytes = 64]
📨 Received request... get_price
💰 Fetching price for BTCUSDT
```

This proves:
- ✅ NSM device was accessible
- ✅ Enclave could receive requests via vsock
- ❓ But we don't see if Binance API calls succeeded

### 2. Enclave Was Terminated

Timeline:
- **Nov 3, 19:17** - `price-oracle-v2.eif` launched
- **Nov 4, 06:27** - v2 terminated, `price-oracle-v3.eif` launched
- **Nov 4, 06:31** - v3 terminated
- **Current** - Using Unix socket enclave instead

### 3. Current Dockerfile Configuration

Located at: `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/Dockerfile`

```dockerfile
# Install socat for DNS forwarding
RUN yum install -y ca-certificates socat iproute

# Startup script sets up DNS
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'echo "nameserver 127.0.0.1" > /etc/resolv.conf' >> /app/start.sh && \
    echo 'socat UDP4-LISTEN:53,fork,reuseaddr VSOCK-CONNECT:3:53 &' >> /app/start.sh && \
    echo 'sleep 2' >> /app/start.sh && \
    echo 'exec /app/price-oracle-enclave' >> /app/start.sh
```

**Potential Issues:**
- socat might not start in time (only 2 second sleep)
- DNS forwarding might fail silently
- No error logging for socat failures

### 4. Parent vsock-proxy Services

**vsock-proxy-dns.service:**
- Command: `vsock-proxy 53 8.8.8.8 53`
- Should forward DNS queries to Google DNS
- Status: Unknown if running correctly

**vsock-proxy-https.service:**
- Command: `vsock-proxy 443 18.245.252.159 443`
- Forwards HTTPS to Binance API IP
- Status: Unknown if running correctly

---

## 🚧 What's Been Tried (All Failed)

1. ✅ Installed vsock-proxy
2. ✅ Created vsock-proxy-dns systemd service
3. ✅ Created vsock-proxy-https systemd service
4. ✅ Modified Dockerfile to add socat
5. ✅ Added DNS forwarding in startup script
6. ✅ Built new EIF (v3) with these changes
7. ✅ Launched Nitro enclave with new EIF
8. ❌ **Still got DNS errors**

---

## 🔧 What Needs Investigation (NO FIXES YET)

### 1. Check vsock-proxy Services Status

**Commands to run:**
```bash
sudo systemctl status vsock-proxy-dns
sudo systemctl status vsock-proxy-https
sudo journalctl -u vsock-proxy-dns -n 50
sudo journalctl -u vsock-proxy-https -n 50
```

**What to look for:**
- Are they running?
- Any error messages?
- Are they actually forwarding traffic?

### 2. Test DNS Resolution from Parent

**Commands to run:**
```bash
# Test if parent can resolve
dig api.binance.com @8.8.8.8

# Test if local DNS works
dig api.binance.com

# Check parent's DNS config
cat /etc/resolv.conf
```

**What to verify:**
- Parent EC2 can resolve DNS
- Parent can reach Binance API
- DNS servers are accessible

### 3. Check vsock-proxy Allowlist

**File:** `/etc/nitro_enclaves/vsock-proxy.yaml`

**What to check:**
- Is 8.8.8.8:53 allowed for DNS?
- Is Binance API IP allowed for HTTPS?
- Is wildcard 0.0.0.0/0 allowed or specific IPs?

### 4. Verify Network from Parent

**Commands to run:**
```bash
# Can parent reach Binance?
curl -v https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT

# Check DNS resolution
nslookup api.binance.com

# Check routing
ip route
```

**What to verify:**
- Parent has internet access
- Binance API is reachable
- No firewall blocking

### 5. Launch Nitro Enclave with Better Logging

**Commands to test:**
```bash
# Terminate any running enclave
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli terminate-enclave --all

# Launch with console output
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli run-enclave \
  --eif-path /home/ubuntu/price-oracle-v3.eif \
  --memory 1024 \
  --cpu-count 2 \
  --enclave-cid 16 \
  --debug-mode

# Watch console for errors
sudo /tmp/nitro-cli/build/install/usr/bin/nitro-cli console --enclave-id <ID>
```

**What to look for:**
- Does socat start?
- Any DNS resolution errors?
- Does app try to fetch from Binance?
- What error messages appear?

---

## 💡 Potential Root Causes (To Investigate)

### Theory 1: socat Not Starting
**Symptom:** socat command fails silently
**Why:** Missing permissions, wrong vsock CID, timing issue
**How to verify:** Add logging before/after socat in Dockerfile

### Theory 2: vsock-proxy Not Forwarding
**Symptom:** Traffic not reaching DNS server
**Why:** Service not running, allowlist blocking, wrong config
**How to verify:** Check vsock-proxy logs, test with tcpdump

### Theory 3: Timing Issue
**Symptom:** App starts before DNS ready
**Why:** 2 second sleep not enough
**How to verify:** Increase sleep time, add retry logic in app

### Theory 4: Wrong DNS Server
**Symptom:** Forwarding to wrong IP
**Why:** 8.8.8.8 might be blocked by AWS network
**How to verify:** Try VPC DNS server (169.254.169.253) instead

### Theory 5: Enclave Security Policy
**Symptom:** NSM restricts network access
**Why:** Nitro security model might block certain traffic
**How to verify:** Check AWS documentation, enclave PCR values

---

## 📋 Systematic Debugging Plan (NOT YET EXECUTED)

### Phase 1: Verify Parent Connectivity
1. Check parent can reach Binance API
2. Verify DNS works on parent
3. Check security groups allow outbound 443/53
4. Test vsock-proxy services are running

### Phase 2: Improve Enclave Logging
1. Modify Dockerfile to log socat startup
2. Add DNS test before app starts
3. Add network diagnostics in startup script
4. Rebuild EIF with better logging

### Phase 3: Test Step by Step
1. Launch enclave
2. Watch console for startup messages
3. Verify socat is running (check process list)
4. Test DNS resolution from inside enclave
5. Try manual curl to Binance from enclave

### Phase 4: Fix Based on Findings
*(Will document after investigation)*

---

## 🎓 Alternative Approaches (Not Tried)

### Option A: Use VPC DNS Instead of 8.8.8.8
```bash
# VPC DNS is always at .2 of VPC CIDR
# For most VPCs: 169.254.169.253
vsock-proxy 53 169.254.169.253 53
```

### Option B: Pre-resolve IPs, No DNS Needed
- Look up Binance API IP: `18.245.252.159`
- Hardcode IP in application
- Skip DNS resolution entirely
- **Downside:** Brittle if IP changes

### Option C: HTTP Proxy Instead of DNS
- Run HTTP proxy on parent (squid, tinyproxy)
- Forward all HTTP through proxy
- Proxy handles DNS resolution
- **Downside:** More complex setup

### Option D: Use AWS PrivateLink
- Create VPC endpoint for Binance API
- No internet gateway needed
- More secure, more reliable
- **Downside:** Requires AWS infrastructure changes

---

## ⚠️ Why We Can't Fix From AWS UI

The problem is NOT:
- ❌ Security groups (parent has internet access)
- ❌ Route tables (Unix socket enclave works)
- ❌ Network ACLs (would block everything)
- ❌ Public IP assignment (parent is reachable)

The problem IS:
- ✅ Enclave-to-parent vsock communication
- ✅ DNS forwarding configuration
- ✅ socat/vsock-proxy setup
- ✅ Timing and initialization order

**These require code/config changes, not AWS console changes.**

---

## 📊 Decision Matrix

| Approach | Effort | Risk | Attestation | Network | Notes |
|----------|--------|------|-------------|---------|-------|
| Keep Unix Socket | Low | Low | ❌ No | ✅ Yes | Current state |
| Fix DNS in Nitro | High | Medium | ✅ Yes | ❓ Maybe | Requires debugging |
| Hardcode IPs | Low | High | ✅ Yes | ✅ Yes | Brittle solution |
| HTTP Proxy | Medium | Medium | ✅ Yes | ✅ Yes | More components |
| AWS PrivateLink | High | Low | ✅ Yes | ✅ Yes | Infrastructure change |

---

## 🚀 Recommended Next Steps

1. **Investigate** (DON'T FIX YET):
   - Check vsock-proxy service logs
   - Verify parent network connectivity
   - Review vsock-proxy allowlist
   - Test DNS from parent EC2

2. **Document Findings**:
   - Note what's working vs broken
   - Identify exact failure point
   - Understand root cause before fixing

3. **Discuss Approach**:
   - Review findings with user
   - Decide on best solution
   - Plan implementation carefully

4. **Implement Fix**:
   - Make targeted changes based on investigation
   - Test incrementally
   - Verify both network AND attestation work

---

## 📝 Related Files

**Configuration:**
- `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/Dockerfile`
- `/etc/systemd/system/vsock-proxy-dns.service`
- `/etc/systemd/system/vsock-proxy-https.service`
- `/etc/nitro_enclaves/vsock-proxy.yaml`

**Binaries:**
- `/home/ubuntu/price-oracle-v3.eif` (latest Nitro enclave)
- `/home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle-unix/target/debug/price-oracle-unix` (Unix socket, currently running)

**Logs:**
- `/var/log/nitro_enclaves/nitro_enclaves.log`
- `sudo journalctl -u vsock-proxy-dns`
- `sudo journalctl -u vsock-proxy-https`

**Documentation:**
- `/home/ubuntu/.claude-session-state.json` (session state for Claude)
- `/home/ubuntu/orbs-tee-scripts/docs/OPS_MANUAL.md`

---

## ⏰ Session Notes

**User Preference:** Understand issue before fixing - no automatic attempts
**Last Updated:** 2025-11-04 07:20 UTC
**Next Session:** Start by reading `.claude-session-state.json`

**Status:** Investigation phase - NO FIXES ATTEMPTED YET
