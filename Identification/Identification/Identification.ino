#include <WiFi.h>
#include <ESP32Servo.h>
#include <Arduino.h>
#include <math.h>

// =============================
// WIFI
// =============================
const char* ssid = "wifim";
const char* password = "12345678";
const char* host = "10.236.15.12";
const uint16_t port = 8080;

WiFiClient client;

// =============================
// ESC MOTORY
// =============================
Servo escLeft, escRight;

const int ESC_LEFT_PIN  = 17;
const int ESC_RIGHT_PIN = 18;

const int ESC_MIN = 1090;
const int ESC_MAX = 1700;

const int PWM_ZERO = 1150;

int currentPWMLeft  = ESC_MIN;
int currentPWMRight = ESC_MIN;

// =============================
// ULTRAZVUK (HC-SR04)
// =============================
#define TRIG_PIN 5
#define ECHO_PIN 4

float readDistanceCM() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 25000);
  if (duration == 0) return -1.0f;

  return (duration * 0.0343f / 2.0f);
}

// =============================
// TIMING
// =============================
static const float Ts = 0.05f;
const unsigned long TICK_INTERVAL = 50;
const unsigned long SEND_INTERVAL = 50;

// =============================
// IDENTIFIKAČNÝ PWM PROFIL
// =============================
struct StepCmd {
  uint32_t t_ms;
  int pwm;
};

StepCmd profile[] = {
  {     0, PWM_ZERO },
  {  5000, 1220     }, // skok
  {  7000, PWM_ZERO },
  {  12000, 1220     },  // skok
  {  14000, PWM_ZERO }
};

const int PROFILE_LEN = sizeof(profile) / sizeof(profile[0]);

int pwmFromProfile(uint32_t t_ms) {
  int pwm = profile[0].pwm;
  for (int i = 0; i < PROFILE_LEN; i++) {
    if (t_ms >= profile[i].t_ms) pwm = profile[i].pwm;
    else break;
  }
  return constrain(pwm, ESC_MIN, ESC_MAX);
}

// =============================
// MEDIAN FILTER N
// =============================
#define MEDIAN_N 5
float medianBuf[MEDIAN_N] = {0};
int medianIdx = 0;
bool medianInit = false;

float medianFilter5(float x) {
  if (!medianInit) {
    for (int i = 0; i < MEDIAN_N; i++) medianBuf[i] = x;
    medianIdx = 0;
    medianInit = true;
  }

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
float emaFast = 0.0f;
float emaSlow = 0.0f;
bool emaInit = false;

float alphaFast = 0.3f;
float alphaSlow = 0.05f;

float dist_filt = 0.0f;
float last_dist_raw = -1.0f;

void updateDistanceFiltering(float rawDistance) {
  if (rawDistance <= 0.0f) return;

  if (!emaInit) {
    emaFast = rawDistance;
    emaSlow = rawDistance;
    dist_filt = rawDistance;
    emaInit = true;

    medianInit = false;
    (void)medianFilter5(rawDistance);
    return;
  }

  //EMA FAST
  emaFast = alphaFast * rawDistance + (1.0f - alphaFast) * emaFast;

  //MEDIAN5 + EMA SLOW
  float med = medianFilter5(rawDistance);
  emaSlow = alphaSlow * med + (1.0f - alphaSlow) * emaSlow;

  dist_filt = emaSlow;
}

// =============================
// SETUP
// =============================
void setup() {
  escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
  escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

  // arming
  escLeft.writeMicroseconds(ESC_MIN);
  escRight.writeMicroseconds(ESC_MIN);
  delay(2000);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
  }

  while (!client.connect(host, port)) {
    delay(500);
  }

  currentPWMLeft  = PWM_ZERO;
  currentPWMRight = PWM_ZERO;
  escLeft.writeMicroseconds(currentPWMLeft);
  escRight.writeMicroseconds(currentPWMRight);
  delay(300);
}

// =============================
// LOOP
// =============================
unsigned long t0 = 0;
unsigned long lastTick = 0;
unsigned long lastSend = 0;

void loop() {
  unsigned long now = millis();
  if (t0 == 0) t0 = now;
  uint32_t t_ms = (uint32_t)(now - t0);

  if (now - lastTick >= TICK_INTERVAL) {
    int pwm = pwmFromProfile(t_ms);

    currentPWMLeft  = pwm;
    currentPWMRight = pwm;

    escLeft.writeMicroseconds(currentPWMLeft);
    escRight.writeMicroseconds(currentPWMRight);

    float dist_raw = readDistanceCM();
    last_dist_raw = dist_raw;

    updateDistanceFiltering(dist_raw);

    lastTick = now;
  }

  if (now - lastSend >= SEND_INTERVAL) {
    client.printf(
      "TIME=%lu, TEXP=%lu, PWM=%d, DIST_RAW=%.2f, DIST_FILT=%.2f\n",
      now, (unsigned long)t_ms, currentPWMLeft,
      last_dist_raw, dist_filt
    );
    lastSend = now;
  }
}