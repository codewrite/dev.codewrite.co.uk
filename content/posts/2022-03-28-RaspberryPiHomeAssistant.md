---
title: "Home Assistant on the Raspberry Pi"
date: 2022-03-28
draft: false
categories:
  - raspberryPi
---

I use Home Assistant (HASS) around the house to switch some of the lights on and off automatically and to monitor the temperature. I plan to use HASS for other automation tasks, maybe controlling things in the garden (e.g. watering plants in the greenhouse) and inside to turn the heating on and off. In this post will describe what I currently have and some ideas for the future.

The main reason that I like HASS is that it separates functionality, specifically keeping the configuration and control logic away from the sensors and devices. This makes everything much more scalable and maintainable. I could write the software to control everything, but like most software engineers I would rather not reinvent the wheel, especially when you have something like HASS that does such a good job with much less effort.

For the devices and sensors I use the following general purpose firmware:
- Tasmota
- ESPHome
- HACS / Passive BLE monitor

I use Tasmota for ESP8266 devices, ESPHome for ESP32 and Passive BLE monitor for some Xiaomi thermometers that you can buy from China for about Â£4 each (I reflash them with an open source firmware but you don't have to). HASS has various integrations and addons that do a very good job of finding these devices when you connect them to your home network (generally using wifi, but other protocols like Bluetooth and ZigBee can be used). It's a good idea to make the security as good as possible because even innocent looking devices like thermometers can be hacked into to gain control of your home network (I know security is tedious, but it will help you sleep better at night!).

I have two Raspberry Pis, both version 4B. One is in an Argon One case, the other is in a standard case. Both use a SSD plugged into via USB rather than using a micro USB card (as recommended by HASS). The Argon One Pi is the "live" version, the other Pi I use for testing and experiments. If you really care about uptime you may want to use an uninterruptible power supply and/or some sort of watchdog arrangement. I haven't bothered to do that (yet).

The simplest use of HASS I have is to turn some of the lights on and off at night. I have some lights inside and some outside. The inside lights use commercially bought smart bulbs and plugs. These come programmed with Tuya firmware which I have reflashed with Tasmota and configured to communicate using MQTT over wifi (there is a Tuya plugin for HASS but I prefer to not have to use the Tuya server). The outside lights are custom made using a Wemos D1 board for the controller and 12V COB LEDs. I used a web api (and swagger) written in C. This was (relatively) easy to control via HASS by writing custom sensor and switch wrappers using the REST integration. With hindsight it may have been easier to use Tasmota on the control board, but it shows that you can abstract away the sensor/device details as I talked about earlier.

The way I wanted the lights to behave was to come on near sunset and go off at a specific time. I also wanted to have an override button (which was actually a button on one of the smart plugs). To turn the lights on and off I wrote the following scripts:
- Inside Lights On Sequenced
- Outside Lights On Sequenced
- Inside Lights Off Sequenced
- Outside Lights Off Sequenced

In the following example script the lights are turned on with a 20 second delay between each:

````yaml
alias: Inside Lights On Sequenced
sequence:
  - service: switch.turn_on
    target:
      entity_id: switch.tablelamp
    data: {}
  - delay: 20
  - service: switch.turn_on
    target:
      entity_id: switch.cornerlamp
    data: {}
mode: single
````

I then wrote the following automations to call the scripts:
- Turn inside lights on at dusk when overcast.
- Turn outside lights on at dusk when overcast.
- Turn inside lights on at dusk when sunny.
- Turn outside lights on at dusk when sunny.
- Turn inside lights off at night.
- Turn outside lights off at night.
- Turn all lights off when table lamp is turned off

In the following automation we check the weather and if it is overcast we turn the lights on:


````yaml
alias: Turn inside lights on at dusk when overcast
description: ''
trigger:
  - platform: sun
    event: sunset
    offset: '-00:30:00'
condition:
  - condition: template
    value_template: >-
      {{ states('weather.home') != "sunny" and states('weather.home') !=
      "partlycloudy" }}
action:
  - service: script.inside_lights_on_sequenced
    data: {}
mode: single
````


The other automations are similar and because they are separated out enable us to (for instance) turn the outside lights on at a different time to the inside lights.

In case we want to override the automatic switch on/off we can press a button on the table lamp. This triggers the following automation that turns all the lights off:

````yaml
alias: Turn off all the lights when table lamp is turned off
description: ''
trigger:
  - platform: state
    entity_id: switch.tablelamp
    to: 'off'
condition: []
action:
  - service: switch.turn_off
    target:
      entity_id: switch.cornerlamp
    data: {}
  - service: switch.turn_off
    target:
      entity_id: switch.cob_light_1
    data: {}
  - service: switch.turn_off
    target:
      entity_id: switch.cob_light_2
    data: {}
  - service: switch.turn_off
    target:
      entity_id: switch.cob_light_3
    data: {}
mode: single
````

As I mentioned earlier, I also have temperature sensors that use BLE. I have also plugged an ultrasonic distance measuring board into an ESP32 board and programmed it up with Tasmota. I can then see the distance (I was actually using it to detect the water level in a bucket) in HASS. Creating a water sensor like this and setting it up took me less than a hour from start to finish. Although I haven't created the automations, these could be created in the same was as the light automation scripts above.

There are lots of addons, some that I am using are:
- Wireguard
- AdGuard
- Node-Red

There are also lots of integrations and even more if you use something called HACS which is the community store.
I have tried connecting an ESP32CAM and using MotionEye, which worked, but it was a bit slow. I have seen that there is a HACS integration called Frigate that looks like it should be very fast, but for the best performance it would need a Google Coral TPU. However the Frigate FAQs seem to suggest that you should then be able to do 100 FPS image recognition!

There is a ton of information, tutorials and questions/answers about HASS on the internet, so most problems should be solvable with a bit of Googling!

