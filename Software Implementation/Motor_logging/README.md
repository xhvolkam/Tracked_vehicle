# Motor Logging

This folder extends the basic motor test with WiFi and TCP logging.

## File

| File | Description |
| --- | --- |
| `Motor_logging.ino` | Arms the ESCs, applies a constant PWM command, connects to a PC TCP server, and periodically sends motor PWM values. |

## Data Flow

```text
ESP32 motor command -> TCP packet -> PC server output
```

The transmitted packet contains timestamp and PWM values:

```text
TIME=<ms>, LEFT_PWM=<us>, RIGHT_PWM=<us>
```

## Role In The Project

This verifies that motor commands can be monitored remotely. The same communication pattern is later used for data logging and MATLAB-based control.

