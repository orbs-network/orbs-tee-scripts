#!/bin/bash
# Auto-update the session summary
# Run this manually or via cron to keep track of progress

SUMMARY_FILE="/home/ubuntu/WHERE_WE_LEFT_OFF.md"
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

# Get current status
ENCLAVE_RUNNING=$(pgrep -f "price-oracle" > /dev/null && echo "✅ Running" || echo "❌ Not running")
HOST_RUNNING=$(pgrep -f "orbs-tee-host.*dev" > /dev/null && echo "✅ Running" || echo "❌ Not running")
MOCK_RUNNING=$(pgrep -f "mock-enclave" > /dev/null && echo "✅ Running" || echo "❌ Not running")
TESTS_RUNNING=$(pgrep -f "jest" > /dev/null && echo "⏳ In progress" || echo "✅ Complete")

# Get test results if available
cd /home/ubuntu/orbs-tee-enclave-nitro 2>/dev/null
ENCLAVE_TESTS=$(/home/ubuntu/.cargo/bin/cargo test --no-default-features 2>&1 | grep "test result" | tail -1)
cd /home/ubuntu 2>/dev/null

# Update the timestamp section in the summary
sed -i "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $TIMESTAMP/" "$SUMMARY_FILE"

# Add current runtime status section if it doesn't exist
if ! grep -q "## 🔄 Current Runtime Status" "$SUMMARY_FILE"; then
    cat >> "$SUMMARY_FILE" << EOF

---

## 🔄 Current Runtime Status

**Auto-updated**: $TIMESTAMP

| Component | Status | Notes |
|-----------|--------|-------|
| Enclave Tests | $ENCLAVE_TESTS | - |
| Host Tests | $TESTS_RUNNING | Check: \`./session-status.sh\` |
| Mock Enclave | $MOCK_RUNNING | Port: Unix socket |
| Host API | $HOST_RUNNING | Port: 8080 |
| Real Enclave | $ENCLAVE_RUNNING | Price Oracle |

**Quick Actions**:
- Check status: \`./session-status.sh\`
- Start session: \`./dev-session.sh\`
- Save work: \`./save-state.sh\`

EOF
fi

echo "✅ Summary updated: $SUMMARY_FILE"
