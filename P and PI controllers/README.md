# P And PI Controllers

This section contains classical feedback controllers for distance regulation of the tracked vehicle. These controllers validate sensing, filtering, actuation, and data logging before MPC is introduced.

## Section Purpose

The P and PI controllers run directly on the ESP32. Unlike MPC, the control command is computed locally on the vehicle instead of in MATLAB.

## Subfolder Overview

| Folder | Important Files | Purpose |
| --- | --- | --- |
| `P_controller/` | `P_controller.ino` | Proportional distance controller using filtered ultrasonic distance. |
| `PI_controller/` | `PI_controller.ino` | PI controller with median filtering, double EMA filtering, feedforward support, and safety logic. |
| `Server and Data Plotting/` | `server.py`, `Plotting.m`, CSV files | TCP logger, recorded experiments, and MATLAB plotting. |

## Control Workflow

```text
HC-SR04 distance
-> filtering
-> distance error
-> P/PI control law
-> PWM command
-> ESCs and motors
-> TCP logging
```

The target distance used in the controller experiments is typically:

```cpp
float targetDistance = 50.0f;
```

## P Controller

The proportional controller computes:

```cpp
error = distance - targetDistance;
u = Kp * error;
```

If the vehicle is closer than the target distance, the PWM command is returned to the stop/minimum value.

## PI Controller

The PI controller extends the P controller with an integral term:

```cpp
u = Kp*error + Ki*integralError;
```

The integral term reduces steady-state error. The implementation constrains the integral value to reduce windup.

## Filtering

Filtering is important because the ultrasonic sensor can produce noisy or invalid samples.

Implemented filtering methods:

- EMA filtering in the P controller,
- median filtering in the PI controller,
- slow EMA for the main feedback signal,
- fast EMA for detecting rapid distance changes,
- feedforward based on the fast/slow EMA difference.

## Logging And Plotting

The ESP32 sends controller data to `server.py`:

```text
TIME=<ms>, PWM_LEFT=<us>, PWM_RIGHT=<us>, DIST=<cm>
```

The recorded CSV files are plotted using `Plotting.m` to compare:

- raw and filtered distance,
- P and PI controller behavior,
- filtered and unfiltered experiments.

## Role In The Project

This section is the practical bridge between open-loop testing and model-based control. It confirms that the vehicle can regulate distance before the MATLAB MPC controller is used.

