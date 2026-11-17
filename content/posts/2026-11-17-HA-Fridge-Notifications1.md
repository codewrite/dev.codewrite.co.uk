---
title: "Home Assistant Fridge / Freezer Notifications"
date: 2026-11-17
draft: false
categories:
  - home assistant
---

In the house there is a fridge, freezer and fridge freezer with smart plugs that show how much power they are using.
One of my dashboards shows the power used (among other things). They all switch on and off periodically as can be seen here:

![Fridge Power Chart](/images/HA-Fridge-Notifications1/FridgePowerChart.png)

It occurred to me that if they stop switching on or off, there is a problem. If an appliance doesn't switch on, it means that there is a problem with the power - maybe the plug has been pulled out, or it has stopped working. If however it doesn't turn off, that indicates another problem - maybe the door has been left open. So I thought about how to detect both situations. You could just have automations that trigger when an appliance has been on (or off) for a certain time, but I decided it would be nice to see what was going on graphically. So I created some template sensors that showed the power integral:

![Fridge Power Integral Chart](/images/HA-Fridge-Notifications1/FridgePowerIntegral.png)

These count up when on, and down when off.
The code for these (in the template.yaml file) is:

```yaml
- trigger:
  - platform: time_pattern
    minutes: "/1"
  variables:
    freezer_on: "{{ states('sensor.freezer_energy_power')|float(0) > 10.0 }}"
    fridge_on: "{{ states('sensor.fridge_energy_power')|float(0) > 10.0 }}"
    fridge_freezer_on: "{{ states('sensor.fridge_freezer_energy_power')|float(0) > 10.0 }}"
  sensor:
  - name: Freezer Power Integral
    unique_id: freezer_power_integral
    unit_of_measurement: ds
    state: "{{ this.attributes['acc'] }}"
    attributes:
      prev_on: "{{ freezer_on }}"
      acc: >
        {% if freezer_on != this.attributes['prev_on'] %}
          {{ 0 }}
        {% else %}
          {{ this.attributes['acc']|int(0) + iif(freezer_on, 1, -1) }}
        {% endif %}
  - name: Fridge Power Integral
    unique_id: fridge_power_integral
    unit_of_measurement: ds
    state: "{{ this.attributes['acc'] }}"
    attributes:
      prev_on: "{{ fridge_on }}"
      acc: >
        {% if fridge_on != this.attributes['prev_on'] %}
          {{ 0 }}
        {% else %}
          {{ this.attributes['acc']|int(0) + iif(fridge_on, 1, -1) }}
        {% endif %}
  - name: Fridge Freezer Power Integral
    unique_id: fridge_freezer_power_integral
    unit_of_measurement: ds
    state: "{{ this.attributes['acc'] }}"
    attributes:
      prev_on: "{{ fridge_freezer_on }}"
      acc: >
        {% if fridge_freezer_on != this.attributes['prev_on'] %}
          {{ 0 }}
        {% else %}
          {{ this.attributes['acc']|int(0) + iif(fridge_freezer_on, 1, -1) }}
        {% endif %}
```

This creates three new sensors. Each sensor stores attributes that hold:

- The previous on/off state, so that we can see when it goes from on to off or vice-versa
- An accumulator (acc) that increments (or decrements) by one for every minute in an on or off state.

On or off is arbitrarily set as on \(\gt\) 10W and off \(\leq\) 10W.

It was then an easy case of creating automations that checked if the values were out of range:

```yaml
- id: notification_fridge_freezer_door_open
  alias: Notification Fridge Freezer Door Open
  description: ''
  triggers:
  - trigger: numeric_state
    entity_id:
    - sensor.freezer_power_integral
    above: 20
  - trigger: numeric_state
    entity_id:
    - sensor.fridge_power_integral
    above: 30
  - trigger: numeric_state
    entity_id:
    - sensor.fridge_freezer_power_integral
    above: 20
  conditions: []
  actions:
  - action: notify.send_message
    target:
      entity_id: notify.my_phone_name_here
    data:
      message: Fridge / Freezer Door Open
  mode: single
- id: notification_fridge_freezer_power_failure
  alias: Notification Fridge Freezer Power Failure
  description: ''
  triggers:
  - trigger: numeric_state
    entity_id:
    - sensor.fridge_freezer_power_integral
    below: 50
  - trigger: numeric_state
    entity_id:
    - sensor.fridge_power_integral
    below: 110
  - trigger: numeric_state
    entity_id:
    - sensor.freezer_power_integral
    below: 30
  conditions: []
  actions:
  - action: notify.send_message
    target:
      entity_id: notify.my_phone_name_here
    data:
      message: Fridge / Freezer Power Failure
  mode: single
```

You can see from this that the freezer turns on and off quite frequently, but the fridge can be off for nearly two hours.

The on and off times do vary - maybe because the door has been opened or closed a few times, or if something has been put in a fridge that needs to be cooled down.

The other problem with this is that in the summer the fridge/freezers will have to work harder - and therefore will be on for longer than we expect - but that's not a problem at the moment!
