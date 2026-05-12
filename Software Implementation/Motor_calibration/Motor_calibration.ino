#include <ESP32Servo.h>

// Minimal ESC bring-up sketch used before communication and feedback control.

Servo escLeft, escRight;

// Signal pins from ESP32 to the left and right ESC inputs.
const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;

// Fixed microsecond commands used to verify each motor/ESC channel.
int PWM_TEST = 1190;
int PWM_TEST_2 = 1160; 

void setup() {
  escLeft.attach(ESC_LEFT_PIN);
  escRight.attach(ESC_RIGHT_PIN);

  // Send minimum pulse first so both ESCs complete their arming sequence.
  escLeft.writeMicroseconds(1090);
  escRight.writeMicroseconds(1090);

  delay(3000);

  // Apply constant test commands; no sensor feedback is used in this sketch.
  escLeft.writeMicroseconds(PWM_TEST);
  escRight.writeMicroseconds(PWM_TEST_2);
}

void loop() {
}
