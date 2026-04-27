# Firmware Implementation

This folder contains the firmware developed for the tracked vehicle platform based on ESP32.

The implementation is structured progressively, where each step extends the functionality of the previous one.

---

## Motor Calibration (Motor Control)

The first step focuses on proper ESC initialization and motor control using PWM signals. This code ensures that the motors are correctly armed and respond consistently to control inputs.

Motors are connected to dedicated ESP32 GPIO pins:

```cpp
const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;
```

The PWM signal range is defined together with a default running value. These parameters determine how the ESC interprets the control signal:

```cpp
#include <ESP32Servo.h>

Servo escLeft, escRight;

const int ESC_MIN = 1090;
const int ESC_MAX = 1700;
const int ESC_RUN = 1200;
```

During initialization, the ESCs are first armed using the minimum signal and then switched to a constant running value:

```cpp
escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

escLeft.writeMicroseconds(ESC_MIN);
escRight.writeMicroseconds(ESC_MIN);
delay(3000);

escLeft.writeMicroseconds(ESC_RUN);
escRight.writeMicroseconds(ESC_RUN);
```

---

## Motor Logging (Communication)

The next step extends the system with WiFi communication and data logging. At this stage, the firmware is able to transmit motor-related data to an external server for monitoring and analysis.

The ESP32 connects to a server using a TCP client:

```cpp
#include <WiFi.h>

WiFiClient client;
client.connect(host, port);
```

Basic data (time and PWM values) is sent periodically. This allows observation of motor commands during operation:

```cpp
client.printf("TIME=%lu, LEFT_PWM=%d, RIGHT_PWM=%d, DIST=%.2f cm\n",
              now, currentPWMLeft, currentPWMRight, dist);
```

This stage is used to validate communication and verify that the motor control signals are correctly generated and transmitted.

---

## Sensor Integration (Distance Measurement)

In the final step, the ultrasonic sensor is integrated into the system, extending the firmware with distance measurement capability.

The sensor is connected using two digital pins:

```cpp
#define TRIG_PIN 5
#define ECHO_PIN 4
```

The distance is obtained by triggering the sensor and measuring the duration of the returned echo signal:

```cpp
float readDistanceCM() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);

  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  float distance = duration * 0.0343 / 2.0;

  if (duration == 0) return -1;
  return distance;
}
```

This function provides a simple interface for obtaining the measured distance in centimeters, which can be further used for monitoring or control purposes.

