#!/usr/bin/env python3
"""
VSOCK to Unix Socket Bridge
Bridges vsocket (CID 16, Port 5000) to Unix socket (/tmp/enclave.sock)
"""

import socket
import os
import threading
import struct
import sys

VSOCK_CID = 16
VSOCK_PORT = 5000
UNIX_SOCKET_PATH = "/tmp/enclave.sock"


def handle_client(unix_conn, addr):
    """Handle a client connection from Unix socket"""
    print(f"[+] Client connected from {addr}")

    try:
        # Connect to vsocket
        vsock = socket.socket(socket.AF_VSOCK, socket.SOCK_STREAM)
        vsock.connect((VSOCK_CID, VSOCK_PORT))
        print(f"[+] Connected to enclave via vsocket (CID {VSOCK_CID}, Port {VSOCK_PORT})")

        # Forward data in both directions
        def forward(src, dst, name):
            try:
                while True:
                    data = src.recv(4096)
                    if not data:
                        break
                    dst.sendall(data)
            except Exception as e:
                print(f"[-] Forward error ({name}): {e}")
            finally:
                src.close()
                dst.close()

        # Start bidirectional forwarding
        t1 = threading.Thread(target=forward, args=(unix_conn, vsock, "unix->vsock"))
        t2 = threading.Thread(target=forward, args=(vsock, unix_conn, "vsock->unix"))
        t1.start()
        t2.start()
        t1.join()
        t2.join()

    except Exception as e:
        print(f"[-] Error: {e}")
    finally:
        unix_conn.close()
        print(f"[+] Client disconnected")


def main():
    # Remove existing socket file
    if os.path.exists(UNIX_SOCKET_PATH):
        os.unlink(UNIX_SOCKET_PATH)

    # Create Unix socket server
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(UNIX_SOCKET_PATH)
    server.listen(5)

    print(f"[*] VSOCK-to-Unix bridge started")
    print(f"[*] Listening on: {UNIX_SOCKET_PATH}")
    print(f"[*] Forwarding to: CID {VSOCK_CID}, Port {VSOCK_PORT}")
    print(f"[*] Waiting for connections...")

    try:
        while True:
            conn, addr = server.accept()
            client_thread = threading.Thread(target=handle_client, args=(conn, addr))
            client_thread.daemon = True
            client_thread.start()
    except KeyboardInterrupt:
        print("\n[*] Shutting down...")
    finally:
        server.close()
        if os.path.exists(UNIX_SOCKET_PATH):
            os.unlink(UNIX_SOCKET_PATH)


if __name__ == "__main__":
    main()
