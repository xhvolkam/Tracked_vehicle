# Identification Server And Data Plotting

This folder contains the PC-side tools for recording and processing identification data.

## Files

| File | Description |
| --- | --- |
| `server.py` | TCP logger that receives ESP32 packets and writes timestamped CSV rows. |
| `Identification.m` | MATLAB script for processing measured data, estimating velocity, plotting signals, and fitting the model. |
| `Identification_data.csv` | Recorded experiment data used for identification. |

## Data Format

The ESP32 sends key-value packets similar to:

```text
TIME=<ms>, TEXP=<ms>, PWM=<us>, DIST_RAW=<cm>, DIST_FILT=<cm>
```

The Python server parses these fields and stores them in CSV format for MATLAB.

## Identification Method

MATLAB computes velocity from filtered distance:

```matlab
v(k) = (d(k-1) - d(k)) / Ts;
```

Then it estimates:

```matlab
v(k+1) = alpha*v(k) + beta*u(k) + gamma
```

using least squares.

## Role In The Project

This folder converts experiment logs into the numerical model used by the MPC controllers.

