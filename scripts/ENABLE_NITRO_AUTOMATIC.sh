#!/bin/bash
# Script to Enable Nitro Enclaves Automatically
#
# Unfortunately, this CANNOT be run from the instance itself because:
# 1. The instance must be STOPPED to enable Nitro Enclaves
# 2. You can't stop an instance from within itself
# 3. Requires AWS API access with proper IAM permissions
#
# You must run this from your LOCAL MACHINE with AWS CLI configured

set -e

# Get instance ID
INSTANCE_ID=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null | xargs -I {} curl -H "X-aws-ec2-metadata-token: {}" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)

if [ -z "$INSTANCE_ID" ]; then
    # Try IMDSv1
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
fi

if [ -z "$INSTANCE_ID" ]; then
    echo "❌ Could not get instance ID"
    echo ""
    echo "You need to run this FROM YOUR LOCAL MACHINE (not the server):"
    echo ""
    echo "INSTANCE_ID=i-xxxxx  # Your instance ID"
    echo 'aws ec2 stop-instances --instance-ids $INSTANCE_ID'
    echo 'aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID'
    echo 'aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --enclave-options Enabled=true'
    echo 'aws ec2 start-instances --instance-ids $INSTANCE_ID'
    exit 1
fi

echo "Instance ID: $INSTANCE_ID"
echo ""
echo "❌ CANNOT enable from within the instance (must stop it first)"
echo ""
echo "Run these commands FROM YOUR LOCAL MACHINE:"
echo ""
echo "# Stop instance"
echo "aws ec2 stop-instances --instance-ids $INSTANCE_ID"
echo ""
echo "# Wait for it to stop"
echo "aws ec2 wait instance-stopped --instance-ids $INSTANCE_ID"
echo ""
echo "# Enable Nitro Enclaves"
echo "aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --enclave-options Enabled=true"
echo ""
echo "# Start instance"
echo "aws ec2 start-instances --instance-ids $INSTANCE_ID"
echo ""
echo "# Wait for it to start"
echo "aws ec2 wait instance-running --instance-ids $INSTANCE_ID"
echo ""
echo "Then SSH back in and verify:"
echo "ssh ubuntu@35.179.36.200"
echo "ls -la /dev/nsm"
