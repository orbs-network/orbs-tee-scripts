# Troubleshooting Port 8080 Access

## ✅ What's Working

```
✅ Services running:
   - Price Oracle: PID 17261
   - Host API: PID 17508

✅ Localhost works perfectly:
   curl http://localhost:8080/api/v1/health
   → {"status":"unhealthy","enclaveConnected":true...}

❌ Public IP blocked:
   curl http://35.179.36.200:8080/api/v1/health
   → Connection timeout
```

## 🔍 The Problem

AWS Security Group is still blocking external access to port 8080.

## ✅ Solution Steps

### Step 1: Verify Security Group Rule

Go to AWS Console and **double-check** the security group:

1. **AWS Console**: https://console.aws.amazon.com/ec2/
2. **Instances** → Find: `ip-172-31-57-189` or IP `35.179.36.200`
3. **Security** tab (bottom) → Click the Security Group link
4. **Inbound rules** tab

**Look for this rule:**
```
Type: Custom TCP
Port: 8080
Source: 0.0.0.0/0
```

### Step 2: If Rule Doesn't Exist

Click **Edit inbound rules** → **Add rule**:

| Field | Value |
|-------|-------|
| Type | Custom TCP |
| Protocol | TCP |
| Port range | **8080** |
| Source | 0.0.0.0/0 |
| Description | ORBS TEE API |

Click **Save rules**

### Step 3: Common Mistakes

❌ **Port 80** instead of **8080**
❌ **Port range 80-8080** instead of just **8080**
❌ **Wrong security group** (instance might have multiple)
❌ **Outbound rules** instead of **Inbound rules**
❌ **Didn't save** the changes

### Step 4: Wait & Test

After saving:
1. Wait 10 seconds
2. Test from your machine:

```bash
curl http://35.179.36.200:8080/api/v1/health
```

## 🔧 Alternative: Test with SSH Tunnel

If security group isn't working, use SSH tunnel temporarily:

**On your local machine:**
```bash
ssh -L 8080:localhost:8080 ubuntu@35.179.36.200

# Then in another terminal:
curl http://localhost:8080/api/v1/health
```

## 📊 Diagnostic Commands

Run these on the server to verify:

```bash
# 1. Check services
ps aux | grep -E "price-oracle|node.*8080"

# 2. Check port
lsof -i :8080

# 3. Test localhost
curl http://localhost:8080/api/v1/health

# 4. Test public IP (should timeout if blocked)
curl -m 5 http://35.179.36.200:8080/api/v1/health
```

## 🎯 What Each Should Show

### 1. Services Running
```
ubuntu  17261  price-oracle-unix
ubuntu  17508  node (host API)
```

### 2. Port Listening
```
node  17508  ubuntu  *:8080 (LISTEN)
```

### 3. Localhost Test
```json
{"status":"unhealthy","enclaveConnected":true,"l3Reachable":false}
```

### 4. Public IP Test
- **If blocked**: Connection timeout (current situation)
- **If working**: Same JSON as localhost

## 📸 Visual Guide

### Finding Security Group

```
EC2 Dashboard
  → Instances (running)
    → [Your instance]
      → Security tab (bottom)
        → Security groups: sg-xxxxxxxxxx ← Click this
          → Inbound rules tab
            → Edit inbound rules
              → Add rule (8080)
```

## 🆘 Still Not Working?

### Check Network ACLs
1. EC2 Console → VPC → Network ACLs
2. Find the ACL for your subnet
3. Ensure it allows port 8080

### Check Instance Metadata
```bash
# Get instance details
curl -s http://169.254.169.254/latest/meta-data/instance-id
curl -s http://169.254.169.254/latest/meta-data/public-ipv4
```

### Verify No VPN/Proxy Blocking
Test from a different network or device

## ✅ Success Test

When working, from **your machine**:

```bash
curl http://35.179.36.200:8080/api/v1/health
```

Should return instantly:
```json
{"status":"unhealthy","enclaveConnected":true,"l3Reachable":false,"uptimeSeconds":2300}
```

And get price:
```bash
curl -X POST http://35.179.36.200:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

Should return:
```json
{
  "id": "...",
  "success": true,
  "data": {
    "symbol": "BTCUSDT",
    "price": "107569.99",
    "source": "binance"
  },
  "signature": "b1982ccd..."
}
```

---

**Need more help?** Share screenshot of your Security Group inbound rules.
