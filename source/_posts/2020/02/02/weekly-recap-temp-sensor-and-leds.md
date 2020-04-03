---
title: "Weekly Recap: Temperature Sensor and Addressable LEDs"
tags:
  - iot
  - esp8266
  - ds18B20
  - battery
  - ws2128b
date: 2020-02-02 12:00:00
---

Lots of small project updates this week! I had one open project going into this week, and started working on one new one:

{% asset_img led-colors.gif "Roll of LEDs changing color from red to green" %}

Plus, [I did a few streams on Twitch](https://www.twitch.tv/rampage_wildcard)! Nothing crazy, but I'm hoping to continue to turn the camera on whenever I'm tinkering. Follow me on [Twitch](https://www.twitch.tv/rampage_wildcard) to get notified when I go live!

<!--more-->

## This Week's Projects
* V2 - [Battery Operated Waterproof Temperature Sensor](/2020/01/15/battery-operated-esp8266/)
* Addressable LEDs ([WS2128B](/parts/WS2812B/))

### Waterproof Temperature Sensor V2
No code changes to this project- instead, V2 focused on hardware functionality (read: drilling better holes). 3 things got changed up in this iteration. If you'd like to see what I did in V1, [check out my previous post](/2020/01/15/battery-operated-esp8266/).

{% asset_img temp-sensor-v2-labelled.png "Side by side comparison of v1 and v2 of the sensor module"%}

1. The original version had the battery management board soldered directly to the battery. This time, I bought some female mini-JST leads to attach to the board. This allows me to swap out the battery if anything goes wrong, or if I want to put a larger one in. The leads are also more pliable, so it helps everything lay flat in the case!

2. This time, I fed the sensor through the side panel instead of the front. The old version was awkward- I had to hold everything in place while shutting the case. You can't tell from the picture, but I also put some hot glue around the sensor wire to create a seal and give a little bit of weather resistance.

3. Power switch! In V1, the ESP8266 was wired directly to the battery management board. This time, I put a simple switch in the circuit so I can turn the power off without opening the case up and unplugging jumpers. This is especially useful when I need to bring the sensor in to charge, so I don't skew any data with inside temperatures.

I'm pretty happy with how everything has turned out so far! Battery life continues to be a pain- I'm only getting a few days out of a charge. I've got a few ideas for V3 already, and using BLE (Bluetooth Low Energy) to decrease that power draw is on the radar.

### Addressable LEDs
I picked up this [spool of LEDs on Amazon](/parts/WS2812B/) a while back and I've been waiting for an excuse to play with it. A lazy Saturday seemed like the perfect reason!

{% asset_img rainbow-leds.png "LEDs in a rainbow pattern, attached to an ESP8266" %}

Turns out, the [FastLED library](https://github.com/FastLED/FastLED) makes addressable LED strips incredibly easy. It supports a bunch of different LED chipsets, including what I've got- the [WS2812B](/parts/WS2812B/).

After doing some simple tests, I set out to recreate the [Philips Hue LightStrip](https://github.com/FastLED/FastLED)- that meant hooking up the ESP8266 to AWS IoT so I could control them from an external source. Figuring out how to get the x.509 certificates loaded into the ESP8266 took a bit longer than I thought, so I called it a night once I was able to do some basic switching through AWS IoT. I still need to clean up the code a bit before I can publish it to GitHub- hardcoded credentials and spaghetti code everywhere.

{% asset_img leds-aws-iot.gif "LED color being controlled by AWS IoT" %}

## Wrap Up
That's what I've knocked out this week! Next week I'm hoping to continue build out the lights- I'd like to use  AWS Thing Shadows to manage state for the lights, and then build out a simple color picker app that will allow me to set the lights from a browser.

Looking forward to the next projects! Cheers!