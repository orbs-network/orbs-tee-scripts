# Automatic Documentation System

Automated tools to track and document all setup/installation sessions.

---

## 📚 Available Scripts

### 1. `auto-document-setup.sh` - Instant Documentation

Generates comprehensive documentation snapshot of current system state.

**Usage:**
```bash
# Document current state
./auto-document-setup.sh "setup-name"

# Examples
./auto-document-setup.sh "nitro-attestation"
./auto-document-setup.sh "initial-setup"
./auto-document-setup.sh "guardian-deployment"
```

**What it captures:**
- ✅ System information (OS, kernel, memory)
- ✅ Installed software versions
- ✅ Running services
- ✅ Network configuration
- ✅ Recent file changes
- ✅ Enclave status (if running)
- ✅ Memory/hugepage configuration
- ✅ Quick command reference

**Output:**
- Creates: `/home/ubuntu/<name>-<timestamp>.md`
- Symlink: `/home/ubuntu/<name>-latest.md`

---

### 2. `session-tracker.sh` - Live Session Logging

Tracks commands and changes during an active session.

**Usage:**
```bash
# Start tracking
source session-tracker.sh

# Log a command
log_command "nitro-cli build-enclave" "Building enclave" "success"

# Log a file change
log_file_change "/home/ubuntu/config.json" "created"

# Finish and generate summary
finalize_session
```

**Output:**
- Creates: `/home/ubuntu/.sessions/session-<timestamp>.md`
- Symlink: `/home/ubuntu/.sessions/latest.md`

---

## 🚀 Quick Examples

### After Installation
```bash
# Document what was just installed
./auto-document-setup.sh "nitro-cli-install"
```

### Before/After Comparison
```bash
# Before changes
./auto-document-setup.sh "before-upgrade"

# Make changes...

# After changes
./auto-document-setup.sh "after-upgrade"

# Compare
diff before-upgrade-latest.md after-upgrade-latest.md
```

### Track a Complex Setup
```bash
# Start session
source session-tracker.sh

# Do your setup commands...
sudo apt install something
log_command "sudo apt install something" "Install dependencies" "success"

./build-script.sh
log_command "./build-script.sh" "Build project" "success"

# Create config
echo "config" > config.json
log_file_change "config.json" "created"

# Finish
finalize_session

# View log
cat ~/.sessions/latest.md
```

---

## 📊 What We Did Today

### Nitro Enclave Setup (Automated)

```bash
# This was automatically generated!
cat /home/ubuntu/nitro-attestation-latest.md
```

Contains:
- Current enclave status
- PCR measurements
- Installed tools (nitro-cli, docker, cargo)
- Network configuration
- Recent file changes
- Memory/hugepage allocation
- Complete system snapshot

---

## 🔄 Integration with CI/CD

### Add to Build Scripts

```bash
#!/bin/bash
# build.sh

# Start documentation
source /home/ubuntu/session-tracker.sh

# Your build steps
cargo build --release
log_command "cargo build --release" "Build release binary" "$?"

docker build -t myapp .
log_command "docker build -t myapp ." "Build Docker image" "$?"

# Auto-document result
/home/ubuntu/auto-document-setup.sh "build-$(date +%Y%m%d)"

# Finalize session
finalize_session
```

### Add to Deployment Scripts

```bash
#!/bin/bash
# deploy.sh

# Document before
/home/ubuntu/auto-document-setup.sh "before-deploy"

# Deploy...
nitro-cli run-enclave ...

# Document after
/home/ubuntu/auto-document-setup.sh "after-deploy"

echo "Deployment documented:"
ls -la *deploy*.md
```

---

## 📁 File Organization

```
/home/ubuntu/
├── auto-document-setup.sh          # Main documentation script
├── session-tracker.sh               # Session logging script
├── <setup-name>-<timestamp>.md     # Generated docs (timestamped)
├── <setup-name>-latest.md          # Symlink to latest
└── .sessions/
    ├── session-<timestamp>.md      # Session logs
    └── latest.md                   # Latest session
```

---

## 💡 Best Practices

### 1. Document Before Major Changes
```bash
./auto-document-setup.sh "before-major-change"
# Make changes...
./auto-document-setup.sh "after-major-change"
```

### 2. Tag Important Milestones
```bash
./auto-document-setup.sh "milestone-attestation-working"
./auto-document-setup.sh "milestone-production-ready"
```

### 3. Daily Snapshots
```bash
# Add to cron
0 9 * * * /home/ubuntu/auto-document-setup.sh "daily-snapshot"
```

### 4. Pre/Post Scripts
```bash
# In any setup script, add at the end:
/home/ubuntu/auto-document-setup.sh "$(basename $0 .sh)"
```

---

## 🔍 Viewing Documentation

### Latest State
```bash
cat nitro-attestation-latest.md
```

### All Documentation
```bash
ls -lt *.md | head -20
```

### Search Documentation
```bash
grep -r "nitro-cli" *.md
grep -r "ERROR" *.md
grep -r "PCR" *.md
```

### Compare States
```bash
diff setup-latest.md attestation-latest.md
```

---

## 🎯 Current Session Summary

**What was documented automatically:**

1. ✅ Nitro CLI installation (v1.4.3)
2. ✅ Enclave build and deployment
3. ✅ Attestation endpoint addition
4. ✅ Current enclave status
5. ✅ All configuration files
6. ✅ Network setup
7. ✅ Memory allocation
8. ✅ Service status

**Generated files:**
- `nitro-attestation-20251103-192202.md` - Full system snapshot
- `ATTESTATION_SUCCESS.md` - Manual documentation
- `test-enclave-full.py` - Test suite

---

## 📝 Notes

- All scripts are idempotent (safe to run multiple times)
- Documentation files are plain markdown (human-readable)
- Symlinks always point to latest version
- Session logs preserved in `.sessions/` directory
- Can be committed to git for version control
- No sensitive information captured (filtered)

---

**Next time you install something, just run:**
```bash
./auto-document-setup.sh "what-i-just-did"
```

**And you'll have complete documentation automatically!**
