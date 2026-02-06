---
title: "Home Assistant REST Devices and Sensors"
date: 2022-12-22
draft: false
categories:
  - raspberryPi
---

A while back (before I was using Home Assistant) I built a COB light controller board. The idea was to have lights under the eaves all round the outside of our house (bungalow). They look like this:

![COB Lights under Eaves](/images/COBLightsInHASS/LightsUnderEaves.jpg)

In this picture there are three lights, but around the rest of the house there are about 15 in total on 4 different circuits. I won't go into the detail here other than to say that there is a controller board up in the loft that uses a Wemos D1 mini which serves up a REST interface to turn the lights on and off. I did a presentation for the London Raspberry Pi group. The link to my GitHub page is here:

[COBHouseLights github repo][COBLights Github Repo]

The Doc folder contains the presentation (.pptx) which describes how it all works. I added current monitoring that also switches all the lights off in the unlikely event that a short occurs in the wiring or lights (the whole thing is powered by a 12V 5A transformer). I created a VueJS front end that was hosted on a Raspberry Pi using Nginx.

The web page looked like this (there's actually two pages, this is one of them):

![COB Lights Web Page](/images/COBLightsInHASS/COBLightWebsite.png)

Because I am using Swagger (OpenAPI) you can access the API via a web page, which looks like this:

![COB Lights API](/images/COBLightsInHASS/COBLightSwaggerAPI.png)

That all worked well, and I could have carried on adding features like turning the lights on and off automatically.

But then...

I started using Home Assistant. Needless to say if I was starting again I would use either ESPHome or Tasmota for the controller board. But I'm glad I have done it this way because I now have an example of how to interface between Home Assistant and a REST interface (which means being able to interface to almost anything). The rest of this article is how I acheived that.

This is how the lights will appear in Home Assistant:

![HA COB Lights Dashboard](/images/COBLightsInHASS/HACOBLightsDashboard.png)

The other devices (tablelamp, cornerlamp and sidelight) are commercial smart plugs and light that I reflashed with Tasmota (they came with Tuya firmware).

If you click on any of the lights you get a properties screen like this:

![HA COB Light Properties](/images/COBLightsInHASS/HACOBLightsProperties.png)

This allows you to change the brighness of the COB lights.

My config.yaml file looks like this (some bits removed for brevity)

````yaml
default_config:

recorder:
  db_url: !secret recorder_db_url

config:

sensor: !include sensors.yaml
automation: !include automations.yaml
script: !include scripts.yaml
rest_command: !include rest_command.yaml
rest: !include rest.yaml
light: !include light.yaml
````

The bits of this file that are relevant to our REST devices are sensors.yaml, rest_command.yaml, rest.yaml and light.yaml. The overall concept is that we will have sensors that tell us the current state of the lights (on, off, brightness etc.) and commands (in rest_command.yaml) that change the state of the lights (again, on, off and brightness). Let's start with the sensors. This is what is in the rest.yaml file:


````yaml
- authentication: basic
  resource: !secret cob_leds_get_url
  username: apikey
  password: !secret coblights_password
  sensor:
    - name: Cob Light 1
      value_template: "{{ value_json[0].on }}"
      json_attributes_path: "$[0]"
      json_attributes:
        - brightness
    - name: Cob Light 2
      value_template: "{{ value_json[1].on }}"
      json_attributes_path: "$[1]"
      json_attributes:
        - brightness
    - name: Cob Light 3
      value_template: "{{ value_json[2].on }}"
      json_attributes_path: "$[2]"
      json_attributes:
        - brightness
    - name: Cob Light 4
      value_template: "{{ value_json[3].on }}"
      json_attributes_path: "$[3]"
      json_attributes:
        - brightness
````


We'll come to the secrets file later, but for now all we need to know is that it contains URLs and passwords (because having that information here would be a bad idea). Each sensor has one value and one attribute. These can be accessed as follows:


````yaml
{{ states('sensor.cob_light_1') }}
{{ state_attr('sensor.cob_light_1', 'brightness') }}
````


There is also a sensor in sensor.yaml. This is for the COB lights current and this is how it is defined:


````yaml
- platform: rest
  name: "COB Lights Current"
  value_template: "{{value_json.current}}"
  unit_of_measurement: mA
  scan_interval: 60
  resource: !secret cob_leds_status_url
  username: apikey
  password: !secret coblights_password
  authentication: basic
  json_attributes:
    - samples
    - millis
    - busvoltage
    - maxcurrent
    - lastMessage
````


In this case we take one of the json attributes (current) and use this for the value. The other json values are presented as attributes. The value and attributes can be accessed in the same way as before.

The next part of the REST devices is the controls. These are defined in rest_command.yaml as follows:


````yaml
cob_light_set:
  url: !secret cob_led_set_url
  method: put
  payload: >
    { {{ '' }}
      {%- if on is defined -%}
        "on": {{ on|lower }},{{ ' ' }}
      {%- endif -%}
      {%- if brightness is defined -%}
        "brightness": {{ brightness }},{{ ' ' }}
      {%- endif -%}
    }
  username: "apikey"
  password: !secret coblights_password
  content_type: 'application/json; charset=utf-8'
````


This is slightly more complicated than the sensors because we have a single service that takes three parameters - led, on and brightness. The led is mandatory, the on and brightness parameters are optional (in case you are wondering where the led parameter is, it is in the secrets.yaml file). So let's see what is in the secrets.yaml file now:


````yaml
coblights_password: mypasswordhere
cob_leds_get_url: http://192.168.1.234:5678/leds
cob_led_set_url: http://192.168.1.234:5678/leds/{{ led }}
cob_leds_status_url: http://192.168.1.234:5678/status
````


Obviously there will be other secrets in here too, but this is the ones that are relevent to our REST API. Only one of these is a real secret, the others are URLs, but it is a good idea to have them here because then we are keeping implementation details out of the configuration files. Notice that the cob_led_set_url has a parameter in it. If you refer back to sensors.yaml you should be able to see how this allows us to call the relevant API service and control a specific group of COB lights (1, 2, 3 or 4). It would be nice to do a similar thing for the sensors (rather than having four very similar defintions), but unfortunately sensors cannot be parameterized.

The final part of our REST devices is the actual definition of the devices. This is done in the lights.yaml file:


````yaml
- platform: template
  lights:
    cob_light_1:
      friendly_name: "COB Lights (Side)"
      value_template: "{{ states('sensor.cob_light_1') }}"
      level_template: "{{ state_attr('sensor.cob_light_1', 'brightness') / 4 }}"
      turn_off:
        - service: rest_command.cob_light_set
          data: { "led": 1, "on": false }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_1
      turn_on:
        - service: rest_command.cob_light_set
          data: { "led": 1, "on": true, "brightness": 132 }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_1
      set_level:
        - service: rest_command.cob_light_set
          data: { "led": 1, "on": "{{ 'true' if brightness > 0 else 'false' }}", "brightness": "{{ brightness * 4 }}" }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_1

    cob_light_2:
      friendly_name: "COB Lights (Bins)"
      value_template: "{{ states('sensor.cob_light_2') }}"
      level_template: "{{ state_attr('sensor.cob_light_2', 'brightness') / 4 }}"
      turn_off:
        - service: rest_command.cob_light_set
          data: { "led": 2, "on": false }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_2
      turn_on:
        - service: rest_command.cob_light_set
          data: { "led": 2, "on": true, "brightness": 132 }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_2
      set_level:
        - service: rest_command.cob_light_set
          data: { "led": 2, "on": "{{ 'true' if brightness > 0 else 'false' }}", "brightness": "{{ brightness * 4 }}" }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_2

    cob_light_3:
      friendly_name: "COB Lights (Front)"
      value_template: "{{ states('sensor.cob_light_3') }}"
      level_template: "{{ state_attr('sensor.cob_light_3', 'brightness') / 4 }}"
      turn_off:
        - service: rest_command.cob_light_set
          data: { "led": 3, "on": false }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_3
      turn_on:
        - service: rest_command.cob_light_set
          data: { "led": 3, "on": true, "brightness": 132 }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_3
      set_level:
        - service: rest_command.cob_light_set
          data: { "led": 3, "on": "{{ 'true' if brightness > 0 else 'false' }}", "brightness": "{{ brightness * 4 }}" }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_3

    cob_light_4:
      friendly_name: "COB Lights (Back)"
      value_template: "{{ states('sensor.cob_light_4') }}"
      level_template: "{{ state_attr('sensor.cob_light_4', 'brightness') / 4 }}"
      turn_off:
        - service: rest_command.cob_light_set
          data: { "led": 4, "on": false }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_4
      turn_on:
        - service: rest_command.cob_light_set
          data: { "led": 4, "on": true, "brightness": 132 }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_4
      set_level:
        - service: rest_command.cob_light_set
          data: { "led": 4, "on": "{{ 'true' if brightness > 0 else 'false' }}", "brightness": "{{ brightness * 4 }}" }
        - service: homeassistant.update_entity
          entity_id: sensor.cob_light_4
````


As with the sensors, we can't parameterize these, unfortunately. Each light has two get values and three set values. We can get the on/off state and the brightness. We can set the lights on, set them off, or set the brightness. Notice that we multiply or divide the brightness by 4. That is because Home Assistant treats the brightness as between 0 and 255, whereas our REST API needs values between 0 and 1023 (the Home Assistant UI displays the brightness as 1 to 100 just to add a bit more confusion!).

We now have some new devices which we can add to any dashboard. They will appear as follows:

![HA COB Light Add to Dashboard](/images/COBLightsInHASS/HACOBLightsAddToDashboard.png)

As I said originally, it is far easier to use Tasmota or ESPHome, but this approach theoretically allows you to turn any REST API into a Home Assistant device, even ones where you only have access to the API not the source code.

## References

- [COBLights Github Repo](https://github.com/codewrite/COBHouseLights)

