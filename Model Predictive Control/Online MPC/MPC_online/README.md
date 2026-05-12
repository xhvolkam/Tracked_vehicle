# Online MPC Firmware

This folder contains the ESP32 firmware used with the MATLAB Online MPC server.

## File

| File | Description |
| --- | --- |
| `MPC_online.ino` | Measures distance, filters it, sends telemetry packets to MATLAB, receives `u=<PWM>` commands, and applies them to both ESCs. |

## Firmware Responsibilities

- Read HC-SR04 distance.
- Reject invalid distance samples.
- Apply median filtering and double EMA filtering.
- Maintain TCP connection with MATLAB.
- Send telemetry packets with packet counter, time, PWM, raw distance, and filtered distance.
- Parse MATLAB PWM replies.
- Apply the received PWM command equally to both tracks.

## Packet Format

ESP32 sends:

```text
K=<n>,TIME=<ms>,TEXP=<ms>,PWM=<us>,DIST_RAW=<cm>,DIST_FILT=<cm>
```

MATLAB replies:

```text
u=<PWM>
```

## Role In The Project

This firmware is the hardware interface for Online MPC. It does not solve MPC locally; it provides measurements and executes the MATLAB-computed command.

