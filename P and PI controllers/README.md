# P And PI Controllers

This section contains classical feedback controllers for distance regulation of the tracked vehicle. These controllers were implemented before MPC to validate sensing, filtering, actuation, and logging.

## What Was Implemented

- Proportional distance controller.
- Proportional-integral distance controller.
- Ultrasonic distance filtering using EMA and median filtering.
- Feedforward support based on fast/slow filtered distance difference.
- TCP logging of PWM and distance data.
- MATLAB plotting of recorded experiments.

## Control Workflow

```text
HC-SR04 distance -> filtering -> distance error -> P/PI control -> PWM command -> ESCs/motors
```

The target distance used in the controller experiments is typically:

```cpp
float targetDistance = 50.0f;
```

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `P_controller/` | ESP32 implementation of proportional distance control. |
| `PI_controller/` | ESP32 implementation of PI distance control with filtering and safety logic. |
| `Server and Data Plotting/` | Python TCP logger, recorded datasets, and MATLAB plotting script. |

## Role In The Project

This section is the bridge between open-loop identification and model-based control. It proves that the vehicle can regulate distance locally on the ESP32 before MATLAB-based MPC is introduced.

