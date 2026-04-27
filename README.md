# Controller Design and Implementation for Tracked Vehicle

This repository contains the implementation of my diploma thesis focused on Adaptive Cruise Control (ACC) using Model Predictive Control (MPC) on a small tracked vehicle.

The goal of the system is to maintain a desired distance from an obstacle using real-time optimization running in MATLAB, while the embedded ESP32 handles sensing, actuation, and communication.

## 📸 Vehicle

![RC Car](docs/car_photo.jpg)

## 🚗 Hardware Overview

The platform is a custom-built tracked vehicle consisting of:

- ESP32-S3 DevKitC-1
- 2× BLDC motors Sunnysky X2212 980KV
- 2× ESC controllers
- HC-SR04 ultrasonic sensor
- Li-Po battery (3S, 11.1 V)
- External 5V regulator (MB102)

- 
