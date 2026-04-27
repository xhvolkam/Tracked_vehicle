#include <WiFi.h>
#include <ESP32Servo.h>

// =============================
// WIFI
// =============================
const char* ssid = "wifim";
const char* password = "12345678";
const char* host = "10.113.66.12";
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

int currentPWMLeft  = ESC_MIN;
int currentPWMRight = ESC_MIN;

// =============================
// ULTRAZVUK
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
  if (duration == 0) return -1;

  return (duration * 0.0343f / 2.0f);
}

// =============================
// REGULÁTOR
// =============================
float targetDistance = 50.0f;

float Kp = 1.1f;
float Ki = 0.2f;

float integralError = 0.0f;
float Ts = 0.02f;   // 20 ms

// =============================
// MEDIAN FILTER
// =============================
#define MEDIAN_N 5
float medianBuf[MEDIAN_N] = {0};
int medianIdx = 0;

float medianFilter(float x) {
  medianBuf[medianIdx++] = x;
  if (medianIdx >= MEDIAN_N) medianIdx = 0;

  float temp[MEDIAN_N];
  memcpy(temp, medianBuf, sizeof(temp));

  for (int i = 0; i < MEDIAN_N - 1; i++) {
    for (int j = i + 1; j < MEDIAN_N; j++) {
      if (temp[j] < temp[i]) {
        float t = temp[i];
        temp[i] = temp[j];
        temp[j] = t;
      }
    }
  }

  return temp[MEDIAN_N / 2];
}

// =============================
// DVOJITÁ EMA
// =============================
float emaFast = 0.0f;   // rýchly signál (feedforward)
float emaSlow = 0.0f;   // hlavný PI signál
float dist = 0.0f;

float alphaFast = 0.3f;
float alphaSlow = 0.05f;

// =============================
// PI REGULÁTOR
// =============================
int computePWM(float rawDistance) {

  if (rawDistance <= 0) return ESC_MIN;

  // --- EMA FAST ---
  emaFast = alphaFast * rawDistance + (1.0f - alphaFast) * emaFast;

  // --- MEDIAN + EMA SLOW ---
  float med = medianFilter(rawDistance);
  emaSlow = alphaSlow * med + (1.0f - alphaSlow) * emaSlow;

  // === REGULAČNÁ VZDIALENOSŤ ===
  dist = emaSlow;

  float error = dist - targetDistance;

  // --- INTEGRÁL ---
  integralError += error * Ts;
  integralError = constrain(integralError, -150.0f, 150.0f);

  // --- PI výpočet ---
  float u = Kp * error + Ki * integralError;

  // --- EMA FAST ako feedforward ---
  float Kff = 0.2f;                // doladiteľné
  u += Kff * (emaFast - emaSlow);

  int pwm = ESC_MIN + (int)u;

  // --- SAFETY ---
  if (dist < 35.0f) {
    integralError = 0.0f;
    return ESC_MIN;
  }

  return pwm;
}

// =============================
// SETUP
// =============================
void setup() {
  escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
  escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

  escLeft.writeMicroseconds(ESC_MIN);
  escRight.writeMicroseconds(ESC_MIN);
  delay(3000);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
  }

  while (!client.connect(host, port)) {
    delay(500);
  }
}

// =============================
// LOOP
// =============================
unsigned long lastPWMUpdate = 0;
unsigned long lastSend = 0;

const unsigned long PWM_INTERVAL = 20;
const unsigned long SEND_INTERVAL = 20;

void loop() {
  unsigned long now = millis();

  float raw = readDistanceCM();

  // --- REGULÁCIA ---
  if (now - lastPWMUpdate >= PWM_INTERVAL) {
    int pwm = computePWM(raw);

    currentPWMLeft  = pwm;
    currentPWMRight = pwm;

    escLeft.writeMicroseconds(currentPWMLeft);
    escRight.writeMicroseconds(currentPWMRight);

    lastPWMUpdate = now;
  }

  // --- LOGGING ---
  if (now - lastSend >= SEND_INTERVAL) {
    client.printf("TIME=%lu, PWM_LEFT=%d, PWM_RIGHT=%d, DIST=%.2f\n",
                  now, currentPWMLeft, currentPWMRight, dist);
    lastSend = now;
  }
}
