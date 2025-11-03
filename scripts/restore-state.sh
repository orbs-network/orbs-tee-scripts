#!/bin/bash
# Restore development state after SSH reconnection

STATE_FILE="/home/ubuntu/.orbs-tee-state.json"

if [ ! -f "$STATE_FILE" ]; then
    echo "❌ No state file found at: $STATE_FILE"
    echo "Run ./save-state.sh first"
    exit 1
fi

echo "📂 Restoring development state..."
echo ""

# Display saved state
echo "Previous State:"
cat "$STATE_FILE"
echo ""

# Parse state (simple grep-based parsing for bash)
ENCLAVE_WAS_RUNNING=$(grep '"enclave"' "$STATE_FILE" | grep -o 'true\|false')
HOST_WAS_RUNNING=$(grep '"host"' "$STATE_FILE" | grep -o 'true\|false')
MOCK_WAS_RUNNING=$(grep '"mockEnclave"' "$STATE_FILE" | grep -o 'true\|false')

echo "════════════════════════════════════════════════════════"
echo "  Restoration Options"
echo "════════════════════════════════════════════════════════"
echo ""

if [ "$ENCLAVE_WAS_RUNNING" = "true" ]; then
    echo "🔧 Enclave was running"
    echo "   To restart:"
    echo "   cd /home/ubuntu/orbs-tee-enclave-nitro"
    echo "   ./examples/price-oracle/target/debug/price-oracle &"
    echo ""
fi

if [ "$HOST_WAS_RUNNING" = "true" ]; then
    echo "🔧 Host was running"
    echo "   To restart:"
    echo "   cd /home/ubuntu/orbs-tee-host"
    echo "   npm run dev &"
    echo ""
fi

if [ "$MOCK_WAS_RUNNING" = "true" ]; then
    echo "🔧 Mock Enclave was running"
    echo "   To restart:"
    echo "   cd /home/ubuntu/orbs-tee-host"
    echo "   npx ts-node examples/mock-enclave.ts &"
    echo ""
fi

echo "════════════════════════════════════════════════════════"
echo ""
echo "💡 Recommended:"
echo "   1. ./session-status.sh      - Check current status"
echo "   2. ./dev-session.sh         - Start tmux session"
echo "   3. Manually restart services as needed"
echo ""
