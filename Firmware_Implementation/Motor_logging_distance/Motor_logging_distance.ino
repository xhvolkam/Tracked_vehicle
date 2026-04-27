#include <WiFi.h>
#include <ESP32Servo.h>

// =============================
// WIFI KONFIG
// =============================
const char* ssid = "wifim";
const char* password = "12345678";
const char* host = "10.171.33.12";
const uint16_t port = 8080;

WiFiClient client;

// =============================
// ESC MOTORY
// =============================
Servo escLeft, escRight;

const int ESC_LEFT_PIN = 17;
const int ESC_RIGHT_PIN = 18;

const int ESC_MIN = 1090;
const int ESC_MAX = 1700;
const int ESC_RUN = 1200;

int currentPWMLeft = ESC_RUN;
int currentPWMRight = ESC_RUN;

// =============================
// HC-SR04
// =============================
#define TRIG_PIN 5
#define ECHO_PIN 4

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

// =============================
// SETUP
// =============================
void setup() {
  delay(500);

  // ---- Motory ----
  escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
  escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

  escLeft.writeMicroseconds(ESC_MIN);
  escRight.writeMicroseconds(ESC_MIN);
  delay(3000);

  escLeft.writeMicroseconds(ESC_RUN);
  escRight.writeMicroseconds(ESC_RUN);

  // ---- Ultrazvuk ----
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  // ---- WiFi ----
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
  }

  // ---- Server ----
  if (!client.connect(host, port)) {
    while (true) delay(1000);
  }
}

// =============================
// LOOP
// =============================
unsigned long lastSent = 0;
const unsigned long SEND_INTERVAL = 2000;

void loop() {
  unsigned long now = millis();

  if (now - lastSent >= SEND_INTERVAL) {

    float dist = readDistanceCM();

    client.printf("TIME=%lu, LEFT_PWM=%d, RIGHT_PWM=%d, DIST=%.2f cm\n",
                  now, currentPWMLeft, currentPWMRight, dist);

    lastSent = now;
  }

  delay(5);
}