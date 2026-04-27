#include "WiFi.h"

void setup(){
  Serial.begin(115200);
  Serial.println("Scanning available WiFi networks...");
  int n = WiFi.scanNetworks();
  Serial.println("Scan done!");
  if (n == 0) {
    Serial.println("No networks found!");
  } else {
    for (int i = 0; i < n; ++i) {
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(WiFi.SSID(i));
      Serial.print(" (");
      Serial.print(WiFi.RSSI(i));
      Serial.println(" dBm)");
    }
  }
}

void loop(){}
