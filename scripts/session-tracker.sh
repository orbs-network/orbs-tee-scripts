#!/bin/bash
# Automatic Session Documentation Tracker
# Tracks all setup/installation sessions automatically

SESSION_DIR="/home/ubuntu/.sessions"
CURRENT_SESSION="$SESSION_DIR/session-$(date +%Y%m%d-%H%M%S).md"

# Create session directory
mkdir -p "$SESSION_DIR"

# Initialize session log
cat > "$CURRENT_SESSION" << 'HEADER'
# Session Log - $(date '+%Y-%m-%d %H:%M:%S')

## System Info
- **Instance**: $(ec2-metadata --instance-id 2>/dev/null | cut -d' ' -f2 || echo "N/A")
- **Region**: $(ec2-metadata --availability-zone 2>/dev/null | cut -d' ' -f2 || echo "N/A")
- **Kernel**: $(uname -r)
- **User**: $(whoami)

## Commands Executed

HEADER

# Function to log command
log_command() {
    local cmd="$1"
    local desc="$2"
    local status="$3"

    cat >> "$CURRENT_SESSION" << EOF
### $(date '+%H:%M:%S') - $desc
\`\`\`bash
$cmd
\`\`\`
**Status**: $status

EOF
}

# Function to log file changes
log_file_change() {
    local file="$1"
    local action="$2"

    cat >> "$CURRENT_SESSION" << EOF
### File: $file
- **Action**: $action
- **Time**: $(date '+%H:%M:%S')
- **Size**: $(ls -lh "$file" 2>/dev/null | awk '{print $5}' || echo "N/A")

EOF
}

# Function to finalize session
finalize_session() {
    cat >> "$CURRENT_SESSION" << EOF

---

## Summary

### Files Created/Modified
\`\`\`
$(find /home/ubuntu -name "*.md" -o -name "*.sh" -mmin -60 2>/dev/null | head -20)
\`\`\`

### Services Status
\`\`\`
$(systemctl list-units --type=service --state=running 2>/dev/null | head -10 || echo "N/A")
\`\`\`

### Disk Usage
\`\`\`
$(df -h / | tail -1)
\`\`\`

---
Generated: $(date)
EOF

    # Create latest symlink
    ln -sf "$CURRENT_SESSION" "$SESSION_DIR/latest.md"

    echo "Session log saved: $CURRENT_SESSION"
}

# Export functions for use in other scripts
export -f log_command
export -f log_file_change
export -f finalize_session
export CURRENT_SESSION

echo "Session tracking started: $CURRENT_SESSION"
echo "Use: log_command \"cmd\" \"description\" \"status\""
echo "Use: finalize_session when done"
