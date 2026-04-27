import socket
import csv
from datetime import datetime

HOST = "0.0.0.0"
PORT = 8080

timestamp_str = datetime.now().strftime("%Y%m%d_%H%M%S")
csv_filename = f"car_data_{timestamp_str}.csv"

FIELDS = [
    "Timestamp",
    "TIME",
    "TEXP",
    "PWM",
    "DIST_RAW",
    "DIST_FILT",
]

def parse_kv_line(line: str) -> dict:
    """
    Parses lines like:
    TIME=123, TEXP=456, PWM=1200, DIST_RAW=12.34, DIST_FILT=12.10
    Returns dict with uppercase keys.
    """
    out = {}
    parts = line.split(",")
    for part in parts:
        part = part.strip()
        if "=" not in part:
            continue
        key, value = part.split("=", 1)
        out[key.strip().upper()] = value.strip()
    return out

def to_int(x):
    if x is None:
        return ""
    x = x.strip()
    if x == "":
        return ""
    x = x.replace("\r", "")
    return int(x)

def to_float(x):
    if x is None:
        return ""
    x = x.strip()
    if x == "":
        return ""
    x = x.replace("\r", "")
    return float(x)

# TCP socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_socket.bind((HOST, PORT))
server_socket.listen(1)

print(f"🔵 Server is running on {HOST}:{PORT}")
print("⏳ Waiting for ESP32 to connect...")

conn, addr = server_socket.accept()
print(f"✅ ESP32 connected from {addr}")
print(f"📝 Logging to: {csv_filename}")

with open(csv_filename, mode="w", newline="") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=FIELDS)
    writer.writeheader()
    csvfile.flush()

    buffer = ""
    total_lines = 0
    parsed_lines = 0
    bad_lines = 0

    last_print_time = datetime.now()
    last_flush_time = datetime.now()
    last_line = ""

    try:
        while True:
            chunk = conn.recv(4096)
            if not chunk:
                break

            # decode robustly
            buffer += chunk.decode("utf-8", errors="ignore")

            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                line = line.strip()
                if not line:
                    continue

                total_lines += 1
                last_line = line
                ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]

                try:
                    kv = parse_kv_line(line)

                    row = {"Timestamp": ts}
                    row["TIME"] = to_int(kv.get("TIME"))
                    row["TEXP"] = to_int(kv.get("TEXP"))
                    row["PWM"] = to_int(kv.get("PWM"))
                    row["DIST_RAW"] = to_float(kv.get("DIST_RAW"))
                    row["DIST_FILT"] = to_float(kv.get("DIST_FILT"))

                    writer.writerow(row)
                    parsed_lines += 1

                except Exception:
                    bad_lines += 1

                now_dt = datetime.now()

                if (now_dt - last_flush_time).total_seconds() >= 1.0:
                    csvfile.flush()
                    last_flush_time = now_dt

                if (now_dt - last_print_time).total_seconds() >= 2.0:
                    print(
                        f"📩 {now_dt.strftime('%H:%M:%S')} | "
                        f"total={total_lines}, ok={parsed_lines}, bad={bad_lines} | "
                        f"last: {last_line}"
                    )
                    last_print_time = now_dt

    except KeyboardInterrupt:
        print("\n🛑 Server stopped manually.")
    finally:
        csvfile.flush()
        conn.close()
        server_socket.close()
        print("🔒 Connection closed.")
        print(f"✅ Final stats: total={total_lines}, ok={parsed_lines}, bad={bad_lines}")