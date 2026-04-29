#include <WiFi.h>
#include <ESP32Servo.h>
#include <Arduino.h>
#include <math.h>

// =============================
// WIFI
// =============================
const char* ssid = "wifim";
const char* password = "12345678";
const char* host = "10.85.168.12";
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

int currentPWMLeft  = PWM_ZERO;
int currentPWMRight = PWM_ZERO;
int commandedPWM    = PWM_ZERO;

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
const unsigned long TICK_INTERVAL = 50;
const unsigned long SEND_INTERVAL = 50;

// =============================
// MEDIAN FILTER N=5
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
// DVOJITA EMA
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

  emaFast = alphaFast * rawDistance + (1.0f - alphaFast) * emaFast;

  float med = medianFilter5(rawDistance);
  emaSlow = alphaSlow * med + (1.0f - alphaSlow) * emaSlow;

  dist_filt = emaSlow;
}

// =============================
// KOMUNIKACIA
// =============================
String rxLine = "";
unsigned long packetCounter = 0;

// =============================
// GLOBAL TIMERS
// =============================
unsigned long t0 = 0;
unsigned long lastTick = 0;
unsigned long lastSend = 0;

// =============================
// FUNKCIE
// =============================
void connectToWiFi();
void connectToServer();
void maintainConnection();
void readServerMessages();
void parseMatlabCommand(const String& line);
void sendPacket(unsigned long now, unsigned long t_ms);
void applyReceivedCommand();

// =============================
// SETUP
// =============================
void setup() {
  Serial.begin(115200);

  escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
  escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

  escLeft.writeMicroseconds(ESC_MIN);
  escRight.writeMicroseconds(ESC_MIN);
  delay(2000);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  connectToWiFi();
  connectToServer();

  escLeft.writeMicroseconds(currentPWMLeft);
  escRight.writeMicroseconds(currentPWMRight);

  t0 = millis();
  lastTick = t0;
  lastSend = t0;
}

// =============================
// LOOP
// =============================
void loop() {
  unsigned long now = millis();
  unsigned long t_ms = now - t0;

  maintainConnection();
  readServerMessages();

  if (now - lastTick >= TICK_INTERVAL) {
    lastTick = now;

    float dist_raw = readDistanceCM();
    last_dist_raw = dist_raw;
    updateDistanceFiltering(dist_raw);
  }

  if (now - lastSend >= SEND_INTERVAL) {
    lastSend = now;
    sendPacket(now, t_ms);
  }
}

// =============================
// WIFI CONNECT
// =============================
void connectToWiFi() {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(200);
  }
}

// =============================
// TCP CONNECT
// =============================
void connectToServer() {
  while (!client.connect(host, port)) {
    delay(500);
  }

  client.setTimeout(5);
  rxLine = "";
}

// =============================
// CONNECTION MAINTENANCE
// =============================
void maintainConnection() {
  if (WiFi.status() != WL_CONNECTED) {
    connectToWiFi();
  }

  if (!client.connected()) {
    client.stop();
    connectToServer();

    unsigned long now = millis();
    lastTick = now;
    lastSend = now;
  }
}

// =============================
// CITANIE ODPOVEDE Z MATLABu
// ocakavany format: u=1170
// =============================
void readServerMessages() {
  while (client.available()) {
    char c = (char)client.read();

    if (c == '\r') continue;

    if (c == '\n') {
      rxLine.trim();

      if (rxLine.length() > 0) {
        parseMatlabCommand(rxLine);
      }

      rxLine = "";
    } else {
      rxLine += c;
    }
  }
}

// =============================
// PARSER MATLAB PRIKAZU
// =============================
void parseMatlabCommand(const String& line) {
  Serial.print("RX MATLAB: ");
  Serial.println(line);

  String valueStr = line;
  valueStr.replace("u=", "");
  valueStr.trim();

  commandedPWM = valueStr.toInt();
  applyReceivedCommand();

  Serial.print("APPLIED PWM: ");
  Serial.println(commandedPWM);
}

// =============================
// ODOSLANIE PACKETU DO MATLABu
// =============================
void sendPacket(unsigned long now, unsigned long t_ms) {
  packetCounter++;

  client.printf(
    "K=%lu,TIME=%lu,TEXP=%lu,PWM=%d,DIST_RAW=%.2f,DIST_FILT=%.2f\n",
    packetCounter,
    now,
    t_ms,
    currentPWMLeft,
    last_dist_raw,
    dist_filt
  );
}

// =============================
// APLIKACIA PRIJATEHO PRIKAZU
// =============================
void applyReceivedCommand() {
  currentPWMLeft  = commandedPWM;
  currentPWMRight = commandedPWM;

  escLeft.writeMicroseconds(currentPWMLeft);
  escRight.writeMicroseconds(currentPWMRight);
}