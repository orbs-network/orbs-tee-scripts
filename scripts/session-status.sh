#!/bin/bash
# Check status of all persistent sessions and running processes

echo "════════════════════════════════════════════════════════"
echo "  ORBS TEE Development Session Status"
echo "════════════════════════════════════════════════════════"
echo ""

# Check tmux sessions
echo "📦 Tmux Sessions:"
if command -v tmux &> /dev/null; then
    tmux list-sessions 2>/dev/null || echo "   No active sessions"
else
    echo "   tmux not installed"
fi
echo ""

# Check screen sessions
echo "📦 Screen Sessions:"
if command -v screen &> /dev/null; then
    screen -ls 2>&1 | grep -v "^No Sockets" || echo "   No active sessions"
else
    echo "   screen not installed"
fi
echo ""

# Check running processes
echo "🔄 Running Processes:"
echo ""

echo "   Enclave (price-oracle):"
if pgrep -f "price-oracle" > /dev/null; then
    ps aux | grep -E "price-oracle" | grep -v grep | awk '{print "   ✅ PID: "$2" | "$11" "$12" "$13}'
else
    echo "   ❌ Not running"
fi

echo ""
echo "   Host (npm/node):"
if pgrep -f "orbs-tee-host" > /dev/null; then
    ps aux | grep -E "orbs-tee-host" | grep -v grep | awk '{print "   ✅ PID: "$2" | "$11" "$12" "$13}'
else
    echo "   ❌ Not running"
fi

echo ""
echo "   Mock Enclave:"
if pgrep -f "mock-enclave" > /dev/null; then
    ps aux | grep -E "mock-enclave" | grep -v grep | awk '{print "   ✅ PID: "$2" | "$11" "$12" "$13}'
else
    echo "   ❌ Not running"
fi

echo ""

# Check sockets
echo "🔌 Unix Sockets:"
if [ -e /tmp/enclave.sock ]; then
    echo "   ✅ /tmp/enclave.sock exists"
    ls -lh /tmp/enclave.sock | awk '{print "      "$1" "$3" "$4" "$9}'
else
    echo "   ❌ /tmp/enclave.sock not found"
fi
echo ""

# Check ports
echo "🌐 Network Ports:"
if lsof -i :8080 > /dev/null 2>&1; then
    echo "   ✅ Port 8080 (Host API):"
    lsof -i :8080 | grep -v "COMMAND" | awk '{print "      PID "$2" | "$1" | "$9}'
else
    echo "   ❌ Port 8080 not listening"
fi
echo ""

# Check last state
echo "📝 Last State File:"
if [ -f /home/ubuntu/.orbs-tee-state.json ]; then
    echo "   ✅ State file exists"
    cat /home/ubuntu/.orbs-tee-state.json 2>/dev/null | head -10
else
    echo "   ❌ No state file found"
fi

echo ""
echo "════════════════════════════════════════════════════════"
echo ""
echo "💡 Commands:"
echo "   ./dev-session.sh          - Start/attach to tmux session"
echo "   tmux attach              - Reattach to last session"
echo "   tmux ls                  - List all sessions"
echo "   ./save-state.sh          - Save current work state"
echo "   ./restore-state.sh       - Restore previous state"
echo ""
