#!/usr/bin/env python3
"""
Simple HTTP server for attestation endpoint
Bridges HTTP → VSocket for enclave communication
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import socket
import struct
import sys

VSOCK_CID = 16
VSOCK_PORT = 5000
HTTP_PORT = 8443


class AttestationHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/api/v1/health':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "status": "healthy",
                "enclaveConnected": True,
                "port": HTTP_PORT
            }
            self.wfile.write(json.dumps(response).encode())
        elif self.path == '/api/v1/status':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = {
                "status": "healthy",
                "enclaveConnected": True,
                "enclaveCID": VSOCK_CID,
                "enclavePort": VSOCK_PORT
            }
            self.wfile.write(json.dumps(response).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        """Handle POST requests"""
        if self.path == '/api/v1/request':
            try:
                # Read request body
                content_length = int(self.headers['Content-Length'])
                post_data = self.rfile.read(content_length)
                request_data = json.loads(post_data.decode('utf-8'))

                # Add required fields if missing
                if 'id' not in request_data:
                    request_data['id'] = 'http-request'
                if 'timestamp' not in request_data:
                    import time
                    request_data['timestamp'] = int(time.time())

                # Forward to enclave via vsocket
                response_data = self.forward_to_enclave(request_data)

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps(response_data).encode())

            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.end_headers()
                error_response = {
                    "success": False,
                    "error": str(e)
                }
                self.wfile.write(json.dumps(error_response).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        """Handle CORS preflight"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def forward_to_enclave(self, request_data):
        """Forward request to enclave via vsocket"""
        try:
            # Connect to enclave
            s = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
            s.settimeout(30)
            s.connect((VSOCK_CID, VSOCK_PORT))

            # Send request (length-prefixed JSON)
            request_json = json.dumps(request_data)
            request_bytes = request_json.encode('utf-8')
            length_buffer = struct.pack('>I', len(request_bytes))
            s.sendall(length_buffer + request_bytes)

            # Read response (length-prefixed JSON)
            length_bytes = s.recv(4)
            if len(length_bytes) != 4:
                raise Exception("Failed to read response length")

            response_length = struct.unpack('>I', length_bytes)[0]
            response_bytes = b''
            while len(response_bytes) < response_length:
                chunk = s.recv(min(4096, response_length - len(response_bytes)))
                if not chunk:
                    break
                response_bytes += chunk

            s.close()

            # Parse and return response
            return json.loads(response_bytes.decode('utf-8'))

        except Exception as e:
            return {
                "success": False,
                "error": f"Enclave communication error: {str(e)}"
            }

    def log_message(self, format, *args):
        """Custom log format"""
        sys.stdout.write(f"[{self.log_date_time_string()}] {format % args}\n")


def main():
    server_address = ('0.0.0.0', HTTP_PORT)
    httpd = HTTPServer(server_address, AttestationHandler)

    print(f"=" * 60)
    print(f"HTTP Attestation Server")
    print(f"=" * 60)
    print(f"Listening on: 0.0.0.0:{HTTP_PORT}")
    print(f"Enclave: CID {VSOCK_CID}, Port {VSOCK_PORT}")
    print(f"")
    print(f"Endpoints:")
    print(f"  GET  /api/v1/health")
    print(f"  GET  /api/v1/status")
    print(f"  POST /api/v1/request")
    print(f"")
    print(f"Ready for requests...")
    print(f"=" * 60)

    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        httpd.shutdown()


if __name__ == '__main__':
    main()
