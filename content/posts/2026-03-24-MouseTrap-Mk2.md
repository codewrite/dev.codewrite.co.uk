---
title: "Mouse Trap Mk II"
date: 2026-03-24
draft: false
categories:
  - raspberryPi
  - homeAssistant
---

It turned out that the original 
[mouse trap]({{% ref "2026-03-11-MouseTrap.md" %}})
wasn't sensitive enough. Very small mice just didn't trigger it. So I decided to improve the design.

The case of the trap is clear, so I thought I could have a beam of light going from one side to the other. When the mouse broke the beam, it would trigger a solenoid that would close the door. After some thought, I decided to use a white LED and LDR (so no lasers or signal modulation). The LED was quite bright (even though it was only driven by 5mA) but bright lights don't seem to put the mice off. The LED illuminated the LDR much more than ambient light (except in bright sunlight - but that's not the best conditions to catch mice, and even if it did need to work in sunlight the case could be covered to reduce the ambient light falling on the LDR).

![Mk2 Modifications](/images/HA-MouseTrap2/Modified-MouseTrap.png)

The design I came up with is as follows:

![Mk2 Block Diagram](/images/HA-MouseTrap2/MT2-Block-Diagram.png)


This was my first prototype (using an Arduino Nano):

![Mk2 Prototype](/images/HA-MouseTrap2/MT2-Prototype.jpg)

I decided to use a Raspberry Pi Pico W so that I could control it directly from Home Assistant. I thought about using an ESP32, but based on my experiments, the Pico W ADC was much more accurate - and stable.

Based on this, I came up with this design (in LTSpice):

![Schematic](/images/HA-MouseTrap2/MouseTrap2Schematic.png)

The reason for the capacitor and DC-DC conveter was because I bought a 3V solenoid (which needs 1.3A according to the manufacturer). In my tests the pull wasn't strong enough, so I decided to overdrive it. The DC-DC converter allowed me to provide any voltage I wanted to (up to 40V). I used a 10,000uF 25V capacitor, which proved more than sufficient. I estimated that the activation time was in the order of about 10 - 20 ms, so the capacitor easily held enough charge. The manufacturer suggested not powering the solenoid for more than about 3 seconds - which I worked out was about 5 joules. A 10,000uF capacitor charged to 15V would hold about 1 joule, so well within the manufacturer's limit.

I then worked out how to make this on a bit of Veroboard:

![Veroboard Layout](/images/HA-MouseTrap2/MouseTrap2VeroBoard.png)

The finished version looked like this:

![Finished Unit Left](/images/HA-MouseTrap2/MouseTrap2Left.jpg)

![Finished Unit Right](/images/HA-MouseTrap2/MouseTrap2Right.jpg)

I programmed the Raspberry Pi Pico board with ESPHome. The Yaml for this was as follows:

```yaml
switch:
  - platform: template
    id: MouseTrapEnable
    name: "Mouse Trap Enable"
    optimistic: True
  - platform: template
    id: MouseTrapTriggered
    name: "Mouse Trap Triggered"
    optimistic: True
  - platform: template
    id: MouseTrapTriggerDoor
    name: "Mouse Trap Trigger Door"
    turn_on_action: 
      then:
        - lambda: |-
            id(MouseTrapTriggerDoor).publish_state(true);
            if (id(MouseTrapEnable).state) {
              id(MouseTrapSolenoid).turn_on();
            }
        - delay: 1s
        - switch.turn_off: MouseTrapTriggerDoor
    turn_off_action: 
      then:
        - lambda: 'id(MouseTrapTriggerDoor).publish_state(false);'
  - platform: gpio
    pin: GPIO22
    id: MouseTrapLED
    name: "Mouse Trap LED"
  - platform: gpio
    pin: GPIO20
    id: MouseTrapSolenoid
    on_turn_on:
      then:
        - delay: 100ms
        - switch.turn_off: MouseTrapSolenoid
        - switch.turn_on: MouseTrapTriggered
binary_sensor:
  - platform: gpio
    pin:
      number: GPIO21
      inverted: true
      mode:
        input: true
        pullup: true
    id: MouseTrapDoor
    name: "Mouse Trap Door"
sensor:
  - platform: adc
    pin: GPIO26
    id: MouseTrapLDRFast
    update_interval: 50ms
    on_value:
      then:
        - lambda: |-
            if (id(MouseTrapEnable).state and id(MouseTrapLED).state and x < 1.9) {
              id(MouseTrapSolenoid).turn_on();
            }
  - platform: template
    id: MouseTrapLDR
    name: "Mouse Trap LDR"
    lambda: 'return id(MouseTrapLDRFast).state;'
    update_interval: 30s
    unit_of_measurement: V
    filters:
      - round: 3
```

On line 55 you can see that I compare the ADC value with 1.9. When the LED is on, the LDR voltage is about 2.22V. When something goes between the LED and LDR (i.e. a mouse) the value drops. I chose 1.9V as a suitably lower value. Normal daylight gives a reading of 0.6V - 1.5V. Note that in bright sunlight the LDR can read 2.3V or more, but:
1. The trap should be in shaded area.
2. Mice are nocturnal, so the best time to catch them is at night.

I had to modify the logging so that the logs weren't full of ADC notifications. I did this by changing the logging section as follows:

```yaml
# Enable logging
logger:
  level: DEBUG
  logs:
    sensor: INFO
```

I used the alarm from the Mk1 mouse trap, but modified the automation:

```yaml
alias: Mouse Caught
description: ""
triggers:
  - trigger: state
    entity_id:
      - switch.mouse_trap_2_mouse_trap_triggered
    to:
      - "on"
conditions: []
actions:
  - action: switch.turn_on
    metadata: {}
    target:
      entity_id: switch.mouse_alarm_mouse_alarm
    data: {}
mode: single
```

I added the controls to a dashboard which looked like this:

![Dashboard](/images/HA-MouseTrap2/MTMk2-Dashboard.png)

This all worked very well, and we managed to capture three mice (over three nights). They were quickly taken taken to their new home a couple of miles away without any undue stress to them.

<video width="100%" controls="controls" poster="/images/HA-MouseTrap2/Mouse1-Still-Image.jpg">
  <source src="/images/HA-MouseTrap2/Mouse1.mp4" type="video/mp4" preload="auto">
  Your browser does not support the video tag.
</video>

You can see the mouse was very curious about the trap, but it didn't put it off taking the food (which was two small bits of cracker, one in the middle and one at the back). The mice are facinating to watch, and I have a lot of respect for their stealth and resourcefulness, but they are no match for technology!
