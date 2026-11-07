---
title: "Home Assistant UPS Mk2 Testing Part 1a"
date: 2026-11-06
draft: false
categories:
  - arduino
---

Something I noticed when I connected and disconnected the USB serial port on the Arduino Nano was that the Nano would reset. After a bit of googling it turned out that this was caused by DTR on the CH340 serial chip being connected to the RESET pin (via a capacitor). So although I was powering the Nano from the UPS, when I shut down Home Assistant on the Raspberry Pi, HA would toggle DTR causing the Nano to reset.

A common solution that other people suggested was to connect a 10uF capacitor between RST and GND. I tried this and it worked, but when Home Assistant started up it wasn't able to send serial commands to the Nano (and receiving data seemed a bit unreliable). I assumed that this was because there should have been some sort of handshake between HA and the Nano.

Another approach I tried was to add a 5K pull-up resistor between P2 and 5V. This ensured that the supply stayed on during a reset. The downside to this is that the Nano lost state information - although the only thing that would currently be lost is the battery mAh state. It would mean that I would need to be careful to not store any state information - but that is probably a good programming strategy anyway.
