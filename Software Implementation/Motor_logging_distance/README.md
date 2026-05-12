# Motor Logging With Distance

This folder adds ultrasonic distance sensing to the open-loop motor logging sketch.

## File

| File | Description |
| --- | --- |
| `Motor_logging_distance.ino` | Sends timestamp, left/right PWM commands, and HC-SR04 distance measurements to the PC over TCP. |

## Sensor Processing

The HC-SR04 measurement is based on echo time:

```cpp
distance = duration * 0.0343 / 2.0;
```

The factor `0.0343` represents the approximate speed of sound in cm/us. Division by two converts round-trip echo time to one-way distance.

## Role In The Project

This section connects the sensing and communication pipeline. It prepares the project for system identification and closed-loop distance control.

