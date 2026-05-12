# Network Scan

This folder contains utilities for checking WiFi availability and basic ESP32-to-PC TCP communication.

## Files

| File | Description |
| --- | --- |
| `Networkscan.ino` | Scans nearby WiFi networks and prints SSID/RSSI values to the serial monitor. |
| `server.py` | Minimal TCP server that accepts one ESP32 connection and prints received messages. |

## Workflow

1. Upload `Networkscan.ino` to the ESP32.
2. Open the serial monitor and identify the correct WiFi network.
3. Run `server.py` on the PC to verify that TCP packets from the ESP32 can reach the computer.

## Role In The Project

This is a communication bring-up step. It should be checked before running identification, P/PI control, or MPC experiments that depend on WiFi communication.

