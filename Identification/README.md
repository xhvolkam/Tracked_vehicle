# System Identification

This section identifies a simple discrete-time model of the tracked vehicle from measured input-output data. The resulting model is later used by the MPC implementations.

## What Was Implemented

- ESP32 firmware that applies a predefined PWM step profile.
- TCP logging of PWM and ultrasonic distance measurements.
- MATLAB processing for velocity estimation, filtering, plotting, and parameter fitting.

## Workflow

1. Upload `Identification/Identification.ino` to the ESP32.
2. Run `Server and Data Plotting/server.py` on the PC.
3. Drive the vehicle using the programmed PWM excitation profile.
4. Save the received data as CSV.
5. Run `Identification.m` to compute velocity and estimate model parameters.

## Key Model

The identified velocity model has the form:

```matlab
v(k+1) = alpha*v(k) + beta*u(k) + gamma
```

where:

- `v` is relative velocity computed from distance,
- `u` is PWM shift relative to `PWM_ZERO`,
- `alpha`, `beta`, and `gamma` are fitted from experiment data.

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `Identification/` | ESP32 identification firmware. |
| `Server and Data Plotting/` | TCP logger, recorded data, and MATLAB identification script. |

## Role In The Project

This section connects physical experiments to model-based control. The fitted model parameters are used in the Online MPC and Tube MPC controllers.

