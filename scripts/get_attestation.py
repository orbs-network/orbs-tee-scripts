#!/usr/bin/env python3
"""
Simple client to connect to the enclave via vsocket and request attestation.
"""

import socket
import json
import struct
import base64

def send_request(cid, port, request):
    """Send a request to the enclave via vsocket."""
    # Create vsocket connection
    s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
    s.connect((cid, port))

    # Serialize request to JSON
    request_json = json.dumps(request)
    request_bytes = request_json.encode('utf-8')

    # Send length prefix (4 bytes, big-endian)
    length = struct.pack('>I', len(request_bytes))
    s.sendall(length + request_bytes)

    # Receive length prefix
    length_bytes = s.recv(4)
    response_length = struct.unpack('>I', length_bytes)[0]

    # Receive response
    response_bytes = b''
    while len(response_bytes) < response_length:
        chunk = s.recv(min(4096, response_length - len(response_bytes)))
        if not chunk:
            break
        response_bytes += chunk

    s.close()

    # Parse response
    response = json.loads(response_bytes.decode('utf-8'))
    return response

def main():
    cid = 16  # Enclave CID
    port = 5000  # Vsocket port

    # Request attestation
    print("🔐 Requesting attestation document from enclave...")
    request = {
        "id": "attest-001",
        "method": "get_attestation",
        "params": {},
        "timestamp": 1730659200
    }

    try:
        response = send_request(cid, port, request)
        print("\n✅ Received response:")
        print(json.dumps(response, indent=2))

        if response.get("success"):
            attestation_data = response.get("data", {})
            attestation_doc = attestation_data.get("attestation_document")

            if attestation_doc:
                print("\n📜 Attestation Document (base64):")
                print(attestation_doc[:200] + "..." if len(attestation_doc) > 200 else attestation_doc)

                print(f"\n📏 Attestation document size: {len(attestation_doc)} bytes (base64)")

                # Decode and show size
                try:
                    doc_bytes = base64.b64decode(attestation_doc)
                    print(f"📦 Decoded size: {len(doc_bytes)} bytes")
                except:
                    pass

    except Exception as e:
        print(f"\n❌ Error: {e}")

if __name__ == "__main__":
    main()
