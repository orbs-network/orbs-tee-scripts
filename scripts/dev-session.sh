#!/bin/bash
# Start or attach to a persistent development session using tmux
# Usage: ./dev-session.sh [session-name]

SESSION_NAME="${1:-orbs-tee-dev}"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "❌ tmux is not installed"
    echo "Install with: sudo apt-get install tmux"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "📎 Attaching to existing session: $SESSION_NAME"
    tmux attach-session -t "$SESSION_NAME"
else
    echo "🚀 Creating new development session: $SESSION_NAME"

    # Create new session with 4 windows
    tmux new-session -d -s "$SESSION_NAME" -n "main"

    # Window 1: Main terminal
    tmux send-keys -t "$SESSION_NAME:main" "cd /home/ubuntu" C-m
    tmux send-keys -t "$SESSION_NAME:main" "echo '=== Main Terminal ===' && echo 'Windows: main | enclave | host | test'" C-m

    # Window 2: Enclave
    tmux new-window -t "$SESSION_NAME" -n "enclave"
    tmux send-keys -t "$SESSION_NAME:enclave" "cd /home/ubuntu/orbs-tee-enclave-nitro" C-m
    tmux send-keys -t "$SESSION_NAME:enclave" "echo '=== Enclave Terminal ===' && echo 'Run: cargo test --no-default-features'" C-m

    # Window 3: Host
    tmux new-window -t "$SESSION_NAME" -n "host"
    tmux send-keys -t "$SESSION_NAME:host" "cd /home/ubuntu/orbs-tee-host" C-m
    tmux send-keys -t "$SESSION_NAME:host" "echo '=== Host Terminal ===' && echo 'Run: npm run dev'" C-m

    # Window 4: Testing
    tmux new-window -t "$SESSION_NAME" -n "test"
    tmux send-keys -t "$SESSION_NAME:test" "cd /home/ubuntu" C-m
    tmux send-keys -t "$SESSION_NAME:test" "echo '=== Test Terminal ===' && echo 'Run curl commands here'" C-m

    # Select first window
    tmux select-window -t "$SESSION_NAME:main"

    # Attach to session
    echo "✅ Session created with 4 windows!"
    tmux attach-session -t "$SESSION_NAME"
fi
