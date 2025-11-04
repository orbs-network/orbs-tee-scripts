# Enable Nitro Enclaves - AWS Console Steps

**Your Instance ID**: `i-08e0d9d2da1c6b79e`
**Your IP**: `35.179.36.200`
**Region**: eu-west-2 (London)

---

## Step-by-Step Instructions

### Step 1: Open AWS Console

Go to: https://console.aws.amazon.com/ec2/v2/home?region=eu-west-2#Instances:

(This link goes directly to EC2 Instances in London region)

### Step 2: Find Your Instance

You'll see a list of instances. Find yours by:

**Option A**: Look for instance ID `i-08e0d9d2da1c6b79e`

**Option B**: Look for public IP `35.179.36.200`

**Option C**: Use the search/filter box at the top:
- Type: `i-08e0d9d2da1c6b79e`
- OR type: `35.179.36.200`

**Click the checkbox** next to your instance to select it.

---

### Step 3: Stop the Instance

1. At the top right, click the **"Instance state"** button (dropdown)
2. Select **"Stop instance"**
3. A popup appears: "Stop these instances?"
4. Click **"Stop"** (orange button)

**Wait**: The "Instance state" column will show:
- "Stopping" (wait...)
- "Stopped" (✓ ready to continue)

**Time**: 1-2 minutes

---

### Step 4: Enable Nitro Enclaves

Once it shows "Stopped":

1. Click the **"Actions"** button (top right)
2. In the dropdown, hover over **"Instance settings"**
3. Click **"Change nitro enclaves"**

A popup appears: "Change nitro enclaves"

4. **Check the box**: ☑️ "Enable"
5. Click **"Save"** (bottom right)

You should see a green success message: "Successfully modified enclave options"

---

### Step 5: Start the Instance

1. Click the **"Instance state"** button again (top right)
2. Select **"Start instance"**
3. A popup appears: "Start these instances?"
4. Click **"Start"** (orange button)

**Wait**: The "Instance state" column will show:
- "Pending" (wait...)
- "Running" (✓ ready!)

**Time**: 1-2 minutes

---

### Step 6: Wait for Services to Start

The instance is running, but wait **1-2 more minutes** for:
- Services to start
- Network to be ready
- SSH to be accessible

---

### Step 7: SSH Back In

From your local terminal:

```bash
ssh ubuntu@35.179.36.200
```

---

### Step 8: Verify Nitro Enclaves is Enabled

Once you're back in the server:

```bash
# Check for NSM device
ls -la /dev/nsm
```

**Expected output**:
```
crw------- 1 root root 10, 144 Nov  3 18:15 /dev/nsm
```

**Also check**:
```bash
# Check kernel module
lsmod | grep nitro
```

**Expected output**:
```
nitro_enclaves         24576  0
```

---

## If You See /dev/nsm - Success! ✅

**Tell me you're back** and I'll immediately:
1. Install Nitro CLI
2. Build the enclave as EIF
3. Run it in a real Nitro Enclave
4. Update the host configuration
5. Test attestation endpoint
6. Get real TEE attestation working!

---

## Screenshot Guide (Where to Click)

### Stop Instance:
```
Top of page:
┌─────────────────────────────────────────┐
│ [Instance state ▼]  [Connect]  [Actions]│  ← Click "Instance state"
└─────────────────────────────────────────┘
                ↓
        [Stop instance]  ← Click this
```

### Enable Nitro Enclaves:
```
Top of page:
┌─────────────────────────────────────────┐
│ [Instance state]  [Connect]  [Actions ▼]│  ← Click "Actions"
└─────────────────────────────────────────┘
                ↓
        [Instance settings →]  ← Hover
                ↓
        [Change nitro enclaves]  ← Click this
```

In the popup:
```
┌──────────────────────────────┐
│ Change nitro enclaves        │
│                              │
│ ☑ Enable                     │  ← Check this box
│                              │
│        [Cancel]  [Save]      │  ← Click Save
└──────────────────────────────┘
```

---

## Troubleshooting

### Can't Find the Instance

- Make sure you're in the correct region: **eu-west-2 (London)**
- Check the region dropdown at the top right of AWS Console
- Try searching by IP: `35.179.36.200`

### "Stop instance" is Grayed Out

- Instance might already be stopped (check "Instance state" column)
- If it says "Stopped", skip to Step 4

### Can't Find "Change nitro enclaves" Option

**Possible reasons**:

1. **Instance type doesn't support Nitro Enclaves**
   - Check "Instance type" column
   - Supported: m5.*, c5.*, r5.*, t3.*
   - If not supported, you need to change instance type first

2. **Instance is not stopped**
   - Make sure it's fully stopped (not "Stopping")

### No /dev/nsm After Enabling

If after enabling and restarting, you still don't see `/dev/nsm`:

```bash
# Try installing kernel modules
sudo apt-get install linux-modules-extra-$(uname -r)

# Reboot
sudo reboot
```

Wait 2 minutes, SSH back in, and check again.

---

## Quick Summary

1. ✅ AWS Console → EC2 → Instances
2. ✅ Find `i-08e0d9d2da1c6b79e`
3. ✅ Instance state → **Stop instance** → wait
4. ✅ Actions → Instance settings → **Change nitro enclaves** → ☑ Enable → Save
5. ✅ Instance state → **Start instance** → wait
6. ✅ SSH back: `ssh ubuntu@35.179.36.200`
7. ✅ Verify: `ls -la /dev/nsm`

**Total time**: 5-7 minutes

---

## After Verification

When you see `/dev/nsm` exists, **let me know** and I'll continue with:
- Nitro CLI installation
- Building EIF
- Running enclave in Nitro
- Testing attestation

**I'll be waiting here!** 🚀
