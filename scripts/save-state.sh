#!/bin/bash
# Save current development state
# This captures what you're working on so you can restore after reconnection

STATE_FILE="/home/ubuntu/.orbs-tee-state.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "💾 Saving current development state..."

# Gather state information
ENCLAVE_RUNNING=$(pgrep -f "price-oracle" > /dev/null && echo "true" || echo "false")
HOST_RUNNING=$(pgrep -f "orbs-tee-host" > /dev/null && echo "true" || echo "false")
MOCK_RUNNING=$(pgrep -f "mock-enclave" > /dev/null && echo "true" || echo "false")
SOCKET_EXISTS=$([ -e /tmp/enclave.sock ] && echo "true" || echo "false")
PORT_8080=$(lsof -i :8080 > /dev/null 2>&1 && echo "true" || echo "false")

# Get working directories
PWD_MAIN=$(pwd)

# Get recent test status
cd /home/ubuntu/orbs-tee-enclave-nitro 2>/dev/null
ENCLAVE_TEST_STATUS=$(/home/ubuntu/.cargo/bin/cargo test --no-default-features 2>&1 | tail -5 | head -1)
cd - > /dev/null

# Create state JSON
cat > "$STATE_FILE" << EOF
{
  "timestamp": "$TIMESTAMP",
  "platform": "$(uname -a)",
  "workingDirectory": "$PWD_MAIN",
  "processes": {
    "enclave": $ENCLAVE_RUNNING,
    "host": $HOST_RUNNING,
    "mockEnclave": $MOCK_RUNNING
  },
  "resources": {
    "enclaveSocket": $SOCKET_EXISTS,
    "port8080": $PORT_8080
  },
  "lastTestStatus": {
    "enclave": "$ENCLAVE_TEST_STATUS"
  },
  "notes": "State saved before potential SSH disconnection"
}
EOF

echo "✅ State saved to: $STATE_FILE"
echo ""
cat "$STATE_FILE"
echo ""
echo "To restore: ./restore-state.sh"
