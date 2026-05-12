# Online MPC Server And Functions

This folder contains the MATLAB server and helper functions used to run Online MPC.

## Files

| File | Description |
| --- | --- |
| `main.m` | Main MATLAB TCP server loop. Receives ESP32 packets, computes MPC commands, sends replies, and logs data. |
| `computeMPC2.m` | Builds and evaluates the YALMIP MPC optimization problem. |
| `computeTestControlV1.m` | Simple test controller for checking communication without MPC. |
| `parseEspPacketV1.m` | Parses ESP32 telemetry packets into MATLAB fields. |
| `sendReplyV1.m` | Sends the computed PWM command back to ESP32. |
| `waitForClient.m` | Waits for ESP32 TCP connection. |

## MPC Computation

The optimization includes:

- state constraints on distance and velocity,
- input constraints on PWM shift,
- delta-input constraints for smooth commands,
- hard safety distance,
- soft safety distance using slack variables,
- reference tracking objective.

The first input of the optimized sequence is applied, then the problem is solved again at the next sample.

## Role In The Project

This folder is the high-level controller implementation for Online MPC. It closes the loop between ESP32 measurements and MATLAB optimization.

