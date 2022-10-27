---
title: Controlling Lights with AWS IoT Thing Shadows
date: 2020-04-04 12:36:52
tags:
---

This week, I dove into a feature of AWS IoT that I've heard a lot about, but I've never implemented myself- AWS IoT Thing Shadows. Often referred to as 'digital twins', Thing Shadows are meant to be a cloud-based representation of a device, acting as an intermediary between the device and any applications that would interface with the device. 

One of my ongoing projects has been to replicate the Philips Hue Light Strip. I've been able to build out the basic device using an ESP8266 and a WS2812B. The device connects directly to AWS IoT over WiFi and subscribes to an MQTT topic, allowing it to receive information about what color the LEDs should display. I wrote a relatively straightforward React app that allows the user to pick a color and publish an MQTT message, which triggers a color change.

There are a few scenarios where this current setup is insufficient:
* The device loses power and reboots to the default state
* The device is offline and a user changes the color through the application

To solve this, I figured I'd check out the AWS Thing Shadows. It seemed like a straightforward way to get this functionality. It was relatively straightforward, but it required a little more effor than I expected.

## Prerequsites
In order to use Thing Shadows, you must first register a Thing with AWS IoT and [deploy the generated X.509 certificates to your device](/2020/03/25/Using-X-509-Certificates-with-ESP8266s/).

## Understanding Thing Shadow Data Flow
Each Thing Shadow can be interacted with in two ways: a REST API, and by sending messages to special MQTT topics set up for each device. In this post, we're only going to be dealing with the MQTT side of things- the REST is going to come later (get it?).

When you register a Thing Shadow