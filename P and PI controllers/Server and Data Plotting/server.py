import socket
import csv
import os
from datetime import datetime

HOST = '0.0.0.0'
PORT = 8080

timestamp_str = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_filename = f"car_data_{timestamp_str}.csv"

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(1)

print(f"🔵 Server is running on {HOST}:{PORT}")
print("⏳ Waiting for ESP32 to connect...")

conn, addr = server_socket.accept()
print(f"✅ ESP32 connected from {addr}")

with open(csv_filename, mode='w', newline='') as csvfile:
    csv_writer = csv.writer(csvfile)
    csv_writer.writerow(["Timestamp", "TIME", "PWM_LEFT", "PWM_RIGHT", "DIST"])

    try:
        while True:
            data = conn.recv(4096).decode().strip() 
            if not data:
                break

            lines = data.splitlines()
            for line in lines:
                timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

                try:
                    parts = line.split(',')
                    time_val = pwm_left = pwm_right = dist_val = None

                    for part in parts:
                        key, value = part.strip().split('=')
                        key = key.upper()
                        if key == "TIME":
                            time_val = int(value)
                        elif key == "PWM_LEFT":
                            pwm_left = int(value)
                        elif key == "PWM_RIGHT":
                            pwm_right = int(value)
                        elif key == "DIST":
                            dist_val = float(value)

                    if None not in (time_val, pwm_left, pwm_right, dist_val):
                        csv_writer.writerow([timestamp, time_val, pwm_left, pwm_right, dist_val])
                        csvfile.flush()  # okamžité zapisovanie
                    else:
                        print(f"⚠️ Incomplete data: {line}")

                except Exception as e:
                    print(f"⚠️ Failed to parse line '{line}': {e}")

                print(f"📩 {timestamp} | {line}")

    except KeyboardInterrupt:
        print("\n🛑 Server stopped manually.")
    finally:
        conn.close()
        server_socket.close()
        print("🔒 Connection closed.")
