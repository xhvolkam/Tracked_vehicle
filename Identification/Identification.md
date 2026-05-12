# Identification

This section identifies a discrete-time dynamic model of the tracked vehicle from measured experiment data. The identified model is later used by the MPC controllers.

## Section Purpose

The goal is to collect input-output data from the vehicle and estimate a model relating PWM input to relative motion. This connects the physical vehicle to the model-based control part of the project.

## Subfolder Overview

| Folder | Important Files | Purpose |
| --- | --- | --- |
| `Identification/` | `Identification.ino` | ESP32 firmware for applying a PWM excitation profile and sending measured data. |
| `Server and Data Plotting/` | `server.py`, `Identification.m`, `Identification_data.csv` | PC-side TCP logging, MATLAB processing, plotting, and parameter estimation. |

## Experiment Workflow

1. Upload `Identification/Identification.ino` to the ESP32.
2. Run `Server and Data Plotting/server.py` on the PC.
3. The ESP32 applies a predefined PWM step profile to both motors.
4. Distance is measured with the HC-SR04 sensor and filtered.
5. The ESP32 sends PWM, raw distance, and filtered distance over TCP.
6. MATLAB loads the CSV data and estimates the model parameters.

## Data Packet

The ESP32 sends key-value packets in this form:

```text
TIME=<ms>, TEXP=<ms>, PWM=<us>, DIST_RAW=<cm>, DIST_FILT=<cm>
```

`server.py` parses these fields and stores them in CSV format.

## Filtering And Velocity Estimation

The ESP32 firmware uses:

- median filtering to remove short ultrasonic outliers,
- fast EMA for dynamic response observation,
- slow EMA for the filtered distance used in identification.

MATLAB estimates velocity from filtered distance:

```matlab
v(k) = (d(k-1) - d(k)) / Ts;
```

Positive velocity means the measured distance to the obstacle is decreasing.

## Identified Model

The fitted velocity model is:

```matlab
v(k+1) = alpha*v(k) + beta*u(k) + gamma
```

where:

- `v` is relative velocity,
- `u` is PWM shift relative to `PWM_ZERO`,
- `alpha` describes inertia,
- `beta` describes input gain,
- `gamma` captures steady-state bias.

## Role In The Project

This section provides the numerical model used in Online MPC and Tube MPC. Future development should start here if the vehicle hardware changes or if a better model is needed.

