---
title: "Arduino Low Power Encryption"
date: 2020-08-19
draft: false
categories:
  - arduino
  - low
  - power
  - encryption
---

![LowPowerEncryptionBoard](/images/ArduinoLowPowerEncryption/LowPowerEncryptionBoard.jpg)

This was my experiment in creating a low power Arduino that can communicate wirelessly to a Raspberry Pi using an HC-12.
By low power I mean run for a couple of years on a 18650 battery. Encryption should be unhackable by today's standards.

I did a presentation for the Raspberry Pint group, [the video is here](https://www.youtube.com/watch?v=aB-yj1D6h-8&t=164s).

The code is on [my Github repo](https://github.com/codewrite/ArduinoLowPowerWirelessEncryption).
I had to do some mods to the Arduino board to make it low power (removing the regulator and power LED resistor):

![LowPowerMods](/images/ArduinoLowPowerEncryption/ProMiniMods.jpg)

and programing the board is done with a serial borad (search "ftdi usb to serial" in AliExpress):

![SerialBoard](/images/ArduinoLowPowerEncryption/ProMiniAndSerialBoard.jpg)

I worked out that if I send a message every minute the 18650 battery should last well over two years.
With a message every four seconds the battery should last two months or so - I have been testing this, and it has managed three weeks, so I think my calculations are correct.

## References

- [Raspberry Pint Video](https://www.youtube.com/watch?v=aB-yj1D6h-8&t=164s)
- [ArduinoLowPowerWirelessEncryption GitHub](https://github.com/codewrite/ArduinoLowPowerWirelessEncryption)
