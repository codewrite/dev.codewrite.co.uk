---
title: "Home Assistant UPS Mk2 Testing Part 1"
date: 2026-10-23
draft: false
categories:
  - arduino
---

This was my test setup:

![HA UPS Mk2 Test Setup 1](/images/HA-UPS-mk2/HA-UPS-Test-Setup-1.jpg)

The only thing I wasn't testing was the Raspberry Pi voltage. This left input voltage and current and battery voltage and current, from which I could work out things like efficiency and estimated run time.

I had 4 lead acid batteries that I got from a radio club junk sale. Three were 4Ah and one was 800mAh. I tried that first. Under load the voltage dropped considerably. It was clear that the battery had degraded, so I decided not to use it.

That left the three 4Ah batteries. The loads consisted of 13 ohm resistors in parallel. I made two types, one with five resistors:

![HA UPS Mk2 5 Resistors](/images/HA-UPS-mk2/Resistors-13Ohm-x5.jpg)

This gave a resistance of 2.6 ohms. The other was two resistors:

![HA UPS Mk2 2 Resistors](/images/HA-UPS-mk2/Resistors-13Ohm-x2.jpg)

This gave a resistance of 6.5 ohms, which connected to 5.2V would draw a current of about 770mA.

|              | Input | Output |
| ------------ | ----- | ------ |
| Voltage (V)  |  15   |  5.15  |
| Current (mA) |  746  |  1590  |
| Power (W)    | 11.19 |  8.19  |

The current on the 5V side was slightly reduced due to the voltage drop across the ammeter. Dividing the output power by the input power gave an efficiency of 73%. The LM2596 case temperature (most of the 3W dissipation) was 78°C (ambient 23°C). When I increased the load current to 1.8A the temperature went up to 90°C. The documentation stated that there was a 6°C difference between junction temperature and case temperature (3W*2°C/W). The maximum junction temperature was stated as 150°C. The ambient temperature could easily be 20°C higher, so we are getting close to the safe limit. To be fair, the description on Aliexpress does say that 2A is the safe limit, and if running continuously above this a heatsink is recommended.

A quick internet search revealed that the LM2596 was probably not a genuine chip (Texas Instruments or National Semiconductor). The general consensus seemed to be that the "fake" ones were ok to use, but just not anywhere near the official 3A rating.

I measured the voltage drop across the supply MOSFET. This was 49.3mV which gives a 37mW power dissipation.

With a few changes to the software, I made it keep a running total of the current drawn (in mAh). I ran this for a few hours, and this is the data I collected:

|   Time   | Voltage  |	Current  |  mAh     |
| -------- | -------- | -------- | -------- | 
| 12:10:29 |  12.521  |  406.0	 |      0.1 |
| 12:25:28 |  12.114  |  418.5	 |    104.3 |
| 12:40:28 |  12.072  |  419.8	 |    209.2 |
| 12:55:27 |  12.064  |  420.1	 |    314.2 |
| 13:10:27 |  12.056  |  418.8	 |    419.1 |
| 13:25:27 |  12.036  |  419.1	 |    523.9 |
| 13:40:26 |  12.016  |  419.9	 |    628.7 |
| 13:55:26 |  11.990  |  418.5	 |    733.5 |
| 14:10:25 |  11.960  |  418.7	 |    838.1 |
| 14:25:25 |  11.928  |  418.9	 |    942.8 |
| 14:40:25 |  11.894  |  420.1	 |   1047.7 |
| 14:55:24 |  11.856  |  420.9	 |   1152.9 |
| 15:10:24 |  11.822  |  422.1	 |   1258.6 |
| 15:25:23 |  11.784  |  423.2	 |   1364.3 |
| 15:40:23 |  11.744  |  424.5	 |   1470.1 |

At a C/10 discharge rate The battery should be capable of delivering 3Ah. I didn't test this fully (deep discharge is very bad for lead acid batteries) but it does seem to hold quite a large capacity.

I checked the current draw from the battery when the supply was disconnected. At 12.7V and no load (i.e. Raspberry Pi powered down - sp0 and sb0) the current was  16mA. This is equivalent to about 10% of the battery charge per day.