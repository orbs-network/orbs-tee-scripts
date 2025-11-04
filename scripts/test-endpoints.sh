#!/bin/bash

# ORBS TEE System - Endpoint Test Script
# This script tests all available API endpoints

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="${BASE_URL:-http://localhost:8080}"
VERBOSE="${VERBOSE:-false}"

# Counter for tests
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo "=========================================="
echo "  ORBS TEE System - Endpoint Tests"
echo "=========================================="
echo ""
echo "Base URL: $BASE_URL"
echo "Verbose: $VERBOSE"
echo ""

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to test endpoint
test_endpoint() {
    local name="$1"
    local method="$2"
    local path="$3"
    local data="$4"
    local expected_field="$5"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))

    echo ""
    echo "----------------------------------------"
    echo "Test $TOTAL_TESTS: $name"
    echo "----------------------------------------"

    # Build curl command
    if [ "$method" = "GET" ]; then
        RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL$path" 2>&1)
    else
        RESPONSE=$(curl -s -w "\n%{http_code}" -X "$method" "$BASE_URL$path" \
            -H "Content-Type: application/json" \
            -d "$data" 2>&1)
    fi

    # Extract HTTP code and body
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)

    # Check HTTP code
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "HTTP Status: $HTTP_CODE"

        # Check if response is valid JSON
        if echo "$BODY" | jq . >/dev/null 2>&1; then
            print_success "Valid JSON response"

            # Check for expected field if provided
            if [ -n "$expected_field" ]; then
                if echo "$BODY" | jq -e "$expected_field" >/dev/null 2>&1; then
                    print_success "Expected field '$expected_field' found"
                    PASSED_TESTS=$((PASSED_TESTS + 1))
                else
                    print_error "Expected field '$expected_field' not found"
                    FAILED_TESTS=$((FAILED_TESTS + 1))
                fi
            else
                PASSED_TESTS=$((PASSED_TESTS + 1))
            fi

            # Print response (formatted or full)
            if [ "$VERBOSE" = "true" ]; then
                echo ""
                echo "Full Response:"
                echo "$BODY" | jq .
            else
                echo ""
                echo "Response Summary:"
                echo "$BODY" | jq 'if .success then {success, data: (.data | keys)} elif .status then {status, enclaveConnected} else . end' 2>/dev/null || echo "$BODY" | jq '{keys: keys}' 2>/dev/null || echo "$BODY"
            fi
        else
            print_error "Invalid JSON response"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            echo "Response: $BODY"
        fi
    else
        print_error "HTTP Status: $HTTP_CODE (expected 200)"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo "Response: $BODY"
    fi
}

# Test 1: Health Check
test_endpoint \
    "Health Check" \
    "GET" \
    "/api/v1/health" \
    "" \
    ".enclaveConnected"

# Test 2: Status
test_endpoint \
    "Status Check" \
    "GET" \
    "/api/v1/status" \
    "" \
    ".hostVersion"

# Test 3: Bitcoin Price
test_endpoint \
    "Bitcoin Price (BTCUSDT)" \
    "POST" \
    "/api/v1/request" \
    '{"method":"get_price","params":{"symbol":"BTCUSDT"}}' \
    ".data.price"

# Test 4: Ethereum Price
test_endpoint \
    "Ethereum Price (ETHUSDT)" \
    "POST" \
    "/api/v1/request" \
    '{"method":"get_price","params":{"symbol":"ETHUSDT"}}' \
    ".data.price"

# Test 5: Binance Coin Price
test_endpoint \
    "Binance Coin Price (BNBUSDT)" \
    "POST" \
    "/api/v1/request" \
    '{"method":"get_price","params":{"symbol":"BNBUSDT"}}' \
    ".data.price"

# Test 6: Solana Price
test_endpoint \
    "Solana Price (SOLUSDT)" \
    "POST" \
    "/api/v1/request" \
    '{"method":"get_price","params":{"symbol":"SOLUSDT"}}' \
    ".data.price"

# Test 7: Attestation
test_endpoint \
    "Get Attestation" \
    "POST" \
    "/api/v1/request" \
    '{"method":"get_attestation","params":{"nonce":"test-'$(date +%s)'","user_data":"endpoint-test"}}' \
    ".data.public_key"

# Test 8: Multiple consecutive requests (stability test)
echo ""
echo "----------------------------------------"
echo "Test $((TOTAL_TESTS + 1)): Stability Test (5 consecutive requests)"
echo "----------------------------------------"
TOTAL_TESTS=$((TOTAL_TESTS + 1))

STABILITY_SUCCESS=0
for i in {1..5}; do
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/request" \
        -H "Content-Type: application/json" \
        -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}')

    if echo "$RESPONSE" | jq -e '.success == true' >/dev/null 2>&1; then
        STABILITY_SUCCESS=$((STABILITY_SUCCESS + 1))
        print_success "Request $i: Success"
    else
        print_error "Request $i: Failed"
    fi
    sleep 0.5
done

if [ $STABILITY_SUCCESS -eq 5 ]; then
    print_success "Stability Test: All 5 requests succeeded"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    print_error "Stability Test: Only $STABILITY_SUCCESS/5 requests succeeded"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Test 9: Response time test
echo ""
echo "----------------------------------------"
echo "Test $((TOTAL_TESTS + 1)): Response Time"
echo "----------------------------------------"
TOTAL_TESTS=$((TOTAL_TESTS + 1))

START_TIME=$(date +%s%N)
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/request" \
    -H "Content-Type: application/json" \
    -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}')
END_TIME=$(date +%s%N)

RESPONSE_TIME=$(( (END_TIME - START_TIME) / 1000000 ))

if [ $RESPONSE_TIME -lt 5000 ]; then
    print_success "Response Time: ${RESPONSE_TIME}ms (< 5000ms)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    print_warning "Response Time: ${RESPONSE_TIME}ms (> 5000ms)"
    PASSED_TESTS=$((PASSED_TESTS + 1))
fi

# Test 10: Signature verification
echo ""
echo "----------------------------------------"
echo "Test $((TOTAL_TESTS + 1)): Signature Presence"
echo "----------------------------------------"
TOTAL_TESTS=$((TOTAL_TESTS + 1))

RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/request" \
    -H "Content-Type: application/json" \
    -d '{"method":"get_price","params":{"symbol":"BTCUSDT"}}')

SIGNATURE=$(echo "$RESPONSE" | jq -r '.signature // empty')

if [ -n "$SIGNATURE" ] && [ "$SIGNATURE" != "null" ]; then
    SIG_LENGTH=${#SIGNATURE}
    print_success "Signature present (length: $SIG_LENGTH)"

    if [ $SIG_LENGTH -eq 128 ]; then
        print_success "Signature has correct length (128 hex chars = 64 bytes)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        print_warning "Signature length unexpected: $SIG_LENGTH (expected 128)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
else
    print_error "No signature in response"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

# Summary
echo ""
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    print_success "All tests passed! ✨"
    echo ""
    exit 0
else
    print_error "Some tests failed!"
    echo ""
    echo "Troubleshooting tips:"
    echo "1. Check if services are running: sudo systemctl status orbs-tee-host orbs-tee-enclave"
    echo "2. View logs: sudo journalctl -u orbs-tee-host -n 50"
    echo "3. Check enclave socket: ls -la /tmp/enclave.sock"
    echo "4. See OPS_MANUAL.md for more troubleshooting steps"
    echo ""
    exit 1
fi
