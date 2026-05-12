# Controller Server And Data Plotting

This folder contains PC-side tools and datasets for P and PI controller experiments.

## Files

| File | Description |
| --- | --- |
| `server.py` | TCP logger that receives ESP32 controller packets and stores them as CSV rows. |
| `Plotting.m` | MATLAB script for plotting PWM and distance response from a selected CSV file. |
| `1_raw_distance.csv` | Raw ultrasonic distance measurement log. |
| `2_filtered_distance.csv` | Filtered distance measurement log. |
| `3_P_unfiltered.csv` | P controller experiment without filtering. |
| `4_P_filtered.csv` | P controller experiment with filtering. |
| `5_PI_unfiltered.csv` | PI controller experiment without filtering. |
| `6_PI_filtered.csv` | PI controller experiment with filtering. |

## Data Flow

```text
ESP32 controller firmware -> TCP packet -> server.py -> CSV file -> Plotting.m
```

Expected packet fields:

```text
TIME=<ms>, PWM_LEFT=<us>, PWM_RIGHT=<us>, DIST=<cm>
```

## Role In The Project

This folder stores and visualizes closed-loop controller experiments. It is useful for comparing filtering strategies and controller performance before moving to MPC.

