#!/usr/bin/env python3
"""
Simple test client for the enclave via vsocket
"""

import socket
import json
import struct
import sys

def send_request(cid, port, request):
    """Send request to enclave via vsocket"""
    try:
        # Connect to enclave
        s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
        s.connect((cid, port))

        # Serialize and send
        request_json = json.dumps(request)
        request_bytes = request_json.encode('utf-8')
        length = struct.pack('>I', len(request_bytes))
        s.sendall(length + request_bytes)

        # Receive response
        length_bytes = s.recv(4)
        if not length_bytes:
            return None
        response_length = struct.unpack('>I', length_bytes)[0]

        response_bytes = b''
        while len(response_bytes) < response_length:
            chunk = s.recv(min(4096, response_length - len(response_bytes)))
            if not chunk:
                break
            response_bytes += chunk

        s.close()
        return json.loads(response_bytes.decode('utf-8'))

    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_echo():
    """Test basic connectivity"""
    print("=" * 50)
    print("Test 1: Echo Test")
    print("=" * 50)

    request = {
        "id": "echo-001",
        "method": "echo",
        "params": {"message": "Hello from host!"},
        "timestamp": 1730659200
    }

    response = send_request(16, 5000, request)
    if response:
        print(json.dumps(response, indent=2))
        return response.get('success', False)
    return False

def test_get_price():
    """Test get_price method"""
    print("\n" + "=" * 50)
    print("Test 2: Get Price (will fail - no DNS)")
    print("=" * 50)

    request = {
        "id": "price-001",
        "method": "get_price",
        "params": {"symbol": "BTCUSDT"},
        "timestamp": 1730659200
    }

    response = send_request(16, 5000, request)
    if response:
        print(json.dumps(response, indent=2))
        return response.get('success', False)
    return False

def test_invalid_method():
    """Test error handling"""
    print("\n" + "=" * 50)
    print("Test 3: Invalid Method (error handling)")
    print("=" * 50)

    request = {
        "id": "invalid-001",
        "method": "nonexistent_method",
        "params": {},
        "timestamp": 1730659200
    }

    response = send_request(16, 5000, request)
    if response:
        print(json.dumps(response, indent=2))
        return not response.get('success', True)
    return False

def show_info():
    """Show enclave info"""
    print("\n" + "=" * 50)
    print("📋 Enclave Information")
    print("=" * 50)
    print("  Enclave CID: 16")
    print("  VSocket Port: 5000")
    print("  Available Methods:")
    print("    - get_price: Fetch crypto prices (needs DNS)")
    print("  ")
    print("  To add attestation endpoint, modify:")
    print("  /home/ubuntu/orbs-tee-enclave-nitro/examples/price-oracle/src/main.rs")
    print("=" * 50)

if __name__ == "__main__":
    print("\n🚀 Testing ORBS TEE Enclave\n")

    # Run tests
    test1 = test_echo()
    test2 = test_get_price()
    test3 = test_invalid_method()

    # Show info
    show_info()

    # Summary
    print("\n" + "=" * 50)
    print("📊 Test Summary")
    print("=" * 50)
    print(f"  Echo Test: {'❌ FAIL' if not test1 else '✅ PASS'}")
    print(f"  Get Price: {'❌ FAIL (expected - no DNS)' if not test2 else '✅ PASS'}")
    print(f"  Error Handling: {'✅ PASS' if test3 else '❌ FAIL'}")
    print("=" * 50)
