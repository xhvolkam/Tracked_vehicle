# Motor Calibration

This folder contains the first motor and ESC bring-up sketch.

## File

| File | Description |
| --- | --- |
| `Motor_calibration.ino` | Arms both ESCs and applies fixed PWM commands to verify motor wiring, direction, and response. |

## Implementation Notes

The sketch sends a low PWM value first so the ESCs can arm, waits for the arming delay, and then sends fixed test commands to the two motor channels.

Key hardware signals:

```cpp
const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;
```

## Role In The Project

This is part of the actuation layer. Use it before any control experiment to confirm that both tracks respond correctly to ESP32 PWM signals.

