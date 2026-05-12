# Tube MPC

This section implements robust Tube MPC for the tracked vehicle. Tube MPC uses the same identified vehicle model as Online MPC, but includes bounded disturbances to improve robustness against model mismatch and measurement uncertainty.

## Workflow

1. MATLAB builds the Tube MPC controller before the ESP32 connects.
2. ESP32 sends filtered distance data over TCP.
3. MATLAB estimates velocity and converts the state to deviation coordinates.
4. The Tube MPC controller evaluates the current state and previous input.
5. MATLAB sends a PWM command back to ESP32.
6. Experiment data is logged and plotted.

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `Server and functions/` | MATLAB Tube MPC server and controller functions. |
| `Plotting/` | MATLAB plotting scripts and Tube MPC dataset. |

## Important State Transformation

Tube MPC is formulated around the reference:

```matlab
x_ref = [50; 0]
z = x - x_ref = [d - 50; v]
```

## Role In The Project

This section extends MPC development toward robust constrained control and provides a basis for future work with model uncertainty.

