# PI Controller Firmware

This folder contains the ESP32 implementation of the proportional-integral distance controller.

## File

| File | Description |
| --- | --- |
| `PI_controller.ino` | Implements PI distance control with median filtering, double EMA filtering, feedforward correction, safety stop logic, and TCP logging. |

## Control Logic

The controller uses:

```cpp
u = Kp*error + Ki*integralError;
```

The integral term reduces steady-state error. The integral value is constrained to reduce windup.

## Filtering And Feedforward

- Median filter removes short ultrasonic outliers.
- Slow EMA provides the main feedback distance.
- Fast EMA tracks rapid distance changes.
- The fast/slow difference is added as a simple feedforward term.

## Safety Logic

If the filtered distance is too small, the controller resets the integral term and commands `ESC_MIN`.

## Role In The Project

This is the most complete local ESP32 feedback controller. It prepares the project for MPC by validating filtering, safety handling, and closed-loop distance response.

