# Identification Firmware

This folder contains the ESP32 firmware used to collect data for dynamic model identification.

## File

| File | Description |
| --- | --- |
| `Identification.ino` | Applies a PWM step profile, reads HC-SR04 distance, filters the signal, and sends experiment packets to the PC. |

## Control And Measurement Flow

```text
PWM step profile -> ESCs/motors -> vehicle motion -> ultrasonic distance -> filtering -> TCP packet
```

The firmware uses:

- a predefined open-loop PWM profile,
- median filtering to reject ultrasonic outliers,
- fast and slow EMA filters for distance smoothing,
- TCP packets containing time, PWM, raw distance, and filtered distance.

## Important Timing

The sampling period is:

```cpp
static const float Ts = 0.05f;
```

This corresponds to a 50 ms sample time and must match the MATLAB identification script.

## Role In The Project

This firmware generates the measured data needed to estimate the vehicle model for MPC.

