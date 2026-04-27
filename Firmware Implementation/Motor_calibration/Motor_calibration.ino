#include <ESP32Servo.h>

Servo escLeft, escRight;

const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;

int PWM_TEST = 1190;
int PWM_TEST_2 = 1160; 

void setup() {
  escLeft.attach(ESC_LEFT_PIN);
  escRight.attach(ESC_RIGHT_PIN);

  escLeft.writeMicroseconds(1090);
  escRight.writeMicroseconds(1090);

  delay(3000);

  escLeft.writeMicroseconds(PWM_TEST);
  escRight.writeMicroseconds(PWM_TEST_2);
}

void loop() {
}
