# What to Push to GitHub Repository

**Date**: 2025-11-03
**Status**: Ready to push deployment infrastructure

---

## Summary

We've created a **complete guardian deployment system** that should be pushed to repositories:

1. **Guardian Setup Script** - One-command deployment
2. **Systemd Services** - Auto-start/restart configuration
3. **Documentation** - Complete deployment guides
4. **Configuration Examples** - For guardians to copy

---

## Files Created for Repository

### 1. Guardian Deployment Infrastructure ⭐

**Critical files that MUST be in repository**:

```
/home/ubuntu/
├── guardian-setup.sh              # Main deployment script (11K)
├── orbs-tee-enclave.service       # Systemd service template (824 bytes)
└── orbs-tee-host.service          # Systemd service template (893 bytes)
```

**Purpose**: Allow new guardians to deploy with one command.

**Where to push**: Create new repo `orbs-tee-deployment` OR add to existing repos.

### 2. Documentation ⭐

**Essential documentation**:

```
/home/ubuntu/
├── GUARDIAN_DEPLOYMENT.md         # Guardian deployment guide (11K) ⭐
├── SETUP_SUMMARY.md               # Setup instructions (11K)
├── INTEGRATION_TESTING.md         # Testing guide (13K)
├── WHY_PORT_8443.md               # Port 8443 explanation (6.3K)
├── HTTPS_SETUP_COMPLETE.md        # HTTPS setup guide (6.6K)
└── FINAL_DEPLOYMENT_STATUS.md     # Deployment complete status (8.3K)
```

**Where to push**:
- Main docs → `orbs-tee-deployment` repo
- Technical docs → Each component repo (enclave/host)

### 3. Development/Session Notes

**Optional (dev notes, not essential for guardians)**:

```
/home/ubuntu/
├── WHERE_WE_LEFT_OFF.md           # Session notes
├── CURRENT_STATUS.md              # Current status
├── FINAL_STATUS.md                # Previous status
├── RECONNECTION_GUIDE.md          # SSH session guide
├── PERMISSIONS.md                 # Permissions tracking
├── AWS_SECURITY_GROUP_FIX.md      # AWS troubleshooting
└── TROUBLESHOOT_PORT_8080.md      # Port troubleshooting
```

**Where to push**: Optional, can go in a `docs/dev-notes/` folder.

### 4. Host Repository Changes

**Modified in orbs-tee-host**:

```bash
$ cd /home/ubuntu/orbs-tee-host && git status
Changes not staged for commit:
	modified:   src/api/routes/attest.ts
```

**Action needed**: Review and commit changes to `orbs-tee-host` repo.

### 5. Enclave Repository Status

```bash
$ cd /home/ubuntu/orbs-tee-enclave-nitro && git status
nothing to commit, working tree clean
```

✅ Enclave repo is clean, no changes needed.

---

## Recommended Repository Structure

### Option 1: New Deployment Repository (Recommended)

Create: `orbs-tee-deployment` repository

```
orbs-tee-deployment/
├── README.md                       # Quick start guide
├── guardian-setup.sh               # Main setup script
├── systemd/
│   ├── orbs-tee-enclave.service
│   └── orbs-tee-host.service
├── docs/
│   ├── GUARDIAN_DEPLOYMENT.md      # Main guide
│   ├── SETUP_SUMMARY.md
│   ├── INTEGRATION_TESTING.md
│   ├── WHY_PORT_8443.md
│   └── HTTPS_SETUP.md
├── examples/
│   ├── config.json                 # Example configuration
│   └── aws-security-group.json     # Example SG config
└── scripts/
    ├── install-dependencies.sh
    ├── build-enclave.sh
    └── build-host.sh
```

**Benefits**:
- ✅ Single repo for all deployment needs
- ✅ Easy for guardians to clone and run
- ✅ Clear separation from code repos
- ✅ CI/CD can test deployment script

### Option 2: Add to Existing Repositories

**In `orbs-tee-enclave-nitro`**:
```
orbs-tee-enclave-nitro/
├── deployment/
│   ├── systemd/
│   │   └── orbs-tee-enclave.service
│   └── docs/
│       └── DEPLOYMENT.md
```

**In `orbs-tee-host`**:
```
orbs-tee-host/
├── deployment/
│   ├── systemd/
│   │   └── orbs-tee-host.service
│   ├── guardian-setup.sh
│   └── docs/
│       ├── GUARDIAN_DEPLOYMENT.md
│       └── HTTPS_SETUP.md
```

---

## What to Push and Where

### High Priority ⭐

**1. Guardian Setup Script**
- **File**: `guardian-setup.sh`
- **Push to**: New `orbs-tee-deployment` repo (preferred) OR `orbs-tee-host` repo
- **Why**: Guardians need this to deploy

**2. Systemd Services**
- **Files**: `orbs-tee-enclave.service`, `orbs-tee-host.service`
- **Push to**: Same repo as setup script
- **Why**: Required for auto-start/restart

**3. Main Documentation**
- **File**: `GUARDIAN_DEPLOYMENT.md`
- **Push to**: Same repo as setup script
- **Why**: Complete deployment guide for guardians

**4. Configuration Examples**
- **File**: Sample `config.json` with comments
- **Push to**: Same repo as setup script
- **Why**: Guardians need reference configuration

### Medium Priority

**5. Technical Documentation**
- **Files**: `SETUP_SUMMARY.md`, `INTEGRATION_TESTING.md`, `WHY_PORT_8443.md`
- **Push to**: Deployment repo or component repos
- **Why**: Helpful for troubleshooting and understanding

**6. Host Code Changes**
- **Files**: `src/api/routes/attest.ts` (modified)
- **Push to**: `orbs-tee-host` repo
- **Why**: Keep code in sync

### Low Priority

**7. Development Notes**
- **Files**: Session notes, troubleshooting guides
- **Push to**: Optional, `docs/dev-notes/` folder
- **Why**: Useful for reference but not essential

---

## How to Push

### Create New Deployment Repository

```bash
# Create new repo on GitHub: orbs-network/orbs-tee-deployment

# On the server
cd /home/ubuntu
mkdir orbs-tee-deployment
cd orbs-tee-deployment

# Initialize git
git init
git branch -M main

# Create structure
mkdir -p systemd docs examples scripts

# Copy files
cp /home/ubuntu/guardian-setup.sh .
cp /home/ubuntu/orbs-tee-enclave.service systemd/
cp /home/ubuntu/orbs-tee-host.service systemd/
cp /home/ubuntu/GUARDIAN_DEPLOYMENT.md docs/
cp /home/ubuntu/SETUP_SUMMARY.md docs/
cp /home/ubuntu/WHY_PORT_8443.md docs/
cp /home/ubuntu/HTTPS_SETUP_COMPLETE.md docs/HTTPS_SETUP.md
cp /home/ubuntu/orbs-tee-host/config.json examples/config.example.json

# Create README
cat > README.md <<'EOF'
# ORBS TEE Guardian Deployment

One-command deployment for ORBS TEE guardians.

## Quick Start

```bash
# Download and run setup
curl -O https://raw.githubusercontent.com/orbs-network/orbs-tee-deployment/main/guardian-setup.sh
chmod +x guardian-setup.sh
sudo ./guardian-setup.sh
```

## Documentation

- [Guardian Deployment Guide](docs/GUARDIAN_DEPLOYMENT.md)
- [Setup Summary](docs/SETUP_SUMMARY.md)
- [Why Port 8443?](docs/WHY_PORT_8443.md)

## Requirements

- Ubuntu 24.04 LTS
- 4GB+ RAM
- Sudo access

## What Gets Installed

- Rust 1.91+
- Node.js 20+
- ORBS TEE Enclave
- ORBS TEE Host
- Systemd services (auto-start on boot)

## Support

See [docs/GUARDIAN_DEPLOYMENT.md](docs/GUARDIAN_DEPLOYMENT.md) for complete guide.
EOF

# Commit
git add .
git commit -m "Initial deployment infrastructure

- Guardian one-command setup script
- Systemd service templates
- Complete documentation
- Example configurations

🤖 Generated with Claude Code
"

# Add remote and push
git remote add origin https://github.com/orbs-network/orbs-tee-deployment.git
git push -u origin main
```

### Update Existing Repositories

**For orbs-tee-host**:

```bash
cd /home/ubuntu/orbs-tee-host

# Create deployment directory
mkdir -p deployment/systemd deployment/docs

# Copy files
cp /home/ubuntu/orbs-tee-host.service deployment/systemd/
cp /home/ubuntu/GUARDIAN_DEPLOYMENT.md deployment/docs/
cp /home/ubuntu/guardian-setup.sh deployment/

# Review changes
git status
git diff src/api/routes/attest.ts

# Commit
git add .
git commit -m "Add guardian deployment infrastructure

- Guardian setup script
- Systemd service template
- Deployment documentation

🤖 Generated with Claude Code
"

git push
```

---

## Testing After Push

Once pushed, test the deployment on a **fresh VM**:

```bash
# On new Ubuntu 24.04 VM
curl -O https://raw.githubusercontent.com/orbs-network/orbs-tee-deployment/main/guardian-setup.sh
chmod +x guardian-setup.sh
sudo ./guardian-setup.sh

# Should complete in ~5 minutes
# Then test:
curl -k https://localhost:8443/api/v1/health
```

---

## What Guardians Will Do

After you push, guardians can deploy with:

```bash
# One command to download and run
curl -sSL https://raw.githubusercontent.com/orbs-network/orbs-tee-deployment/main/guardian-setup.sh | sudo bash

# Or download first
curl -O https://raw.githubusercontent.com/orbs-network/orbs-tee-deployment/main/guardian-setup.sh
chmod +x guardian-setup.sh
sudo ./guardian-setup.sh
```

---

## Files NOT to Push

**Do not push these** (local/temporary files):

```
/home/ubuntu/
├── *.pem                          # SSL certificates (private keys!)
├── *.sock                         # Unix sockets
├── installation-info.json         # Local installation data
└── node_modules/                  # Dependencies
```

**Add to .gitignore**:
```gitignore
*.pem
*.sock
*.log
installation-info.json
node_modules/
dist/
target/
```

---

## Summary

### Must Push ⭐

1. **guardian-setup.sh** - Deployment script
2. **systemd/*.service** - Service templates
3. **GUARDIAN_DEPLOYMENT.md** - Main guide
4. **Example config.json** - Configuration template

### Should Push

5. Technical documentation (SETUP_SUMMARY, WHY_PORT_8443)
6. Host code changes (attest.ts)

### Optional

7. Development notes and session logs

### Recommended Approach

Create **new repo**: `orbs-tee-deployment` with:
- Setup script
- Systemd templates
- Documentation
- Examples

This gives guardians everything in one place! 🚀

---

## Next Steps

1. **Create** `orbs-tee-deployment` repository on GitHub
2. **Organize** files as shown above
3. **Push** to repository
4. **Test** on fresh VM
5. **Share** deployment URL with guardians

---

*Everything guardians need to deploy in minutes!*
