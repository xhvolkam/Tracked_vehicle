# P and PI Controller Implementation

This section describes the implementation of basic control strategies used for distance regulation of the tracked vehicle.

The controllers operate directly on the measured distance from the ultrasonic sensor and generate a PWM signal for the motors.
The development follows a progressive approach, where each step extends the functionality of the previous one.

---

## Distance Measurement and Filtering

The raw distance signal obtained from the ultrasonic sensor is noisy and unsuitable for direct control.
Therefore, filtering is introduced before applying any control law.

### Exponential Moving Average (EMA)

A simple EMA filter is used for basic smoothing of the measured signal:

```cpp
ema = alpha * distance + (1.0f - alpha) * ema;
```

---

## Proportional (P) Controller

The P controller introduces the first feedback control law based on the distance error:

```cpp
float error = distance - targetDistance;
float u = Kp * error;
int pwm = ESC_MIN + (int)u;
```

This controller reacts directly to the current error but may result in steady-state offset.

---

## Improved Filtering and Feedforward

To improve signal quality, a combination of median filtering and double EMA filtering is used.

* Median filter removes outliers
* Slow EMA smooths the signal
* Fast EMA captures rapid changes

```cpp
float med = medianFilter(distance);
emaSlow = alphaSlow * med + (1.0f - alphaSlow) * emaSlow;
emaFast = alphaFast * distance + (1.0f - alphaFast) * emaFast;
```

A feedforward term is added based on the difference between fast and slow filtered signals:

```cpp
u += Kff * (emaFast - emaSlow);
```

This improves responsiveness to dynamic changes.

---

## Proportional-Integral (PI) Controller

The PI controller extends the P controller by adding an integral component:

```cpp
float error = dist - targetDistance;
integralError += error * Ts;

float u = Kp * error + Ki * integralError;
int pwm = ESC_MIN + (int)u;
```

The integral term helps eliminate steady-state error and improves tracking accuracy.

---

## Data Logging and Visualization

Measured data and visualization scripts are available in the [Server Data]/(Server and Data Plotting/) folder.

This part of the project contains recorded experimental data together with the MATLAB script `Plotting.m`, which is used for generating plots and analyzing controller performance.

---
