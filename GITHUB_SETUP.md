# How to Push to GitHub

## Step 1: Create GitHub Repository

Go to GitHub and create a new repository:
- Repository name: `orbs-tee-scripts`
- Description: "Development scripts and documentation for ORBS TEE system"
- Visibility: Public (or Private if you prefer)
- **Do NOT initialize with README, .gitignore, or license** (we already have these)

## Step 2: Add Remote and Push

Once the repository is created on GitHub, run:

```bash
cd /home/ubuntu/orbs-tee-scripts

# Add your GitHub remote (replace with your username/org)
git remote add origin https://github.com/orbs-network/orbs-tee-scripts.git

# OR use SSH (recommended)
git remote add origin git@github.com:orbs-network/orbs-tee-scripts.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Verify

Go to:
```
https://github.com/orbs-network/orbs-tee-scripts
```

You should see all files committed!

## What's in the Repo

```
orbs-tee-scripts/
├── README.md                      # Main documentation
├── .gitignore                     # Git ignore rules
├── .claude-permissions.json       # Permission tracking
├── GITHUB_SETUP.md                # This file
├── scripts/                       # 8 helper scripts
│   ├── dev-session.sh
│   ├── session-status.sh
│   ├── save-state.sh
│   ├── restore-state.sh
│   ├── ssh-server-keepalive.sh
│   ├── update-summary.sh
│   ├── setup-testing.sh
│   └── guardian-install.sh
└── docs/                          # 8 documentation files
    ├── CLAUDE.md
    ├── INTEGRATION_TESTING.md
    ├── SETUP_SUMMARY.md
    ├── TEST_RESULTS.md
    ├── REMOTE_TESTING.md
    ├── FINAL_STATUS.md
    ├── WHERE_WE_LEFT_OFF.md
    ├── RECONNECTION_GUIDE.md
    └── PERMISSIONS.md
```

## Ongoing Development

### Make Changes

```bash
cd /home/ubuntu/orbs-tee-scripts

# Edit files
nano scripts/new-script.sh

# Add and commit
git add .
git commit -m "Add new feature"
git push
```

### Update Documentation

```bash
# Edit docs
nano docs/NEW_GUIDE.md

# Commit
git add docs/NEW_GUIDE.md
git commit -m "Add new guide"
git push
```

### Pull Changes

```bash
git pull origin main
```

## Integration with Main Projects

Add as submodule to main repos:

```bash
# In orbs-tee-enclave-nitro
cd /path/to/orbs-tee-enclave-nitro
git submodule add https://github.com/orbs-network/orbs-tee-scripts.git scripts

# In orbs-tee-host
cd /path/to/orbs-tee-host
git submodule add https://github.com/orbs-network/orbs-tee-scripts.git scripts
```

## Sharing with Team

Once pushed to GitHub, anyone can clone:

```bash
git clone https://github.com/orbs-network/orbs-tee-scripts.git
cd orbs-tee-scripts
chmod +x scripts/*.sh
./scripts/dev-session.sh
```

## Benefits

✅ Version controlled scripts
✅ Shared across team
✅ Easy deployment to new servers
✅ Documented workflows
✅ Reproducible setups
✅ CI/CD integration ready

---

**Ready to push!** Just create the GitHub repo and run the commands above.
