---
title: Soil Humidity Monitor on Arduino
tags:
- IoT
- Arduino
---

# Building a Soil Humidity Monitor with an Arduino
Hey builders!

I recently attended the GeekWire Cloud Summit in Seattle, and listened to a great fireside chat with Kevin Scott, the CTO of Microsoft. Although he covered a wide range of subjects, he touched on how some Azure customers are using IoT to add value to the agriculture industry. That was all it took for me to start shopping around for some parts to see if I could spin up a proof of concept.

This project isn't finished yet, but I have reached the first milestone- **get soil humidity of plants**. I'll follow up with another post as I build out the notification system.

## The Problem
I'm not the green thumb of the house- that's Lindsey's specialty. I do, however, enjoy having lots of greenery around my desk. I often neglect my plants (poor babies) and although I haven't killed any yet, they get pretty sad when they're not watered.

## The Solution
I'd like to be notified when the plants are drying out.

## The Materials
### Hardware
* [5x Soil Hygrometer](https://amzn.to/2MH0kVT)
* [Arduino Uno](https://amzn.to/2MJsb8c)

### Software
* [Arduino IDE](https://www.arduino.cc/en/Main/Software)

## Procedure
I've had an Arduino sitting unused in my parts kit for the better part of a decade, so I was happy to finally have a use for it.

1. Connect the Arduino to your computer via USB.
1. Upload a test script to see how the whole thing works.
1. Connect a hygrometer to the Arduino.
1. Write a script to read from the hygrometer.
1. Observe hygrometer outputs in the serial console.
1. Connect multiple hygrometers and update script to handle them.

## So Now What?
The Arduino can now read the soil humidity, but we can only observe the values through the IDE's serial monitor. This isn't the standalone solution that I'm looking for- I'd like to power this through a 5v USB cable and communicate over WiFi. Once that's done, I can start to work on sending the data to the cloud, where there's plenty of cool stuff we can do with it.

## Future Work
### Get Arduino on WiFi
It looks like there are new Arduino revisions coming out soon that have WiFi built in, but my old Arduino Leonardo doesn't have that capability. I've been reading about the ESP8266 chip and that seems like the route to go. You can buy Arduino WiFi shields that are 'plug and play' for ~$35 but the $2.50 ESP8266 is a good opportunity to learn some new stuff and save a few bucks.

### Send Data to AWS IoT from Arduino
I've done plenty of AWS IoT work using the NodeJS SDK so hopefully some of that transfers. The Arduino runs C though, and I'll have to figure out how to add libraries to the Arduino package. I'll also have to figure out how to load x.509 certs onto the Arduino. Once that's sorted out, I can send data to AWS IoT and use the rules engine to connect my data stream however I'd like.

### Act on IoT Data
I've got a couple of things to figure out here. In the past I've just sent data to CloudWatch and configured alarms based off of that, but I'd like to explore some of the other features that AWS IoT offers. More research and fiddling is needed here.

### Store Data
I'm not concerned about storing data except to look at trends later on- if I went the CloudWatch route I'd get all of this out of the box. I might be convincing myself just to do CloudWatch :)
