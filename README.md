# Controller Design and Implementation for Tracked Vehicle

This repository contains the implementation of my diploma thesis focused on Adaptive Cruise Control (ACC) using Model Predictive Control (MPC) on a small tracked vehicle.

The goal of the system is to maintain a desired distance from an obstacle using real-time optimization running in MATLAB, while the embedded ESP32 handles sensing, actuation, and communication.

---

## 📸 Vehicle

![RC Car](Documents/rc_vehicle.png)

---

## 🚗 Hardware Overview

The platform is a custom-built tracked vehicle consisting of:

- PLA chassis
- ESP32-S3 DevKitC-1
- 2× BLDC motors Sunnysky X2212 980KV
- 2× ESC controllers
- HC-SR04 ultrasonic sensor
- Li-Po battery (3S, 11.1 V)
- External 5V regulator (MB102)

---

## 🔌 Final Hardware Wiring

![Wiring Diagram](Documents/wiring_diagram.png)

---

## ⚙️ Firmware Implementation


The ESP32 firmware is responsible for low-level control of the tracked vehicle, including motor actuation, data logging, and communication.

This part is described in more detail in the 📂 [Firmware Implementation](Tracked_vehicle/Firmware%20Implementation/) section of the repository, where the following aspects are covered:

* sensor wiring and integration
* data logging and communication
* motor initialization and control

The repository contains individual programs used during development, organized into separate modules for clarity and easier testing.


