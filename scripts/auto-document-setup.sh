#!/bin/bash
# Automatic Setup Documentation Generator
# Call this after any installation/setup to auto-generate documentation

set -e

SETUP_NAME="${1:-setup}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_FILE="/home/ubuntu/${SETUP_NAME}-${TIMESTAMP}.md"

echo "🔍 Generating automatic documentation for: $SETUP_NAME"

# Start document
cat > "$OUTPUT_FILE" << EOF
# $SETUP_NAME Setup Documentation

**Generated**: $(date)
**User**: $(whoami)
**Instance**: $(ec2-metadata --instance-id 2>/dev/null | cut -d' ' -f2 || echo "N/A")

---

## System State

### OS Information
\`\`\`
$(cat /etc/os-release | head -5)
\`\`\`

### Kernel
\`\`\`
$(uname -a)
\`\`\`

### Available Memory
\`\`\`
$(free -h)
\`\`\`

### Disk Usage
\`\`\`
$(df -h /)
\`\`\`

---

## Installed Software

EOF

# Check for various tools
check_tool() {
    local tool="$1"
    if command -v "$tool" &> /dev/null; then
        echo "### $tool" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        $tool --version 2>&1 | head -3 >> "$OUTPUT_FILE" || echo "Version info not available" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
}

check_tool "nitro-cli"
check_tool "docker"
check_tool "cargo"
check_tool "node"
check_tool "npm"
check_tool "python3"
check_tool "git"

# Check for running services
cat >> "$OUTPUT_FILE" << EOF

---

## Running Services

\`\`\`
$(systemctl list-units --type=service --state=running | head -20)
\`\`\`

---

## Network Configuration

### Listening Ports
\`\`\`
$(ss -tuln | head -20)
\`\`\`

### Firewall Status
\`\`\`
$(sudo iptables -L -n | head -20 2>/dev/null || echo "Not accessible")
\`\`\`

---

## Recent File Changes (Last Hour)

### Modified Files
\`\`\`
$(find /home/ubuntu -type f -mmin -60 2>/dev/null | head -30)
\`\`\`

### New Directories
\`\`\`
$(find /home/ubuntu -type d -mmin -60 2>/dev/null | head -20)
\`\`\`

---

## Key Files

EOF

# Check for key configuration files
for file in /home/ubuntu/orbs-tee-host/config.json \
            /etc/nitro_enclaves/allocator.yaml \
            /home/ubuntu/price-oracle*.eif \
            /home/ubuntu/attestation_document.bin; do
    if [ -f "$file" ]; then
        echo "### $file" >> "$OUTPUT_FILE"
        echo "- **Size**: $(ls -lh "$file" | awk '{print $5}')" >> "$OUTPUT_FILE"
        echo "- **Modified**: $(stat -c '%y' "$file")" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

# Nitro enclave status if available
if command -v nitro-cli &> /dev/null; then
    cat >> "$OUTPUT_FILE" << EOF

---

## Nitro Enclave Status

\`\`\`json
$(source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh 2>/dev/null && nitro-cli describe-enclaves 2>/dev/null || echo "No enclaves running")
\`\`\`

EOF
fi

# Check for hugepages
cat >> "$OUTPUT_FILE" << EOF

---

## Memory Configuration

### Hugepages
\`\`\`
$(grep -i huge /proc/meminfo)
\`\`\`

---

## Recent Logs

### System Logs (Last 20 lines)
\`\`\`
$(sudo journalctl -n 20 2>/dev/null || echo "Not accessible")
\`\`\`

---

## Environment Variables (Filtered)

\`\`\`
$(env | grep -E "PATH|HOME|USER|CARGO|NODE" | sort)
\`\`\`

---

## Quick Commands Reference

\`\`\`bash
# Check enclave status
source /tmp/nitro-cli/build/install/etc/profile.d/nitro-cli-env.sh
nitro-cli describe-enclaves

# View logs
sudo journalctl -u nitro-enclaves-allocator -f

# Test enclave
python3 /home/ubuntu/test-enclave-full.py

# Verify setup
/home/ubuntu/verify-enclave.sh
\`\`\`

---

**Documentation generated automatically by auto-document-setup.sh**
**Saved to**: $OUTPUT_FILE
EOF

echo "✅ Documentation generated: $OUTPUT_FILE"
echo "📄 View with: cat $OUTPUT_FILE"

# Create latest symlink
ln -sf "$OUTPUT_FILE" "/home/ubuntu/${SETUP_NAME}-latest.md"
echo "📌 Latest link: /home/ubuntu/${SETUP_NAME}-latest.md"
