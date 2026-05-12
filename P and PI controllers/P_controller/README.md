# P Controller Firmware

This folder contains the ESP32 implementation of the proportional distance controller.

## File

| File | Description |
| --- | --- |
| `P_controller.ino` | Reads ultrasonic distance, filters it, computes a proportional PWM command, applies it to both tracks, and logs data over TCP. |

## Control Logic

The controller computes distance error as:

```cpp
error = distance - targetDistance;
u = Kp * error;
```

If the vehicle is closer than the target distance, the command returns to `ESC_MIN` to stop forward motion.

## Filtering

The measured distance is smoothed using an exponential moving average:

```cpp
filteredDist = alpha*d + (1.0f - alpha)*filteredDist;
```

## Role In The Project

This is the first closed-loop controller. It verifies that the ESP32 can measure distance, compute a control command, actuate both tracks, and log the result.

