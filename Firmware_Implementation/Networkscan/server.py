import socket

HOST = '0.0.0.0'   
PORT = 8080

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(1)

print(f"🔵 Server is running on {HOST}:{PORT}")
print("⏳ Waiting for ESP32 to connect...")

conn, addr = server_socket.accept()
print(f"✅ ESP32 connected from {addr}")

try:
    while True:
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
