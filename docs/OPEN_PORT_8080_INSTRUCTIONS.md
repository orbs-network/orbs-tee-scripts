# Open Port 8080 for External Access

**Status**: Server is running on port 8080 but AWS Security Group is blocking external access

**Your Public IP**: `35.179.36.200`

---

## Quick Fix: Open Port 8080 in AWS Console

### Step 1: Go to AWS Console

1. Open AWS Console: https://console.aws.amazon.com/ec2/
2. Go to **EC2** → **Instances**
3. Find your instance: `ip-172-31-57-189`
4. Look at the **Security groups** section (in instance details)
5. Click on the security group name (e.g., `sg-xxxxx` or `launch-wizard-1`)

### Step 2: Add Inbound Rule

1. In the security group page, click **"Edit inbound rules"**
2. Click **"Add rule"**
3. Configure the new rule:
   - **Type**: Custom TCP
   - **Protocol**: TCP
   - **Port range**: `8080`
   - **Source**: `0.0.0.0/0` (allow from anywhere)
   - **Description**: `ORBS TEE Host API (dev)`
4. Click **"Save rules"**

### Step 3: Test Access

From your local machine (not the server):

```bash
# Health check
curl http://35.179.36.200:8080/api/v1/health

# Expected response:
# {"status":"unhealthy","enclaveConnected":true,"l3Reachable":false,"uptimeSeconds":500}
```

If it works, try getting a Bitcoin price:

```bash
curl -X POST http://35.179.36.200:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

---

## Alternative: Using AWS CLI

If you prefer command line:

```bash
# Get instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
echo "Instance: $INSTANCE_ID"

# Get security group ID
SG_ID=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text \
  --region eu-west-2)
echo "Security Group: $SG_ID"

# Add rule for port 8080
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0 \
  --region eu-west-2
```

---

## Current Server Status

✅ **Enclave**: Running on `/tmp/enclave.sock`
✅ **Host**: Running on `0.0.0.0:8080` (HTTP)
✅ **API**: Responding to local requests
⚠️ **Security Group**: Port 8080 closed (needs to be opened)

### Verify Server is Running

From the server:

```bash
# Check services
systemctl status orbs-tee-enclave orbs-tee-host

# Check port is listening
ss -tlnp | grep 8080

# Test locally
curl http://localhost:8080/api/v1/health
```

All should work locally. Once you open port 8080 in Security Group, external access will work too.

---

## Security Notes

### For Development (Current Setup)

- ✅ HTTP on port 8080
- ✅ Open to 0.0.0.0/0 (world)
- ⚠️ **No encryption** (fine for dev/testing)
- ⚠️ **No authentication** (fine for dev/testing)

This is **FINE for development** but **NOT for production**.

### For Production (Later)

When ready for production, you should:
1. ✅ Switch to HTTPS on port 443 (certificates already exist)
2. ✅ Enable TLS in config.json
3. ✅ Enable authentication
4. ✅ Enable rate limiting
5. ✅ Restrict source IPs (not 0.0.0.0/0)

We can set this up later when you're ready.

---

## Troubleshooting

### Still Can't Connect After Opening Port

1. **Check security group was updated**:
   - Go back to AWS Console → EC2 → Security Groups
   - Verify the rule for port 8080 exists
   - Check the rule has source `0.0.0.0/0`

2. **Check server is listening on 0.0.0.0** (not just 127.0.0.1):
   ```bash
   ss -tlnp | grep 8080
   # Should show: 0.0.0.0:8080 (not 127.0.0.1:8080)
   ```

3. **Check no firewall on server**:
   ```bash
   sudo iptables -L -n | grep 8080
   # Should show nothing (no iptables rules blocking)
   ```

4. **Check service is running**:
   ```bash
   systemctl status orbs-tee-host
   # Should show: active (running)
   ```

---

## Summary

**What to do**: Open port 8080 in AWS Security Group (AWS Console → EC2 → Security Groups)

**Then test**: `curl http://35.179.36.200:8080/api/v1/health`

**Time**: 2 minutes

---

*Once port is open, your guardian will be accessible from anywhere on HTTP port 8080*
