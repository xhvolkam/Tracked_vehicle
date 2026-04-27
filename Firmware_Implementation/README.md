# Firmware Implementation

This folder contains the firmware developed for the tracked vehicle platform used in the diploma thesis.

The firmware is implemented on the ESP32 and focuses on motor control, communication, and sensor integration.

---

## Overview

The firmware development was carried out in several stages:

* ESC calibration and motor initialization
* Motor control with PWM signals
* Data logging and communication with server
* Distance measurement using ultrasonic sensor (HC-SR04)
* Network connectivity testing

Each stage is organized into a separate subfolder.

---

## Structure

### Motor_calibration

Code used for ESC calibration and proper motor initialization.

---

### Motor_logging

Basic motor control with periodic data transmission.

---

### Motor_logging_distance

Motor control extended with distance measurement using HC-SR04.

---

### Networkscan

WiFi scanning and connection testing utilities.

---

