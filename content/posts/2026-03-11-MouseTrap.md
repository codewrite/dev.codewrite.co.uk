---
title: "Mouse Capture Using Home Assistant"
date: 2026-03-11
draft: false
categories:
  - raspberryPi
  - homeAssistant
---

So we thought we might have a mouse under the kitchen units...

This isn't the first time we've had mice. And if you don't think there are any in your house, well maybe it's because you haven't noticed them. They are very elusive, generally coming out in the middle of the night, and they are __very__ shy!

I already had all the bits I needed to catch and re-home the mouse (you have to take it quite a long way - a mile or two - otherwise it will find it's way back!). The central component is a humane mouse trap, which has a pressure sensitive pad and door that stops the mouse escaping. They typically cost about £10 (e.g. on Amazon). My advice - do a bit of research - don't just get the cheapest one. They are very sensitive, but mice are very light, so the one I have had to be adjusted by putting a couple of coins on the pressure pad so that even the lightest mouse would trigger it.

The layout of the mouse trap components looked like this (not to scale):

![Mouse Trap Layout](/images/HA-MouseTrap/MouseTrapDeployment.png)

The light is always on. It doesn't put the mouse off; if it was that easy, then you could just put LEDs where you wanted to keep the mice out! The LDR on the mouse detector is placed behind the door. When the door closes, light falls on the sensor and the value reported to Home Assistant goes up. I checked this by trial and error, and found a suitable threshold was 800. More on this later.
The Raspberry Pi camera was there so that:
1. I could see what was going on.
2. My plan was to have some automatic detection (maybe using OpenCV). I haven't done that yet.

There are three main components of the Home Assistant solution. These are shown below:

![Mouse Trap Components](/images/HA-MouseTrap/MouseTrapComponents.png)

I used ESPHome. The code for the detector looked like this (after _captive_portal_):

```yaml
sensor:
  - platform: adc
    pin: GPIO32
    id: MouseTrapDoor
    name: "Mouse Trap Door"
    raw: True
    unit_of_measurement: "lx"
    update_interval: 30s
    filters:
      - round: 0
      - sliding_window_moving_average:
          window_size: 4
          send_every: 1
```

The code for the alarm looks like this:

```yaml
switch:
  - platform: gpio
    pin: GPIO16
    id: MouseAlarm
    name: "Mouse Alarm"
    on_turn_on:
      then:
        - script.execute: alarmbeep1
        - script.wait: alarmbeep1
        - if:
            condition:
              switch.is_on: MouseAlarm
            then:
              - script.execute: alarmbeep2
              - script.wait: alarmbeep2
        - script.execute: alarmbeep99
    on_turn_off: 
      then:
        - script.stop: alarmbeep1
        - script.stop: alarmbeep2
        - script.stop: alarmbeep99
  - platform: gpio
    pin: GPIO14
    id: GPIO14

script:
  - id: alarmbeep1
    then:
      - repeat:
          count: 60
          then:
            - switch.turn_on: GPIO14
            - delay: 0.1s
            - switch.turn_off: GPIO14
            - delay: 1.9s
  - id: alarmbeep2
    then:
      - repeat:
          count: 60
          then:
            - switch.turn_on: GPIO14
            - delay: 0.3s
            - switch.turn_off: GPIO14
            - delay: 0.7s
  - id: alarmbeep99
    then:
      - while:
          condition:
            switch.is_on: MouseAlarm
          then:
            - repeat:
                count: 11
                then:
                  - switch.turn_on: GPIO14
                  - delay: 0.2s
                  - switch.turn_off: GPIO14
                  - delay: 0.2s
            - repeat:
                count: 7
                then:
                  - switch.turn_on: GPIO14
                  - delay: 0.1s
                  - switch.turn_off: GPIO14
                  - delay: 0.1s
            - repeat:
                count: 5
                then:
                  - switch.turn_on: GPIO14
                  - delay: 0.4s
                  - switch.turn_off: GPIO14
                  - delay: 0.4s
```

It's a bit complicated (and needs to be simplified) but the idea is that it starts off quietly and then gets louder. That way, if it goes off in the middle of the night, it will wake me in a reasonable manner.

I wrote an automation to connect the detector up to the alarm:

```yaml
alias: Mouse Caught
description: ""
triggers:
  - trigger: numeric_state
    entity_id:
      - sensor.mouse_trap_mouse_trap_door
    above: 800
conditions: []
actions:
  - action: switch.turn_on
    metadata: {}
    target:
      entity_id: switch.mouse_alarm_mouse_alarm
    data: {}
mode: single
```

This is it set up just before I put the kick boards back in:

![Kitchen Photo](/images/HA-MouseTrap/Kitchen-without-kickboards.jpg)

I then just had to wait... I could watch to see if anything was happening on the Raspberry Pi Camera (you can see the bits of cracker in the trap):

![Raspberry Pi Camera Image](/images/HA-MouseTrap/RaspberryPiVideo.jpg)

Once the alarm had gone off, I put the whole trap in a cardboard box and the mouse was taken on a car journey to it's new home where it was released.
