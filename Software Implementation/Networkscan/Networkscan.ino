#include "WiFi.h"

// Utility sketch for selecting a usable WiFi network before TCP experiments.

void setup(){
  Serial.begin(115200);
  Serial.println("Scanning available WiFi networks...");
  // WiFi.scanNetworks returns the number of visible access points.
  int n = WiFi.scanNetworks();
  Serial.println("Scan done!");
  if (n == 0) {
    Serial.println("No networks found!");
  } else {
    for (int i = 0; i < n; ++i) {
      // RSSI helps choose the strongest nearby network for reliable control logs.
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
