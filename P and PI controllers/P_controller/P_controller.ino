  #include <WiFi.h>
  #include <ESP32Servo.h>

  // =============================
  // WIFI
  // =============================
  const char* ssid = "wifim";
  const char* password = "12345678";
  const char* host = "10.139.144.12";
  const uint16_t port = 8080;

  WiFiClient client;

  // =============================
  // ESC MOTORY
  // =============================
  Servo escLeft, escRight;

  const int ESC_LEFT_PIN = 17;
  const int ESC_RIGHT_PIN = 18;

  const int ESC_MIN = 1090;   // neutral / stop
  const int ESC_MAX = 1700;   // maximum throttle

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

    return (duration * 0.0343 / 2.0);
  }

  // =============================
  // ADAPTÍVNY TEMPOMAT – P REGULÁTOR
  // =============================
  float targetDistance = 50.0; 
  float Kp = 1.5;

  int computePWM(float distance) {
    
    if (distance <= 0) return ESC_MIN;

    float error = distance - targetDistance; // cim dalej tym viac musim akcelerovat

    //P control
    float u = Kp * error;

    int pwm = ESC_MIN + (int)u;

    if (distance < targetDistance) {
      return ESC_MIN;
    }

    // Safety saturation
    if (pwm > ESC_MAX) pwm = ESC_MAX;
    if (pwm < ESC_MIN) pwm = ESC_MIN;

    return pwm;
  }

  //=====================
  // FILTER
  //=====================
float filteredDist = 0.0f;
float alpha = 0.15f;  

float processDistance(float d) {

    // Neplatné merania iba preskočíme
    if (d < 0) return filteredDist;

    // EMA: správna forma (silnejšie filtruje)
    filteredDist = alpha * d + (1.0f - alpha) * filteredDist;

    return filteredDist;
}

  // =============================
  // SETUP
  // =============================
  void setup() {
    escLeft.attach(ESC_LEFT_PIN, ESC_MIN, ESC_MAX);
    escRight.attach(ESC_RIGHT_PIN, ESC_MIN, ESC_MAX);

    // ARM ESC
    escLeft.writeMicroseconds(ESC_MIN);
    escRight.writeMicroseconds(ESC_MIN);
    delay(3000);

    pinMode(TRIG_PIN, OUTPUT);
    pinMode(ECHO_PIN, INPUT);

    // WiFi
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED) {
      delay(200);
    }

    // TCP klient
    while (!client.connect(host, port)) {
      delay(500);
    }
  }

  // =============================
  // LOOP – REGULÁCIA + LOGGING
  // =============================
  unsigned long lastPWMUpdate = 0;
  const unsigned long PWM_INTERVAL = 20;

  unsigned long lastSend = 0;
  const unsigned long SEND_INTERVAL = 20;

  void loop() {
    unsigned long now = millis();

    // --- update PWM ---
    if (now - lastPWMUpdate >= PWM_INTERVAL) {

      float raw = readDistanceCM();
      float dist = processDistance(raw); 
      int pwm = computePWM(dist);

      // use same PWM for both motors
      currentPWMLeft  = pwm;
      currentPWMRight = pwm;

      escLeft.writeMicroseconds(currentPWMLeft);
      escRight.writeMicroseconds(currentPWMRight);

      lastPWMUpdate = now;
    }

  // --- send data to server ---
    if (now - lastSend >= SEND_INTERVAL) {

      float raw = readDistanceCM();
      float dist = processDistance(raw);

      client.printf("TIME=%lu, PWM_LEFT=%d, PWM_RIGHT=%d, DIST=%.2f\n",
                    now, currentPWMLeft, currentPWMRight, dist);

      lastSend = now;
    }
  }



