import socket

# Minimal receive-only TCP server used to check that ESP32 packets reach the PC.

HOST = '0.0.0.0'   
PORT = 8080

# Bind to all interfaces so the ESP32 can connect through the active adapter.
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(1)

print(f"🔵 Server is running on {HOST}:{PORT}")
print("⏳ Waiting for ESP32 to connect...")

conn, addr = server_socket.accept()
print(f"✅ ESP32 connected from {addr}")

try:
    while True:
        # This diagnostic server prints raw payloads and does not attempt CSV parsing.
        data = conn.recv(1024).decode().strip()
        if not data:
            break
        print(f"📩 Received: {data}")
except KeyboardInterrupt:
    print("\n🛑 Server stopped manually.")
finally:
    conn.close()
    server_socket.close()
    print("🔒 Connection closed.")
