#include <WiFi.h>
#include <ESP32Servo.h>

// Open-loop motor test with TCP logging of the active PWM commands.

// =============================
// WIFI CONFIG
// =============================
// Host is the PC running the receive server on the same WiFi network.
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
// Constant running command used to validate motor actuation and logging.
const int ESC_RUN = 1200;

int currentPWMLeft = ESC_RUN;
int currentPWMRight = ESC_RUN;

// =============================
// SETUP
// =============================
void setup() {
  delay(500);

  escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
  escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

  // ESCs must see the minimum pulse before accepting a running command.
  escLeft.writeMicroseconds(ESC_MIN);
  escRight.writeMicroseconds(ESC_MIN);
  delay(3000);

  escLeft.writeMicroseconds(ESC_RUN);
  escRight.writeMicroseconds(ESC_RUN);

  // WIFI
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
    // Human-readable key=value packet for the simple Python TCP server.
    client.printf("TIME=%lu, LEFT_PWM=%d, RIGHT_PWM=%d\n",
                  now, currentPWMLeft, currentPWMRight);

    lastSent = now;
  }

  delay(5);
}
