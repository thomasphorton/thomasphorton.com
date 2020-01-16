---
title: raspberry pi vs. arduino
tags:
  - IoT
  - Arduino
  - Raspberry Pi
---

If you're new to the IoT/Maker space, you've probably noticed that there are two great options for hardware: the Raspberry Pi and the Arduino. While they might initially seem similar, there are actually enough differences that you'd want to pick one over the other based off of your application.

## Input Pins
Pi: digital only, must use an mcp3008 to convert analog

Arduino: digital and analog

## Operating System
Pi: full control over the OS, typically a Linux distribution. There are stripped down options to help with battery life etc

Arduino: ? Can't access the OS directly, can only upload sketch files (C) through the IDE

## Development Environment
Pi: typical Linux tools, lots of freedom

Arduino: Arduino IDE is a full IDE that handles code as well as compilation and upload.

## Power Consumption:
The Arduino family wins the power consumption battle, with ~70ma draw as opposed to Raspberry Pi's

## Pricing
Both the Raspberry Pi and Arduino come in a variety of different models, the largest differences in pricing being connectivity features.

### Standalone Boards
No WiFi, no Bluetooth- these are great for projects that will display data on an LCD.

###  WiFi
