# Software Implementation

This section contains the first ESP32 programs used to bring up the tracked vehicle hardware. The code verifies WiFi availability, ESC arming, motor actuation, TCP communication, and ultrasonic distance measurement before feedback control is introduced.

## Section Purpose

This part belongs to the low-level embedded and hardware interface layer of the project. It confirms that the ESP32 can:

- connect to WiFi,
- control both ESCs using PWM,
- communicate with a PC server,
- read the HC-SR04 ultrasonic sensor,
- send simple experiment data over TCP.

## Subfolder Overview

| Folder | Main File | Purpose |
| --- | --- | --- |
| `Networkscan/` | `Networkscan.ino`, `server.py` | Checks visible WiFi networks and verifies basic ESP32-to-PC TCP communication. |
| `Motor_calibration/` | `Motor_calibration.ino` | Arms both ESCs and sends fixed PWM commands to verify motor response. |
| `Motor_logging/` | `Motor_logging.ino` | Sends active motor PWM values from ESP32 to a PC server. |
| `Motor_logging_distance/` | `Motor_logging_distance.ino` | Adds HC-SR04 distance measurement to the motor logging workflow. |

## Implementation Workflow

1. Run the WiFi scan sketch to confirm that the ESP32 can see the intended network.
2. Test ESC arming and motor response with fixed PWM commands.
3. Add TCP logging to confirm that the PC receives ESP32 packets.
4. Add ultrasonic distance measurement and transmit distance together with PWM values.

## Important Configuration

Typical hardware pins used by the ESP32 sketches:

```cpp
const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;
#define TRIG_PIN 5
#define ECHO_PIN 4
```

The HC-SR04 distance calculation uses echo time:

```cpp
distance = duration * 0.0343 / 2.0;
```

The factor `0.0343` is the approximate speed of sound in cm/us. Division by two converts round-trip echo time to one-way distance.

## Communication Flow

```text
ESP32 sketch -> WiFi TCP client -> PC TCP server -> printed/logged data
```

This communication pattern is reused later in identification, P/PI experiments, and MATLAB-based MPC.

