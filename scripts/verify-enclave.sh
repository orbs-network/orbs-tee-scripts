#!/bin/bash
echo "═══════════════════════════════════════════"
echo "  AWS Nitro Enclave Verification"
echo "═══════════════════════════════════════════"
echo ""

# Source environment
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh 2>/dev/null

echo "📋 Nitro CLI Version:"
nitro-cli --version
echo ""

echo "📊 Enclave Status:"
nitro-cli describe-enclaves | jq -r '.[0] | "  Name: \(.EnclaveName)\n  ID: \(.EnclaveID)\n  State: \(.State)\n  CID: \(.EnclaveCID)\n  Memory: \(.MemoryMiB) MiB\n  CPUs: \(.CPUIDs | join(", "))"'
echo ""

echo "🔐 PCR Measurements:"
nitro-cli describe-enclaves | jq -r '.[0].Measurements | "  PCR0: \(.PCR0)\n  PCR1: \(.PCR1)\n  PCR2: \(.PCR2)"'
echo ""

echo "💾 EIF File:"
ls -lh /home/ubuntu/price-oracle.eif 2>/dev/null && echo "" || echo "  Not found"

echo "🔧 Hugepages:"
grep HugePages /proc/meminfo | grep -v "AnonHugePages\|ShmemHugePages\|FileHugePages"
echo ""

echo "✅ Setup Complete!"
echo "═══════════════════════════════════════════"
