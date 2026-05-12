# Online MPC

This section implements online Model Predictive Control for the tracked vehicle. MATLAB solves the MPC optimization problem during the experiment, while the ESP32 handles sensing and actuation.

## Workflow

1. ESP32 measures and filters distance.
2. ESP32 sends telemetry to MATLAB over TCP.
3. MATLAB estimates velocity from distance.
4. MATLAB solves the MPC problem using the identified model.
5. MATLAB sends an absolute PWM command back to ESP32.
6. ESP32 applies the command to both ESCs.

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `MPC_online/` | ESP32 firmware for online MPC experiments. |
| `Server and functions/` | MATLAB TCP server and MPC computation functions. |
| `Plotting/` | MATLAB plotting scripts and recorded MPC datasets. |

## Important Model

The MPC state is:

```matlab
x = [d; v]
```

where `d` is distance and `v` is relative velocity. The model uses the identified velocity dynamics:

```matlab
v(k+1) = alpha*v(k) + beta*u(k) + gamma
```

## Role In The Project

Online MPC demonstrates constrained model-based control using the measured vehicle model and real-time MATLAB optimization.

