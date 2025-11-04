# Open Port 8080 - Step by Step

Your API is **running and working locally** but blocked from remote access.

**Problem:** AWS Security Group is blocking port 8080
**Solution:** Add an inbound rule (takes 30 seconds)

---

## Quick Steps

### 1. Go to AWS Console
- Open: https://console.aws.amazon.com/ec2/
- Or search for "EC2" in AWS Console

### 2. Find Your Instance
- Click "Instances" in left sidebar
- Look for instance with IP: **35.179.36.200**
- Or hostname: **ip-172-31-57-189**

### 3. Click on Security Group
- Click on your instance
- Scroll down to "Security" tab
- Click on the Security Group name (looks like: sg-xxxxxxxxx)

### 4. Edit Inbound Rules
- Click "Edit inbound rules" button
- Click "Add rule"

### 5. Add the Rule
Fill in:
- **Type**: Custom TCP
- **Port range**: 8080
- **Source**: 0.0.0.0/0 (for testing - allows all IPs)
- **Description**: ORBS TEE Host API

### 6. Save
- Click "Save rules"
- Done! Port is now open

---

## Test It

From **your local machine** (not SSH):

```bash
# Health check
curl http://35.179.36.200:8080/api/v1/health

# Get Bitcoin price
curl -X POST http://35.179.36.200:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

---

## Expected Results

**Health Check:**
```json
{
  "status": "unhealthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "uptimeSeconds": 600
}
```

**Price Request:**
```json
{
  "id": "...",
  "success": true,
  "data": {
    "symbol": "BTCUSDT",
    "price": "107569.99000000",
    "source": "binance",
    "timestamp": 1762181051
  },
  "signature": "b1982ccd..."
}
```

---

## Security Note

For testing: `0.0.0.0/0` is fine
For production: Restrict to specific IPs or VPCs

---

## Still Having Issues?

Check:
1. ✅ Services running: `ps aux | grep -E "price-oracle|node.*8080"`
2. ✅ Port listening: `lsof -i :8080`
3. ✅ Security group rule saved properly
4. ✅ Correct port (8080, not 8008 or 80)

---

**Your Public IP**: 35.179.36.200
**Port**: 8080
**API Endpoints**: See /home/ubuntu/FINAL_STATUS.md
