# SSH Reconnection & Session Persistence Guide

## 🎯 Problem Solved

This guide helps you continue work seamlessly after SSH disconnections with:

1. **SSH Keepalive** - Prevents disconnections
2. **Persistent Sessions** - tmux sessions survive disconnections
3. **State Tracking** - Resume work exactly where you left off

## 🚀 Quick Start

### First Time Setup

```bash
# 1. Configure SSH server to stay alive (run once)
sudo ./ssh-server-keepalive.sh

# 2. Start a persistent development session
./dev-session.sh
```

That's it! Your work is now protected against SSH disconnections.

## 📋 Daily Workflow

### Starting Work

```bash
# Connect via SSH
ssh user@your-server

# Start or attach to tmux session
./dev-session.sh
```

This creates 4 tmux windows:
- **main** - General commands
- **enclave** - Enclave development/testing
- **host** - Host development/testing
- **test** - API testing with curl

### During Work

```bash
# Save state before risky operations
./save-state.sh

# Check what's running
./session-status.sh
```

### After Disconnection

```bash
# Reconnect via SSH
ssh user@your-server

# Check what survived
./session-status.sh

# Restore your tmux session (if it's still running)
./dev-session.sh

# Or restore previous state
./restore-state.sh
```

## 🛠️ How It Works

### 1. SSH Keepalive (Prevents Disconnections)

**Client side** (`~/.ssh/config`):
```
ServerAliveInterval 60      # Send keepalive every 60s
ServerAliveCountMax 120     # Allow 2 hours of no response
```

**Server side** (`/etc/ssh/sshd_config`):
```
ClientAliveInterval 60      # Send keepalive every 60s
ClientAliveCountMax 120     # Allow 2 hours of no response
```

This keeps your SSH connection alive **indefinitely** as long as network is up.

### 2. tmux (Persistent Sessions)

tmux creates persistent terminal sessions that:
- ✅ Survive SSH disconnections
- ✅ Can be reattached from new SSH session
- ✅ Keep all running processes alive
- ✅ Support multiple windows/panes

**Key tmux commands:**
```bash
# List sessions
tmux ls

# Attach to session
tmux attach -t orbs-tee-dev

# Detach (but keep running)
Ctrl-b d

# Switch windows
Ctrl-b 0    # Window 0 (main)
Ctrl-b 1    # Window 1 (enclave)
Ctrl-b 2    # Window 2 (host)
Ctrl-b 3    # Window 3 (test)
Ctrl-b n    # Next window
Ctrl-b p    # Previous window
```

### 3. State Tracking (Resume Work)

Saves and restores:
- Running processes (enclave, host, mock)
- Socket status
- Port usage
- Working directory
- Test status

## 📖 Detailed Commands

### Session Management

```bash
# Start new session or attach to existing
./dev-session.sh [session-name]

# Check all active sessions
tmux ls

# Attach to specific session
tmux attach -t orbs-tee-dev

# Kill a session (when done)
tmux kill-session -t orbs-tee-dev

# Check status of everything
./session-status.sh
```

### State Management

```bash
# Save current state
./save-state.sh

# Restore after reconnection
./restore-state.sh

# View saved state
cat ~/.orbs-tee-state.json
```

### SSH Configuration

```bash
# Configure server keepalive (run once as root)
sudo ./ssh-server-keepalive.sh

# Client config is already in ~/.ssh/config
cat ~/.ssh/config
```

## 🔍 Troubleshooting

### "Cannot attach to session"

```bash
# List all sessions
tmux ls

# If no sessions exist, start a new one
./dev-session.sh

# If session exists but won't attach
tmux kill-server
./dev-session.sh
```

### "SSH still disconnecting"

```bash
# Verify server config
cat /etc/ssh/sshd_config | grep ClientAlive

# Should show:
# ClientAliveInterval 60
# ClientAliveCountMax 120

# If not, run:
sudo ./ssh-server-keepalive.sh
```

### "Processes not running after reconnection"

```bash
# Check what's running
./session-status.sh

# Manually restart services
# In tmux window "enclave":
cd /home/ubuntu/orbs-tee-host
npx ts-node examples/mock-enclave.ts

# In tmux window "host":
cd /home/ubuntu/orbs-tee-host
npm run dev
```

### "Lost my place in work"

```bash
# Check saved state
cat ~/.orbs-tee-state.json

# Get restoration hints
./restore-state.sh

# View recent bash history
history | tail -50
```

## 🎓 Example Workflows

### Workflow 1: Testing Integration

```bash
# Terminal 1
ssh user@server
./dev-session.sh

# Inside tmux, switch to "enclave" window (Ctrl-b 1)
cd /home/ubuntu/orbs-tee-host
npx ts-node examples/mock-enclave.ts
# Ctrl-b d to detach (keeps running)

# Terminal 2
ssh user@server
tmux attach -t orbs-tee-dev
# Switch to "host" window (Ctrl-b 2)
npm run dev
# Ctrl-b d to detach

# Terminal 3
ssh user@server
tmux attach -t orbs-tee-dev
# Switch to "test" window (Ctrl-b 3)
curl http://localhost:8080/api/v1/health

# If disconnected, just reconnect and:
./dev-session.sh    # Everything still running!
```

### Workflow 2: Long-Running Tests

```bash
# Start tmux session
./dev-session.sh

# Save state before starting
./save-state.sh

# Run long tests in tmux window
cd /home/ubuntu/orbs-tee-enclave-nitro
cargo test --no-default-features

# Detach safely (Ctrl-b d)
# Tests keep running even if SSH dies

# Reconnect later
./dev-session.sh
# Tests still running!
```

### Workflow 3: Development with Frequent Saves

```bash
# Start session
./dev-session.sh

# Periodically save state (every 30 min or before risky ops)
./save-state.sh

# If something breaks or SSH dies
./session-status.sh    # What's still alive?
./restore-state.sh     # What was I doing?
```

## 📊 State File Format

The state file (`~/.orbs-tee-state.json`) contains:

```json
{
  "timestamp": "2024-11-03T14:00:00Z",
  "platform": "Linux ...",
  "workingDirectory": "/home/ubuntu",
  "processes": {
    "enclave": false,
    "host": true,
    "mockEnclave": true
  },
  "resources": {
    "enclaveSocket": true,
    "port8080": true
  },
  "lastTestStatus": {
    "enclave": "test result: ok..."
  },
  "notes": "..."
}
```

## 🔐 Security Notes

- SSH keepalive settings are safe for development
- For production, consider shorter timeouts
- tmux sessions persist until server reboot
- State files contain no secrets, just process status

## 📚 Additional Resources

- tmux cheat sheet: https://tmuxcheatsheet.com/
- SSH config guide: https://www.ssh.com/academy/ssh/config
- ORBS TEE docs: `/home/ubuntu/INTEGRATION_TESTING.md`

## ✅ Success Checklist

After setup, verify:

- [ ] SSH doesn't disconnect for at least 2 hours of idle time
- [ ] `./dev-session.sh` creates/attaches to tmux session
- [ ] Processes survive SSH disconnection
- [ ] Can switch between tmux windows
- [ ] `./save-state.sh` creates state file
- [ ] `./session-status.sh` shows accurate status
- [ ] Can reconnect and resume work seamlessly

---

**Now your development workflow is bulletproof! 🛡️**
