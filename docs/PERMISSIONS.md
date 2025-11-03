# Claude Code Permissions

This file tracks all commands and operations that Claude has permission to run without asking for approval in this workspace.

**Last Updated**: 2025-11-03 14:15 UTC

## Purpose

To enable efficient development without repeated permission prompts while maintaining safety.

## Approved Commands

### Build & Test Commands
```bash
# Rust/Cargo
cargo test:*
cargo build:*
cargo run:*
cargo clean
/home/ubuntu/.cargo/bin/cargo test --no-default-features
/home/ubuntu/.cargo/bin/cargo build --no-default-features --manifest-path examples/price-oracle/Cargo.toml

# Node.js/NPM
npm install
npm run build:*
npm run dev
npm run start
npm test:*
npx ts-node:*
```

### System Commands
```bash
# Package management
sudo apt-get update:*
sudo apt-get install:*
sudo apt-cache:*
sudo apt-get clean:*
sudo apt-get autoclean:*

# System info
lsmod:*
ec2-metadata:*
uname:*
ps aux:*
whoami
pwd

# File operations
cat:*
ls:*
grep:*
head:*
tail:*
wc:*
chmod:*
```

### Service Management
```bash
# Systemd
sudo systemctl:*
sudo systemctl start:*
sudo systemctl stop:*
sudo systemctl status:*
sudo journalctl:*

# Process management
pkill:*
```

### Custom Scripts
```bash
# Testing & setup
./setup-testing.sh:*
./session-status.sh:*
./save-state.sh
./restore-state.sh
./dev-session.sh:*
./update-summary.sh
./ssh-server-keepalive.sh  # with sudo

# Installation
sudo ./install.sh:*
make nitro-cli:*
```

### Development Tools
```bash
# Shell
sh:*
source $HOME/.cargo/env
sudo -E bash -

# Networking
curl:*

# Utilities
sleep:*
```

## File System Access

### Read Access
- `/tmp/**` - Temporary files
- `/etc/ssh/**` - SSH configuration
- `/home/ubuntu/**` - All workspace files
- `/home/ubuntu/orbs-tee-enclave-nitro/**` - Enclave code
- `/home/ubuntu/orbs-tee-host/**` - Host code

### Write Access
- `/home/ubuntu/**` - Workspace files (scripts, docs, code)
- `/home/ubuntu/orbs-tee-host/**` - Host source code
- `/tmp/**` - Temporary files

## Safety Rules

### Commands That Still Require Explicit Approval

Even with broad permissions, these operations require explicit confirmation:

❌ `rm -rf` - Recursive file deletion
❌ `git push --force` - Force push to git
❌ `git reset --hard` - Hard reset
❌ `mkfs` - Format file systems
❌ `dd` - Disk operations
❌ `chmod 777` on critical files
❌ Database drops or destructive SQL
❌ Network-wide changes
❌ Security-related modifications to production systems

### Rationale

These permissions enable:
1. ✅ Fast iteration on builds and tests
2. ✅ Quick debugging with system commands
3. ✅ Seamless script execution
4. ✅ Efficient development workflow
5. ✅ Service management and monitoring

While maintaining safety by:
1. 🛡️ No destructive file operations
2. 🛡️ No force operations on version control
3. 🛡️ No production system modifications
4. 🛡️ All changes are reversible
5. 🛡️ Code can be reviewed before execution

## Usage

### For Claude

Reference this file at the start of each session:
```bash
cat /home/ubuntu/.claude-permissions.json
```

### For Users

To add new permissions:
1. Edit `/home/ubuntu/.claude-permissions.json`
2. Update this documentation
3. Commit changes to preserve across sessions

To revoke permissions:
1. Remove from `.claude-permissions.json`
2. Update this documentation

## Permission Tracking

All permissions are tracked in:
- **Machine-readable**: `/home/ubuntu/.claude-permissions.json`
- **Human-readable**: `/home/ubuntu/PERMISSIONS.md` (this file)

## Session Continuity

To ensure permissions persist across sessions:

1. **Claude reads this file** at session start
2. **User can reference** this file to see current permissions
3. **Changes are preserved** in git/filesystem
4. **Permissions can be expanded** as needed

## Updates

When new permission is granted during a session:
1. Add to `.claude-permissions.json`
2. Update this PERMISSIONS.md
3. Run `./save-state.sh` to preserve

---

**Note**: These permissions are for development/testing on this specific AWS instance. Production deployments should use stricter controls.
