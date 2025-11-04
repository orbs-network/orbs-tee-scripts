#!/bin/bash
# Script to commit and push all changes to GitHub

set -e

echo "════════════════════════════════════════════════════════"
echo "  Pushing ORBS TEE Changes to GitHub"
echo "════════════════════════════════════════════════════════"
echo ""

# 1. Push orbs-tee-enclave-nitro
echo "📦 1/3: orbs-tee-enclave-nitro"
echo "────────────────────────────────────────────────────────"
cd /home/ubuntu/orbs-tee-enclave-nitro

echo "Changes to commit:"
git status --short

echo ""
echo "Adding changes..."
git add CLAUDE.md
git add examples/price-oracle-unix/

echo "Committing..."
git commit -m "Add Unix socket price oracle example and integration testing docs

- Add price-oracle-unix example for testing without Nitro
- Supports Unix socket communication for Mac/Linux testing
- Real Binance API integration with ECDSA signing
- Update CLAUDE.md with integration testing reference

This allows testing the full system without AWS Nitro hardware.
"

echo "Pushing to GitHub..."
git push

echo "✅ orbs-tee-enclave-nitro pushed!"
echo ""

# 2. Push orbs-tee-host
echo "📦 2/3: orbs-tee-host"
echo "────────────────────────────────────────────────────────"
cd /home/ubuntu/orbs-tee-host

echo "Changes to commit:"
git status --short

echo ""
echo "Adding changes..."
git add src/config/index.ts
git add examples/mock-enclave.ts
git add CLAUDE.md

echo "Committing..."
git commit -m "Add Unix socket support and improve mock enclave

- Add socketPath option to vsock config schema
- Update mock enclave with better logging and structure
- Update CLAUDE.md with integration testing reference

Fixes config validation error when using Unix sockets for testing.
"

echo "Pushing to GitHub..."
git push

echo "✅ orbs-tee-host pushed!"
echo ""

# 3. Push orbs-tee-scripts (NEW REPO)
echo "📦 3/3: orbs-tee-scripts (NEW REPO)"
echo "────────────────────────────────────────────────────────"
cd /home/ubuntu/orbs-tee-scripts

echo ""
echo "⚠️  IMPORTANT: You need to create this repo on GitHub first!"
echo ""
echo "Go to: https://github.com/new"
echo "- Name: orbs-tee-scripts"
echo "- Description: Development scripts and documentation for ORBS TEE"
echo "- Don't initialize with README"
echo ""
read -p "Have you created the GitHub repo? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Setting up remote..."

    # Check if remote already exists
    if git remote get-url origin 2>/dev/null; then
        echo "Remote 'origin' already exists"
    else
        read -p "Enter GitHub URL (e.g., git@github.com:orbs-network/orbs-tee-scripts.git): " GITHUB_URL
        git remote add origin "$GITHUB_URL"
    fi

    echo "Pushing to GitHub..."
    git branch -M main
    git push -u origin main

    echo "✅ orbs-tee-scripts pushed!"
else
    echo "⏸️  Skipping orbs-tee-scripts push"
    echo "   Run this script again after creating the GitHub repo"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo "  ✅ All Done!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Summary:"
echo "  ✅ orbs-tee-enclave-nitro - Pushed"
echo "  ✅ orbs-tee-host - Pushed"
echo "  📝 orbs-tee-scripts - Check if pushed above"
echo ""
