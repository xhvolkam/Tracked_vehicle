# System Identification

This section describes the process of identifying a dynamic model of the tracked vehicle based on experimental data.

The goal is to determine parameters of a discrete-time model that describes the relationship between the control input (PWM) and the system behavior (distance and relative motion).

---

## Input Excitation – PWM Profile

To properly identify the system, the vehicle is using a predefined PWM input profile implemented in the [Identification.ino](Identification/Identification.ino) code.
The PWM signal is not constant, but changes in steps over time in order to sufficiently excite the system dynamics:

```cpp
int pwm;

if (t < 2000)        pwm = 1150;
else if (t < 4000)   pwm = 1200;
else if (t < 6000)   pwm = 1300;
else if (t < 8000)   pwm = 1400;
else                 pwm = 1200;
```

This approach ensures that the system is stimulated over a range of operating conditions, which is necessary for reliable identification.

## Data Processing and Identification

The identification itself is performed in MATLAB using the script [Identification.m](Server%20and%20Data%20Plotting/Identification.m)

The key step is the computation of relative velocity from the measured distance:

```matlab
v(k) = (d(k-1) - d(k)) / Ts;
```

Based on this, a discrete-time model is formulated:

```matlab
v(k+1) = alpha * v(k) + beta * u(k) + gamma;
```

where:

* `alpha` represents system inertia
* `beta` represents input gain
* `gamma` captures steady-state bias

The parameters `alpha`, `beta`, and `gamma` are estimated directly from measured data using least-squares methods.

## Visualization

The MATLAB script also provides visualization of measured signals and identified behavior.

This includes:

* input PWM signal
* measured distance
* computed velocity

These plots are used to validate the quality of the identified model.

## Data Logging

Experimental data are collected using a [Server](Server%20and%20Data%20Plotting/server.py).

The server receives data from the ESP32, parses incoming messages, and stores them into CSV files for further processing and analysis.

