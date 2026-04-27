# Controller Design and Implementation for Tracked Vehicle

This repository contains the implementation of my diploma thesis focused on Adaptive Cruise Control (ACC) using Model Predictive Control (MPC) on a small tracked vehicle.

The goal of the system is to maintain a desired distance from an obstacle using real-time optimization running in MATLAB, while the embedded ESP32 handles sensing, actuation, and communication.

## 📸 Vehicle

![RC Car](Documents/rc_vehicle.png)

## 🚗 Hardware Overview

The platform is a custom-built tracked vehicle consisting of:

- PLA chassis
- ESP32-S3 DevKitC-1
- 2× BLDC motors Sunnysky X2212 980KV
- 2× ESC controllers
- HC-SR04 ultrasonic sensor
- Li-Po battery (3S, 11.1 V)
- External 5V regulator (MB102)

## 🔌 Final Hardware Wiring

![Wiring Diagram](Documents/wiring_diagram.png)

## ⚙️ Firmware Implementation

📂 Full code: 

The ESP32 firmware is responsible for reading distance from the ultrasonic sensor, filtering the measured signal, controlling both ESCs using PWM, and sending measured data to the server for logging and controller evaluation.

### Distance Measurement

The distance is measured using the HC-SR04 ultrasonic sensor. The ESP32 sends a short trigger pulse and measures the duration of the returned echo signal.

```cpp
float readDistanceCM() {
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    long duration = pulseIn(ECHO_PIN, HIGH, 30000);
    if (duration == 0) return -1;

    return (duration * 0.0343 / 2.0);
}

