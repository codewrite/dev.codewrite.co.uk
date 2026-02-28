---
title: "Home Assistant Serial Link to an Arduino"
date: 2026-02-27
draft: false
categories:
  - arduino
  - raspberryPi
  - homeAssistant
---

The purpose of this project was to connect an Arduino Nano to the USB port that Home Assistant was running on. For me that is a Raspberry Pi 4 but this solution should work with any Home Assistant hardware. And the reason for using a serial connection over USB (rather than wirelessly with WiFi or similar) could be for many reasons:
- Wifi may not be available (e.g. if the network is down)
- It is more secure
- It is un-jammable

The ultimate plan for me was to create an uninterruptable power supply for Home Assistant from bits that I had:
- A 12V lead acid battery
- A 15V mains adapter
- A DC - DC converter to provide the 5V supply to the Raspberry Pi
- An Arduino Nano as the UPS controller

And the reason for using serial over USB for me was that if the power went down there would be no WiFi (unless I powered the WiFi router from the UPS which I didn't want to do).

So the solution that I came up with looked like this:

![RPI LED Board](/images/HA-UPS/UPS-Block-Diagram.png)

The Arduino Nano is always powered and running - with the watchdog enabled.
But before I started on the UPS, I decided to create a proof of concept to test the Home Assistant to Arduino communication. So for this I created the following on a breadboard:

![RPI LED Board](/images/HA-UPS/HA-Nano-Block-Diagram.png)

The LDR (light dependent resistor) is used to sense the ambient light level, and the LED is programmable to blink with an interval and duration.

The software is based on the Home Assistant [Serial Integration](https://www.home-assistant.io/integrations/serial/). I decided that the return from the Arduino would be encoded as JSON:

```json
{"lightlevel":472,"Sensor":{"Interval":1000,"AvgSamples":30},"LedBlink":{"Interval":500,"Duration":50}}
```

The JSON response includes the LDR value, LDR sample rate (Interval) and sample average (AvgSamples). These last two numbers multiplied together give the sensor update rate (in this case 30 seconds). The LED blink interval and duration are reported back to HA, but also the LED blinks at the specified rate.

The serial integration allows you to create **sensors**, but does not allow you to send **commands**. However, you can send commands using the Home Assistant [Shell Command](https://www.home-assistant.io/integrations/shell_command/). Example commands would look like:

- echo 'ss1000,30;' > /dev/ttyUSB0
- echo 'sl500,50;' > /dev/ttyUSB0

To test these, they can be sent via the Home Assistant Terminal Add-On.

To receive the serial data and decode it, and send commands, I modified the configuration.yaml file as follows:

```yaml
sensor:
  - platform: serial
    serial_port: /dev/ttyUSB0

shell_command:
  set_sensor: /config/nano-send-command.sh "ss" {{ interval }} {{ samples }}
  set_led_blink: /config/nano-send-command.sh "sl" {{ interval }} {{ duration }}

template: !include template.yaml
```

And I created a Template.yaml file with the following contents:

```yaml
### template.yaml

- sensor:
  - name: Nano Light Level
    state: "{{ state_attr('sensor.serial_sensor', 'lightlevel') }}"
    unique_id: nano_light_level
    unit_of_measurement: lx
- number:
  - name: Nano Sensor Interval
    unique_id: nano_sensor_interval
    state: "{{ state_attr('sensor.serial_sensor', 'Sensor').Interval }}"
    set_value:
      - action: script.set_sensor_interval
        data:
          interval: "{{ value }}"
          samples: "{{ state_attr('sensor.serial_sensor', 'Sensor').AvgSamples }}"
    step: 1
    min: 100
    max: 60000
    unit_of_measurement: ms
- number:
  - name: Nano Sensor Average Samples
    unique_id: nano_sensor_avg_samples
    state: "{{ state_attr('sensor.serial_sensor', 'Sensor').AvgSamples }}"
    set_value:
      - action: script.set_sensor_interval
        data:
          interval: "{{ state_attr('sensor.serial_sensor', 'Sensor').Interval }}"
          samples: "{{ value }}"
    step: 1
    min: 1
    max: 60000
- number:
  - name: Nano LED Interval
    unique_id: nano_led_interval
    state: "{{ state_attr('sensor.serial_sensor', 'LedBlink').Interval }}"
    set_value:
      - action: script.set_led_blink_interval
        data:
          interval: "{{ value }}"
          duration: "{{ state_attr('sensor.serial_sensor', 'LedBlink').Duration }}"
    step: 1
    min: 1
    max: 60000
    unit_of_measurement: ms
- number:
  - name: Nano LED Duration
    unique_id: nano_led_duration
    state: "{{ state_attr('sensor.serial_sensor', 'LedBlink').Duration }}"
    set_value:
      - action: script.set_led_blink_interval
        data:
          interval: "{{ state_attr('sensor.serial_sensor', 'LedBlink').Interval }}"
          duration: "{{ value }}"
    step: 1
    min: 1
    max: 60000
    unit_of_measurement: ms
```

The shell commands call a bash script which I put in the config directory:

```bash
#!/bin/bash

#echo "$1$2,$3;" > /config/abc.txt

echo "$1$2,$3;" > /dev/ttyUSB0
```

_Note the commented out echo command to a file. This allowed me to do some simple testing, in case I needed to. Also, make sure that the line endings in the File Editor are set to Unix (LF), not Auto or Windows (CRLF) otherwise the script won't work. Unix is not necessarily the default (which I think it should be)._

The sensors (in the template.yaml file) have a **set_value** action which calls a script. The scripts file looks like this:

```yaml
set_sensor_interval:
  alias: Set Sensor Interval
  sequence:
  - action: shell_command.set_sensor
    metadata: {}
    data:
      interval: '{{ interval }}'
      samples: '{{ samples }}'
  mode: single
set_led_blink_interval:
  alias: Set LED Blink Interval
  sequence:
  - action: shell_command.set_led_blink
    metadata: {}
    data:
      interval: '{{ interval }}'
      duration: '{{ duration }}'
  mode: single
```

_Note that I have used the same parameter names in the scripts and the shell commands. You don't have to do this, and it might have been clearer if they were different. I might refactor this at some point..._

I could then add these sensors to a dashboard:

![HA Nano Dashboard](/images/HA-UPS/HA-Nano-Dashboard1.png)

The sensor numbers could be changed by clicking on them which showed the following dialog:

![HA Nano Dashboard](/images/HA-UPS/HA-Nano-Number-Change.png)

For the Arduino code, I created two classes, **Task** and **Command**. Tasks are timed with an interval and duration (typically). Commands process messages sent from Home Assistant.

The entire code for the Arduino can be found on Github, see below.

In part 2 of this article, I will show the UPS circuit in detail and the testing I did on it (but I haven't done that yet ;).

## References

- [Arduino Code on GitHub](https://github.com/codewrite/AnalogReadLightLevel)