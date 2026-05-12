# Tube MPC Server And Functions

This folder contains the MATLAB implementation of the Tube MPC controller and TCP server.

## Files

| File | Description |
| --- | --- |
| `main_tcp_server.m` | Main MATLAB TCP loop for Tube MPC experiments. |
| `buildTubeMPC_simple.m` | Builds the robust Tube MPC controller using the identified model, constraints, disturbance bounds, and penalties. |
| `computeMPC2_tube_simple.m` | Estimates velocity, converts distance to deviation coordinates, evaluates Tube MPC, and converts the result to PWM. |
| `parseEspPacketV1.m` | Parses ESP32 telemetry packets. |
| `sendReplyV1.m` | Sends `u=<PWM>` command replies to ESP32. |
| `waitForClient.m` | Waits for ESP32 connection. |
| `main_tcp_server.asv` | MATLAB autosave backup of the server script. |

## Tube MPC Elements

The controller uses:

- state vector `z = [d - 50; v]`,
- bounded disturbance model,
- distance and velocity constraints,
- input and delta-input constraints,
- quadratic penalties on state and input.

The controller is built before the real-time loop starts to reduce first-sample delay.

## Role In The Project

This folder contains the robust controller computation layer. It receives vehicle data, evaluates the Tube MPC controller, sends PWM commands, and logs the experiment.

