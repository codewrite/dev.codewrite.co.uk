---
title: "Debugging ESP32 S3 in VS Code"
date: 2026-09-19
draft: false
categories:
  - arduino
---

Debugging is much better than littering your code with print statements for lots of reasons - which I'm not going to go into here. But setting debugging up is not always straightforward.

To make things easier, I use an esp32 s3 board that had JTAG built into it. I found this article on the internet and loosely followed the instructions: [How to use JTAG built-in debugger of the ESP32-S3 in PLATFORMIO](https://community.platformio.org/t/how-to-use-jtag-built-in-debugger-of-the-esp32-s3-in-platformio/36042).

I'm not sure whether using Zadig is required, but I did do that bit.

Also, I did the **ERASE FLASH** step using the following command:

````powershell
pio run --target erase
````

The platformio.ini file looked like this:

````c
[env:esp32-s3-devkitc-1]
platform = espressif32
board = esp32-s3-devkitc-1
framework = arduino
lib_deps = adafruit/Adafruit NeoPixel@^1.15.5

build_type = debug
; Ensure the USB CDC (serial) remains active on boot
;build_flags = 
;    -D ARDUINO_USB_MODE=1
;    -D ARDUINO_USB_CDC_ON_BOOT=1

;upload_speed = 2000000     ;ESP32S3 USB-Serial Converter maximum 2000000bps
;upload_port = COM5
;upload_flags = --erase-all

monitor_speed = 115200
monitor_port = COM4

;debug_tool = esp-builtin
;debug_init_break = break setup
````

I used the Adafruit NeoPixel library to control the S3 multi-colour pixel. The whole main.cpp file looked like this:

````c
#include <Arduino.h>
#include <Adafruit_NeoPixel.h>

#define PIN_NEO_LED   48
#define NUM_NEO_PIXELS 1

Adafruit_NeoPixel strip(NUM_NEO_PIXELS, PIN_NEO_LED, NEO_GRB + NEO_KHZ800);

struct Colour {
  int red; int green; int blue;
};

Colour ColourMap[] =
{
  {6,0,0}, {0,6,0}, {0,0,6}, {3,3,0},
  {3,0,3}, {0,3,3}, {2,2,2}
};

int ColourMap_NumElements = sizeof(ColourMap)/sizeof(ColourMap[0]);

int loopCounter=0;

void setup() {
  // put your setup code here, to run once:
  strip.begin();
  strip.show();
  Serial.begin(115200);
}

void loop() {
  // put your main code here, to run repeatedly:
  for (int j=0; j<ColourMap_NumElements; j++)
  {
    Colour c = ColourMap[j];
    strip.setPixelColor(0, strip.Color(c.red, c.green, c.blue));
    strip.show();
    Serial.print(loopCounter);
    Serial.print(" ");
    loopCounter++;
    delay(1000);
  }
}
````

This was all I needed - I could then set breakpoints, step through the code and inspect variables.