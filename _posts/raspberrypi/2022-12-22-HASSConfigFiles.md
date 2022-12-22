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

TODO: Watch this space! I'm i the middle of writing this... I'll describe the files in HA that make the above possible...

[//]: # (# -------------)
[//]: # (#  References)
[//]: # (# -------------)

[COBLights Github Repo]: https://github.com/codewrite/COBHouseLights
