---
title: "Home Assistant UPS Mk2 Software Part 1"
date: 2026-11-11
draft: false
categories:
  - arduino
---

## Determining the Battery State of Charge (SOC)

![Lead Acid Battery Voltage vs SOC](/images/HA-UPS-mk2/LeadAcidBatteryVoltageVsSOC.png)

The voltage of a lead acid battery vs the SOC can be approximated to a straight line. This isn't completely accurate especially at the extremes (0% and 100%) but it's close enough. Especially given that batteries vary, the voltage can't be measured 100% accurately and it's a really bad idea to run a lead-acid battery down to 0% (which is about 10.5V). So the following equation gives quite a good approximation of the battery voltage (at rest):

$$
v_b = \frac{soc}{64} + 11.3
$$

This can be rearranged to get the state of charge given the voltage:

$$
soc (\%) = (v_b - 11.3) * 64
$$

It should be noted that this value is only valid if the battery has been at rest (not charging or discharging) for several hours.

Lead acid batteries lose about 3% - 5% of their charge a month. For a 4Ah battery that equates to a constant discharge current of about 277uA. I also measured 120uA through the UPS circuit (when M5 is on, which it should be to ensure that the battery takes over immediately if there is a power cut). So the battery will lose about 25% of it's charge every 3 months. Charging the battery every month would seem like a good idea (maybe at 30mA for 10 hours).

The entire software solution [is on GitHub](https://github.com/codewrite/HomeAssistant-UPS-PIO).
