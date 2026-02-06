---
title: "Arduino Default Libraries"
date: 2020-08-14
draft: false
categories:
  - arduino
  - libraries
---

I used to think that the default libraries in the Arduino IDE would be the best available but having come across a couple of cases where this isn't true I would definitely search for better lib libraries now...

## What libraries?

What am I talking about? Well the two that have better alternatives are:

### Keyboard

The reason why this didn't work for me was because the BIOS on my desktop PC didn't recognize the Arduino Leonardo as a keyboard. So I tried [the HID project][HID-Project] - which works flawlessly.

### SD

This didn't seem to work very well for me, so I tried [SdFat][SDFat]. That worked much better. I guess I can understand that the Arduino people don't want to break things by replacing SD with SDFat, but I think they should mention SDFat on [their reference page][Arduino-SD].

I noticed that SDFat has a lot more stars than SD - which I guess is a big clue as to which one is better:

![SDLibStars](/images/ArduinoLibraries/SDvsSdFat.png)

## References (websites)

- [Arduino Library List][Arduio-Libraries]
- [Built In Libraries][Built-in-libraries]


[//]: # (# -------------)
[//]: # (#  References)
[//]: # (# -------------)

[HID-Project]: https://www.arduinolibraries.info/libraries/hid-project
[SDFat]: https://www.arduinolibraries.info/libraries/sd-fat
[Arduino-SD]: https://www.arduino.cc/en/Reference/SD
[Arduio-Libraries]: https://www.arduinolibraries.info/
[Built-in-libraries]: https://www.arduino.cc/en/reference/libraries

