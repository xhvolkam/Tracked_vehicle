# Model Predictive Control

This section contains the MATLAB-based MPC implementations for distance regulation of the tracked vehicle.

## Section Purpose

MPC uses the identified vehicle model to predict future behavior and compute constrained PWM commands. The ESP32 handles sensing, filtering, communication, and actuation. MATLAB performs the high-level optimization and sends the PWM command back to the vehicle.

## Main Workflow

```text
ESP32 distance measurement
-> filtering
-> TCP telemetry packet
-> MATLAB state estimation
-> MPC optimization
-> PWM command reply
-> ESP32 motor actuation
-> CSV logging and plotting
```

## Subfolder Overview

| Folder | Important Files | Purpose |
| --- | --- | --- |
| `Online MPC/MPC_online/` | `MPC_online.ino` | ESP32 firmware for measurement, filtering, TCP communication, and applying MATLAB PWM commands. |
| `Online MPC/Server and functions/` | `main.m`, `computeMPC2.m`, `parseEspPacketV1.m`, `sendReplyV1.m` | MATLAB TCP server and Online MPC computation. |
| `Online MPC/Plotting/` | `graphs_ploting.m`, `plotMPC_*.m`, CSV files | Plots Online MPC states, outputs, inputs, and constraints. |
| `Tube MPC/Server and functions/` | `main_tcp_server.m`, `buildTubeMPC_simple.m`, `computeMPC2_tube_simple.m` | MATLAB Tube MPC server and robust controller implementation. |
| `Tube MPC/Plotting/` | `graphs_ploting.m`, `plotMPC_*.m`, `Tube_MPC.csv` | Plots Tube MPC experiment results. |

## Online MPC

Online MPC solves the optimization problem during each control step.

The state is:

```matlab
x = [d; v]
```

where:

- `d` is distance to the obstacle,
- `v` is relative velocity estimated from distance.

The model uses the identified velocity dynamics:

```matlab
v(k+1) = alpha*v(k) + beta*u(k) + gamma
```

The optimization includes:

- distance and velocity constraints,
- input constraints,
- delta-input constraints for smoother PWM changes,
- hard safety distance,
- soft safety distance with slack variables,
- reference tracking cost.

Only the first optimized input is applied. The full sequence is recomputed at the next sample.

## Tube MPC

Tube MPC adds robustness by considering bounded disturbances and model uncertainty. The controller is built before the ESP32 connects, then evaluated during the experiment.

Tube MPC uses deviation coordinates:

```matlab
x_ref = [50; 0]
z = x - x_ref = [d - 50; v]
```

The Tube MPC implementation includes:

- bounded disturbance model,
- state and input constraints,
- delta-input constraints,
- quadratic penalties on state and input,
- controller warm-up before the real-time loop.

## ESP32 Communication

The ESP32 sends telemetry packets:

```text
K=<n>,TIME=<ms>,TEXP=<ms>,PWM=<us>,DIST_RAW=<cm>,DIST_FILT=<cm>
```

MATLAB replies with:

```text
u=<PWM>
```

`K` is a packet counter used to detect missing samples. `DIST_FILT` is used for control, while `DIST_RAW` is logged for diagnostics.

## Plotting

The plotting scripts load recorded CSV files and display:

- PWM input trajectory,
- distance output and reference,
- filtered velocity state,
- input and state constraints,
- full experiment summaries.

## Role In The Project

This is the advanced control section of the repository. It demonstrates how the identified model is used for constrained optimal control and provides the foundation for future improvements in robust control, model accuracy, and real-time implementation.

