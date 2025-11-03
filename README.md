# ORBS TEE Development Scripts & Documentation

Helper scripts and documentation for ORBS TEE system development, testing, and deployment.

## 📦 What's Included

### Scripts (`scripts/`)
- `dev-session.sh` - Start/attach to persistent tmux development session
- `session-status.sh` - Check status of all running services
- `save-state.sh` - Save current development state
- `restore-state.sh` - Restore state after reconnection
- `ssh-server-keepalive.sh` - Configure SSH server for long sessions
- `update-summary.sh` - Update session progress summary

### Documentation (`docs/`)
- `CLAUDE.md` - Main workspace guide
- `INTEGRATION_TESTING.md` - Complete integration testing guide
- `SETUP_SUMMARY.md` - Initial setup summary
- `TEST_RESULTS.md` - Test results and reports
- `REMOTE_TESTING.md` - Remote API testing guide
- `FINAL_STATUS.md` - Current system status
- `WHERE_WE_LEFT_OFF.md` - Session progress tracker
- `RECONNECTION_GUIDE.md` - SSH persistence guide
- `PERMISSIONS.md` - Approved commands reference

## 🚀 Quick Start

```bash
# Clone this repo
git clone https://github.com/orbs-network/orbs-tee-scripts.git
cd orbs-tee-scripts

# Make scripts executable
chmod +x scripts/*.sh

# Configure SSH for persistence
sudo ./scripts/ssh-server-keepalive.sh

# Start development session
./scripts/dev-session.sh
```

## 📖 Key Features

### 1. Session Persistence
Never lose work due to SSH disconnections:
- Automatic reconnection with SSH keepalive
- tmux sessions that survive disconnects
- State tracking and restoration

### 2. Development Workflow
Streamlined development with:
- Multi-window tmux setup (enclave, host, test)
- Quick status checks
- Automated state saving

### 3. Comprehensive Documentation
Everything you need to know:
- Setup guides
- Testing procedures
- API references
- Troubleshooting

## 🎯 Use Cases

### For Developers
- Quick environment setup
- Persistent development sessions
- Easy testing and debugging

### For Guardians
- Production deployment scripts
- System monitoring
- State management

### For CI/CD
- Automated testing
- Status reporting
- State verification

## 📋 Requirements

- Linux (Ubuntu 20.04+ recommended)
- tmux (for persistent sessions)
- Git (for version control)
- Bash 4.0+

## 🔧 Configuration

### SSH Keepalive

Run once to configure SSH server:
```bash
sudo ./scripts/ssh-server-keepalive.sh
```

This configures:
- 60-second keepalive interval
- 2-hour timeout (120 missed keepalives)
- Automatic reconnection

### Custom Configuration

Edit `.claude-permissions.json` to customize:
- Approved bash commands
- Read/write paths
- Tool permissions

## 📚 Documentation

### For First-Time Setup
1. Read `docs/CLAUDE.md` - Workspace overview
2. Read `docs/SETUP_SUMMARY.md` - What was installed
3. Follow `docs/INTEGRATION_TESTING.md` - Testing guide

### For Daily Development
1. Run `./scripts/dev-session.sh` - Start working
2. Check `./scripts/session-status.sh` - View status
3. Save `./scripts/save-state.sh` - Before leaving

### For Deployment
1. Review `docs/FINAL_STATUS.md` - Current state
2. Follow `docs/REMOTE_TESTING.md` - API testing
3. Check `docs/PERMISSIONS.md` - Security reference

## 🛠️ Script Reference

### `dev-session.sh`
Start or attach to tmux development session with 4 windows:
- **main**: General commands
- **enclave**: Rust development
- **host**: TypeScript development
- **test**: API testing

```bash
./scripts/dev-session.sh [session-name]
```

### `session-status.sh`
Check status of:
- Tmux/screen sessions
- Running processes (enclave, host, mock)
- Unix sockets
- Network ports
- Last saved state

```bash
./scripts/session-status.sh
```

### `save-state.sh`
Save current state to JSON:
- Running processes
- Socket status
- Port usage
- Working directory
- Test results

```bash
./scripts/save-state.sh
```

### `restore-state.sh`
Display restoration hints after reconnection:
- What was running
- How to restart services
- Where you left off

```bash
./scripts/restore-state.sh
```

### `ssh-server-keepalive.sh`
Configure SSH server for persistent connections:
- Enables TCP keepalive
- Sets client alive interval
- Configures timeout

```bash
sudo ./scripts/ssh-server-keepalive.sh
```

### `update-summary.sh`
Update progress summary with current status:
- Process status
- Test results
- Runtime information

```bash
./scripts/update-summary.sh
```

## 🔒 Security

### Permissions
All scripts follow least-privilege principle:
- Read-only where possible
- Explicit write permissions
- No destructive operations without confirmation

### SSH Security
Keepalive configuration:
- Safe for development
- Consider shorter timeouts for production
- Compatible with AWS Security Groups

## 🐛 Troubleshooting

### tmux Not Found
```bash
sudo apt-get update && sudo apt-get install tmux
```

### Script Not Executable
```bash
chmod +x scripts/*.sh
```

### Permission Denied
```bash
# For SSH server config:
sudo ./scripts/ssh-server-keepalive.sh

# For other scripts:
chmod +x scripts/*.sh
```

### Session Won't Attach
```bash
# Kill hung sessions
tmux kill-server

# Start fresh
./scripts/dev-session.sh
```

## 📊 File Structure

```
orbs-tee-scripts/
├── README.md                      # This file
├── .gitignore                     # Git ignore rules
├── .claude-permissions.json       # Permissions config
├── scripts/
│   ├── dev-session.sh             # Tmux session manager
│   ├── session-status.sh          # Status checker
│   ├── save-state.sh              # State saver
│   ├── restore-state.sh           # State restorer
│   ├── ssh-server-keepalive.sh    # SSH config
│   └── update-summary.sh          # Summary updater
└── docs/
    ├── CLAUDE.md                  # Workspace guide
    ├── INTEGRATION_TESTING.md     # Testing guide
    ├── SETUP_SUMMARY.md           # Setup summary
    ├── TEST_RESULTS.md            # Test results
    ├── REMOTE_TESTING.md          # Remote testing
    ├── FINAL_STATUS.md            # Current status
    ├── WHERE_WE_LEFT_OFF.md       # Progress tracker
    ├── RECONNECTION_GUIDE.md      # SSH guide
    └── PERMISSIONS.md             # Permissions reference
```

## 🤝 Contributing

This repo is part of the ORBS TEE project. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📜 License

Part of the ORBS Network - see main project for license details.

## 🔗 Related Repositories

- [orbs-tee-enclave-nitro](https://github.com/orbs-network/orbs-tee-enclave-nitro) - Rust enclave SDK
- [orbs-tee-host](https://github.com/orbs-network/orbs-tee-host) - TypeScript host
- [orbs-tee-protocol](https://github.com/orbs-network/orbs-tee-protocol) - Protocol definitions

## ✅ Testing

All scripts are tested on:
- Ubuntu 24.04 LTS
- AWS EC2 instances
- macOS (where applicable)

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Check documentation in `docs/`
- Review troubleshooting section above

---

**Made with ❤️ for ORBS TEE Development**

Last Updated: 2025-11-03
