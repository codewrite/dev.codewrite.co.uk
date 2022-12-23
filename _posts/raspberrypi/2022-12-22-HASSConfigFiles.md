---
layout: post
title:  "Home Assistant REST Devices and Sensors"
date:   2022-12-22 16:00:00 +0000
categories: raspberryPi
---

A while back (before I was using Home Assistant) I built a COB light controller board. The idea was to have lights under the eaves all round the outside of our house (bungalow). They look like this:

![COB Lights under Eaves](/assets/images/COBLightsInHASS/LightsUnderEaves.jpg)

In this picture there are three lights, but in around the rest of the house there are about 15 in total on 4 different circuits. I won't go into the detail here other than to say that there is a controller board up in the loft that uses a Wemos D1 mini which serves up a REST interface to turn the lights on and off. I did a presentation for the London Raspberry Pi group. The link to my GitHub page is here:

[COBHouseLights github repo][COBLights Github Repo]

The Doc folder contains the presentation (.pptx) which describes how it all works. I added current monitoring that also switches all the lights off in the unlikely event that a short occurs in the wiring or lights (the whole thing is powered by a 12V 5A transformer). I created a VueJS front end that was hosted on a Raspberry Pi using Nginx.

The web page looked like this (there's actually two pages, this is one of them):

![COB Lights Web Page](/assets/images/COBLightsInHASS/COBLightWebsite.png)

Because I am using Swagger (OpenAPI) you can access the API via a web page, which looks like this:

![COB Lights API](/assets/images/COBLightsInHASS/COBLightSwaggerAPI.png)

That all worked well, and I could have carried on adding features like turning the lights on and off automatically.

But then...

I started using Home Assistant. Needless to say if I was starting again I would use either ESPHome or Tasmota for the controller board. But I'm glad I have done it this way because I now have an example of how to interface between Home Assistant and a REST interface (which means being able to interface to almost anything). The rest of this article is how I acheived that.

This is how the lights will appear in Home Assistant:

![HA COB Lights Dashboard](/assets/images/COBLightsInHASS/HACOBLightsDashboard.png)

The other devices (tablelamp, cornerlamp and sidelight) are commercial smart plugs and light that I reflashed with Tasmota (they came with Tuya firmware).

If you click on any of the lights you get a properties screen like this:

![HA COB Light Properties](/assets/images/COBLightsInHASS/HACOBLightsProperties.png)

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

We'll come to the secrets file later, but for now all we need to know is that it contains URLs and passwords (because having that information here would be a bad idea). 


TODO: Watch this space! I'm i the middle of writing this... I'll describe the files in HA that make the above possible...

[//]: # (# -------------)
[//]: # (#  References)
[//]: # (# -------------)

[COBLights Github Repo]: https://github.com/codewrite/COBHouseLights
