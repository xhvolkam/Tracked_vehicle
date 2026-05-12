# Model Predictive Control

This section contains the MATLAB-based MPC implementations for distance regulation of the tracked vehicle.

## What Was Implemented

- Online MPC solved with YALMIP/Gurobi at each control step.
- Tube MPC built with MPT for robust control under bounded disturbances.
- ESP32 firmware for sensing, filtering, TCP communication, and PWM actuation.
- MATLAB TCP servers for receiving telemetry and sending PWM commands.
- Plotting tools for analyzing states, outputs, inputs, and constraint behavior.

## General MPC Workflow

```text
ESP32 distance measurement
-> filtering
-> TCP telemetry packet
-> MATLAB state estimation and MPC computation
-> PWM command reply
-> ESP32 motor actuation
```

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `Online MPC/` | Online optimization-based MPC implementation. |
| `Tube MPC/` | Robust Tube MPC implementation with disturbance handling. |

## Role In The Project

This is the advanced control section. It uses the identified model to predict future vehicle behavior and compute constrained PWM commands.

