# Fix AWS Security Group for Port 8080

## The Problem

The API works locally but not from remote:
- ✅ `curl http://localhost:8080/api/v1/health` - **WORKS**
- ❌ `curl http://35.179.36.200:8080/api/v1/health` - **TIMEOUT**

This means AWS Security Group is blocking port 8080.

## The Solution

### Option 1: AWS Console (Easiest)

1. Go to AWS EC2 Console
2. Find your instance (ip-172-31-57-189)
3. Click on the Security Group
4. Click "Edit inbound rules"
5. Add a new rule:
   - **Type**: Custom TCP
   - **Port range**: 8080
   - **Source**: 0.0.0.0/0 (or your IP for testing)
   - **Description**: ORBS TEE Host API
6. Save

### Option 2: AWS CLI

```bash
# Get instance ID
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Get security group ID
SG_ID=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

# Add rule
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8080 \
  --cidr 0.0.0.0/0
```

### Verify

After adding the rule:

```bash
# From your local machine
curl http://35.179.36.200:8080/api/v1/health
```

Should return:
```json
{
  "status": "unhealthy",
  "enclaveConnected": true,
  "l3Reachable": false,
  "uptimeSeconds": 500
}
```

## Test Commands (After Fix)

```bash
# Health check
curl http://35.179.36.200:8080/api/v1/health

# Get BTC price
curl -X POST http://35.179.36.200:8080/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}'
```

## Security Note

For production:
- Restrict source IP to specific ranges
- Enable TLS/HTTPS
- Use authentication
- Rate limiting

For testing:
- 0.0.0.0/0 is OK temporarily
