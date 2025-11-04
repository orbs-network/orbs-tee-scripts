# Enable AWS Nitro Enclaves

**Current Status**: Running enclave in **development mode** (Unix socket)
**Goal**: Deploy to **real Nitro Enclave** for attestation

---

## Current Situation

You're on AWS Nitro-based EC2, but Nitro Enclaves are **not enabled**:

❌ Nitro CLI not installed
❌ NSM device not available (`/dev/nsm`)
❌ Nitro kernel modules not loaded
❌ Enclave running in Unix socket mode (dev)

**To get attestation working**, we need to:
1. Install Nitro CLI
2. Enable Nitro Enclaves on the instance
3. Build the enclave as an EIF (Enclave Image File)
4. Run it in a real Nitro Enclave
5. Update host to use vsocket instead of Unix socket

---

## Prerequisites

### 1. Check Instance Type

Your instance must support Nitro Enclaves:

```bash
# Check instance type
curl -s http://169.254.169.254/latest/meta-data/instance-type

# Supported types include:
# - m5.*, m5a.*, m5n.*
# - c5.*, c5a.*, c5n.*
# - r5.*, r5a.*, r5n.*
# - t3.* (some)
```

**Not all instance types support Nitro Enclaves!**

### 2. Enable Nitro Enclaves in EC2

**Via AWS Console**:
1. Stop the instance
2. Actions → Modify instance attributes → Nitro Enclaves
3. Check "Enable"
4. Start the instance

**Via AWS CLI**:
```bash
aws ec2 modify-instance-attribute \
  --instance-id <your-instance-id> \
  --enclave-options Enabled=true
```

---

## Installation Steps

### Step 1: Install Nitro CLI

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    docker.io \
    wget

# Add user to docker group
sudo usermod -aG docker ubuntu

# Download and install Nitro CLI
wget https://s3.amazonaws.com/aws-nitro-enclaves-cli/install.sh
chmod +x install.sh
sudo ./install.sh

# Verify installation
nitro-cli --version
```

### Step 2: Configure Nitro Enclaves Allocator

Edit `/etc/nitro_enclaves/allocator.yaml`:

```yaml
---
# Enclave configuration file.
#
# How much memory to allocate for enclaves (in MiB).
memory_mib: 2048

# How many CPUs to reserve for enclaves.
cpu_count: 2

# Alternatively, the exact CPUs to be reserved for the enclave can be explicitly
# configured by using `cpu_pool` (like below), instead of `cpu_count`.
# Note: cpu_count and cpu_pool conflict with each other. Only use exactly one of them.
# Example of reserving CPUs 2, 3, and 6 through 9:
# cpu_pool: 2,3,6-9
```

**Restart the allocator**:
```bash
sudo systemctl enable nitro-enclaves-allocator.service
sudo systemctl start nitro-enclaves-allocator.service
sudo systemctl status nitro-enclaves-allocator.service
```

### Step 3: Verify NSM Device

```bash
# Check NSM device exists
ls -la /dev/nsm

# Should show:
# crw------- 1 root root 10, 144 Nov  3 18:00 /dev/nsm
```

---

## Build Enclave as EIF

### Option 1: Build from Docker (Recommended)

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro

# Create Dockerfile for enclave
cat > Dockerfile.enclave <<'EOF'
FROM ubuntu:24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    libssl-dev \
    pkg-config

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Copy enclave code
WORKDIR /app
COPY . .

# Build enclave with nitro features
RUN cargo build --release --features nitro --manifest-path examples/price-oracle/Cargo.toml

# Entry point
CMD ["/app/examples/price-oracle/target/release/price-oracle"]
EOF

# Build Docker image
docker build -f Dockerfile.enclave -t orbs-tee-enclave:latest .

# Build EIF (Enclave Image File)
nitro-cli build-enclave \
  --docker-uri orbs-tee-enclave:latest \
  --output-file orbs-tee-enclave.eif

# This will output:
# - Enclave Image File: orbs-tee-enclave.eif
# - PCR0, PCR1, PCR2 values (code measurements)
```

### Option 2: Direct Build (Without Docker)

```bash
cd /home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle

# Build with nitro features
cargo build --release --features nitro

# Convert to EIF
nitro-cli build-enclave \
  --binary-path target/release/price-oracle \
  --output-file orbs-tee-enclave.eif
```

---

## Run Enclave in Nitro

### Start the Enclave

```bash
# Run enclave
nitro-cli run-enclave \
  --eif-path orbs-tee-enclave.eif \
  --cpu-count 2 \
  --memory 2048 \
  --debug-mode

# This will output:
# {
#   "EnclaveID": "i-abc123...",
#   "ProcessID": 12345,
#   "EnclaveCID": 16
# }
```

**Important**: Note the **EnclaveCID** (e.g., 16) - you'll need this for the host config!

### Verify Enclave is Running

```bash
# List running enclaves
nitro-cli describe-enclaves

# View enclave console output (debug mode)
nitro-cli console --enclave-id <enclave-id>
```

---

## Update Host Configuration

### Change from Unix Socket to vsocket

Edit `/home/ubuntu/orbs-tee-host/config.json`:

**Before** (Unix socket - development):
```json
{
  "vsock": {
    "socketPath": "/tmp/enclave.sock"
  }
}
```

**After** (vsocket - Nitro Enclave):
```json
{
  "vsock": {
    "cid": 16,
    "port": 3000,
    "timeoutMs": 30000,
    "retryAttempts": 5,
    "retryDelayMs": 100
  }
}
```

**Note**: Use the CID from `nitro-cli run-enclave` output.

### Restart Host Service

```bash
sudo systemctl restart orbs-tee-host

# Check logs
journalctl -u orbs-tee-host -f
```

---

## Test Attestation

### 1. Test Health

```bash
curl -k https://localhost:8443/api/v1/health
```

Should show `enclaveConnected: true`.

### 2. Test Attestation Endpoint

```bash
curl -k -X POST https://localhost:8443/api/v1/attest
```

**Expected response** (success):
```json
{
  "status": "submitted",
  "attestationId": "att-uuid-1234",
  "submissionTime": "2025-11-03T18:00:00Z"
}
```

### 3. Get Attestation Document Directly

```bash
# Request attestation from enclave
curl -k -X POST https://localhost:8443/api/v1/request \
  -H "Content-Type: application/json" \
  -d '{"method":"get_attestation","params":{}}'
```

Should return:
```json
{
  "success": true,
  "data": {
    "attestation": "base64-encoded-attestation-doc",
    "certificates": ["base64-cert-1", "base64-cert-2"],
    "publicKey": "0x03..."
  }
}
```

---

## Troubleshooting

### NSM Device Not Found

```bash
# Check if Nitro Enclaves enabled
sudo systemctl status nitro-enclaves-allocator

# Check kernel modules
lsmod | grep nitro

# Reload modules
sudo modprobe nitro_enclaves
```

### Enclave Won't Start

```bash
# Check allocator has resources
cat /sys/module/nitro_enclaves/parameters/ne_cpus
cat /sys/module/nitro_enclaves/parameters/ne_mem_mib

# Check Docker is running
sudo systemctl status docker

# Try debug mode
nitro-cli run-enclave \
  --eif-path orbs-tee-enclave.eif \
  --cpu-count 2 \
  --memory 2048 \
  --debug-mode
```

### Host Can't Connect to Enclave

```bash
# Check enclave is running
nitro-cli describe-enclaves

# Check vsock CID is correct
# Update config.json with correct CID from describe-enclaves

# Check enclave console for errors
nitro-cli console --enclave-id <enclave-id>
```

### Instance Type Not Supported

If your instance type doesn't support Nitro Enclaves:

1. **Stop the instance**
2. **Change instance type** to supported type (e.g., m5.large)
3. **Enable Nitro Enclaves** in instance settings
4. **Start the instance**

---

## Systemd Service for Nitro Enclave

Create a systemd service to auto-start the enclave:

**File**: `/etc/systemd/system/orbs-tee-nitro-enclave.service`

```ini
[Unit]
Description=ORBS TEE Nitro Enclave
After=nitro-enclaves-allocator.service docker.service
Requires=nitro-enclaves-allocator.service docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/home/ubuntu/orbs-tee-enclave-nitro

# Stop any running enclaves
ExecStartPre=/bin/sh -c 'nitro-cli terminate-enclave --all || true'

# Start enclave
ExecStart=/usr/bin/nitro-cli run-enclave \
  --eif-path /home/ubuntu/orbs-tee-enclave-nitro/orbs-tee-enclave.eif \
  --cpu-count 2 \
  --memory 2048

# On stop, terminate enclave
ExecStop=/usr/bin/nitro-cli terminate-enclave --all

Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

**Enable and start**:
```bash
sudo systemctl daemon-reload
sudo systemctl enable orbs-tee-nitro-enclave
sudo systemctl start orbs-tee-nitro-enclave
```

---

## Summary

**Current**: Running in development mode (Unix socket)
**Goal**: Running in Nitro Enclave (vsocket + attestation)

**Steps**:
1. ✅ Check instance supports Nitro Enclaves
2. ⚙️ Enable Nitro Enclaves on instance (AWS Console)
3. ⚙️ Install Nitro CLI
4. ⚙️ Configure allocator (CPU/memory)
5. ⚙️ Build enclave as EIF
6. ⚙️ Run enclave in Nitro
7. ⚙️ Update host config (vsocket)
8. ✅ Test attestation endpoint

**Result**: Real TEE attestation with AWS Nitro! 🚀

---

## Need Help?

1. Check AWS docs: https://docs.aws.amazon.com/enclaves/
2. Check instance supports enclaves
3. Make sure to enable in EC2 instance settings
4. Start with debug mode for troubleshooting

---

*Ready to enable real Nitro Enclaves and attestation!*
