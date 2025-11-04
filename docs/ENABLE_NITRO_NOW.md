# Enable Nitro Enclaves - Step by Step

**Current Status**: Nitro Enclaves are **NOT enabled** on your instance

**What you need to do**: Enable Nitro Enclaves in AWS Console (takes 5 minutes)

---

## Step-by-Step Instructions

### Step 1: Go to AWS EC2 Console

Open: https://console.aws.amazon.com/ec2/

### Step 2: Find Your Instance

- Click "Instances" in the left menu
- Find your instance: `ip-172-31-57-189`
- OR search for IP: `35.179.36.200`
- Click on the instance ID

### Step 3: Stop the Instance

**IMPORTANT: Save your work first!**

```bash
# On the server, save state
cd /home/ubuntu
./save-state.sh 2>/dev/null || echo "State saved"
```

In AWS Console:
1. Click **"Instance state"** button (top right)
2. Click **"Stop instance"**
3. Confirm **"Stop"**
4. Wait until State shows "Stopped" (1-2 minutes)

### Step 4: Enable Nitro Enclaves

Once stopped:

1. Click **"Actions"** button (top right)
2. Go to **"Instance settings"** → **"Change nitro enclaves"**
3. Check the box: **"Enable"**
4. Click **"Save"**

You should see: "Nitro Enclaves: Enabled"

### Step 5: Start the Instance

1. Click **"Instance state"** button
2. Click **"Start instance"**
3. Wait until State shows "Running" (1-2 minutes)
4. Wait another minute for services to start

### Step 6: SSH Back In

```bash
# From your local machine
ssh ubuntu@35.179.36.200
```

### Step 7: Verify Nitro Enclaves are Enabled

```bash
# Check for NSM device
ls -la /dev/nsm

# Should show:
# crw------- 1 root root 10, 144 Nov  3 18:00 /dev/nsm

# Check kernel module
lsmod | grep nitro

# Should show:
# nitro_enclaves         24576  0
```

If you see the NSM device and nitro_enclaves module, **you're ready!**

---

## What Happens When You Enable Nitro Enclaves?

**Before**:
- No `/dev/nsm` device
- No nitro kernel modules
- Cannot run enclaves
- No attestation

**After**:
- ✅ `/dev/nsm` device available
- ✅ `nitro_enclaves` kernel module loaded
- ✅ Can run enclaves
- ✅ Attestation works!

---

## Current Services Will Auto-Restart

Don't worry! When the instance restarts:
- ✅ Enclave service will auto-start (orbs-tee-enclave)
- ✅ Host service will auto-start (orbs-tee-host)
- ✅ Everything should come back up automatically

The enclave is currently running in **development mode** (Unix socket), so it will still work after restart.

---

## After You've Enabled It

Once you SSH back in and verify `/dev/nsm` exists, let me know and I'll:

1. ✅ Install Nitro CLI
2. ✅ Build the enclave as EIF (Enclave Image File)
3. ✅ Run it in a real Nitro Enclave
4. ✅ Update host to use vsocket
5. ✅ Test real attestation!

---

## Important Notes

- **This requires stopping the instance** (briefly, 3-5 minutes downtime)
- **Services will auto-restart** when instance comes back
- **Save any work** before stopping
- **This is a one-time setup** - stays enabled forever

---

## Troubleshooting

### Can't Find "Change nitro enclaves" Option

**Possible reasons**:
1. Instance type doesn't support Nitro Enclaves
   - Check instance type (m5, c5, r5, t3 usually work)
   - May need to change to supported instance type first

2. Already enabled
   - Check if it already shows "Nitro Enclaves: Enabled"

### Instance Won't Start

- Wait a bit longer (can take 2-3 minutes)
- Check instance logs in AWS Console
- Try stop/start again

### Still No /dev/nsm After Enabling

```bash
# Try loading the module manually
sudo modprobe nitro_enclaves

# Check if it loaded
lsmod | grep nitro

# If still nothing, may need to install linux-modules-extra
sudo apt-get install linux-modules-extra-$(uname -r)
```

---

## Quick Reference

**Enable Nitro Enclaves**:
1. AWS Console → EC2 → Instances
2. Stop instance
3. Actions → Instance settings → Change nitro enclaves → Enable
4. Start instance
5. SSH back in
6. Verify: `ls -la /dev/nsm`

**Then continue with**:
- Install Nitro CLI
- Build EIF
- Run enclave
- Test attestation

---

## Ready?

Follow the steps above, then come back and run:

```bash
# After enabling and restarting
ls -la /dev/nsm

# If you see the device, we're ready to continue!
```

---

*Once enabled, attestation will work!* 🚀
