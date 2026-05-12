# Software Implementation

This section contains the first ESP32 programs used to bring up the tracked vehicle hardware. The code here verifies WiFi availability, ESC arming, motor actuation, TCP communication, and ultrasonic distance measurement before closed-loop control is introduced.

## Workflow

1. Use `Networkscan/` to confirm that the ESP32 can see the required WiFi network.
2. Use `Motor_calibration/` to verify ESC arming and motor response.
3. Use `Motor_logging/` to test TCP communication while sending PWM values.
4. Use `Motor_logging_distance/` to add HC-SR04 distance measurement to the logging pipeline.

## Folder Overview

| Folder | Purpose |
| --- | --- |
| `Networkscan/` | WiFi scan sketch and a minimal TCP server for communication testing. |
| `Motor_calibration/` | Basic fixed-PWM motor test for ESC and motor verification. |
| `Motor_logging/` | Sends motor PWM data from ESP32 to a PC server. |
| `Motor_logging_distance/` | Sends PWM and ultrasonic distance data from ESP32 to a PC server. |

## Important Configuration

Typical ESP32 hardware connections used in these sketches:

```cpp
const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;
#define TRIG_PIN 5
#define ECHO_PIN 4
```

The communication pattern introduced here is reused in later sections: the ESP32 acts as a TCP client and the PC runs a TCP server for receiving experiment data.

