---
title: Building a Battery-operated ESP8266 Sensor Module
tags:
  - iot
  - esp8266
  - tp4056
  - ds18B20
  - battery
date: 2020-01-15 19:14:39
---

This last week I've building a bunch of sensor modules to compliment my new local MQTT broker -> AWS IoT setup. One limiting factor for my rollout was powering all of these devices- it isn't exactly sustainable to run all of these off of microUSB plugged into the wall. I specifically wired up a waterproof temperature sensor so that I could monitor the lake temperature, before realizing that I had no good way to run it without punching a hole in the side of our house or leaving a window open.

That's a no go.

Enter the world of batteries: small bricks of chemicals that you can zap power into and pull it back out later. I'm honestly terrified of them, but I think it's healthy to treat them with respect- if you aren't careful, you can get hurt.

{% asset_img temp-sensor-outside.png "Battery-powered temperature sensor in a black case"%}

In this walkthrough, I'll go over how to wire up a battery/charging solution for your ESP8266 projects, as well as a simple method to reduce your project's power consumption so you don't have to charge up every few hours.

<!--more -->

## Ingredients
### Components
* [NodeMCU ESP8266](https://amzn.to/2uAy9zw)
* [DS18B20 Waterproof Temperature Probe](https://amzn.to/30bxGj4)
* [TP4056 Battery Management Board](https://amzn.to/2R1fynM)
* [3.7V 1000mAh Lithium Polymer Battery](https://amzn.to/2R2aqj5)

### Odds and Ends
* [Solid Core Electrical Wire](https://amzn.to/39UUnMP)
* [Crimps](https://amzn.to/37Tqmv2) & [Crimpers](https://amzn.to/2tPAgyP)
* [Watertight Cases](https://amzn.to/2tdjB8L)

## Procedure
### Hardware
1. Crimp a set of positive/negative leads.
1. Solder leads to the discharge pads.
1. Solder JST leads to battery management pads (the ones in the middle).
1. Connect power to the USB Micro port of the TP4056 to begin charging your battery.

{% asset_img battery-management-board.png "TP4056 Battery Management board attached to a 1000 mAh LiPo Battery"%}

### Code Changes

Before starting this project, I had an existing Arduino sketch that handled sensor reading and sending data through MQTT. It is available [on GitHub](https://github.com/thomasphorton/esp8266-temp), but you'll have to go back to the initial commit to see what it looked like originally. I've posted links to pull requests for each change I made so you can follow along and see what I did.

1. Use ESP.deepSleep() to incease battery life
The ESP.deepSleep(**n**) method will put your ESP8266 into a low-power mode for **n** microseconds. After this time, the voltage on pin 16 will go LOW. By connecting pin 16 to the RST pin, we can use that low voltage to cause the board to reset. Note: Leave the RST pin disconnected until after the code has been deployed! You will not be able to upload your sketch to the ESP8266 if pin 16 is connected to RST.

To use this feature properly, we'll have to refactor our code to match the new lifecycle of our component.

a. Refactor sensor code into a separate function. [View Pull Request](https://github.com/thomasphorton/esp8266-temp/pull/2/files)
Initially, the code for pulling sensor data was placed directly in the main loop. We can factor that out and make it a separate function. In a perfect world I'd separate the sensor reading from the message publishing because they do different things, but I'm feeling lazy... so they're getting stuck in the same function call for now.

b. Move sensor function call to from loop() to setup(). [View Pull Request](https://github.com/thomasphorton/esp8266-temp/pull/3/files)
Because the ESP.sleep() method will be resetting the board, we can consolidate all of our logic into the setup method. The client reconnect loop should be moved to the setup function as well. We can also get rid of the interval code left over in the loop.

The result of uploading this code to your ESP8266 should be that the function runs only one time, when the device first boots. That's what we want!

c. Add the ESP.sleep() call. [View Pull Request](https://github.com/thomasphorton/esp8266-temp/pull/4/files)
ESP.sleep takes the number of microseconds to sleep as a parameter. For readability, we can use exponential notation (e.g. 5e6 = 5,000,000 microseconds = 5 seconds). I've also added a small delay- without it, it seemed like the program was sleeping before the messages could be fired off. Not gonna worry about it for now!

If you upload this to your board, you should see the same output as before, but with the additional 'Going to sleep' message. Everything is going according to plan- now we need to connect some pins on the board to let it know when to wake up.

### Final Steps
1. Upload the new sketch to the ESP8266.
1. Connect pin 16 (D0) to RST.
{% asset_img sleep-pin-setup.png "Pin 16 (D0) connected to RST on an ESP8266"%}
1. Monitor the COM port to make sure that your script is going through its sleep cycles properly (consider using a shorter sleep interval while testing).
1. Disconnect the MicroUSB from the EPS8266.
1. Connect the discharge leads of the TP4056 to VIN/Ground on the ESP8266.

That should do it! The sketch should be running on battery power.

### "Finishing" the Project
I ordered a two-pack of small, plastic, waterproof cases for just such an occassion. They come with foam insulation to help keep everything in place. I removed one piece to make room for the components, but I could probably cut out room for each piece and make this a little fancier.

{% asset_img temp-sensor-inside.png "Battery-powered temperature sensor interior"%}

A small hole in the front of the cover was enough to push the temperature probe through. Looking back, I could've made a slightly smaller hole and fed the connectors through rather than going in the other way. Next time!

Because this will be outside, I want to add some sort of grommet or membrane to the sensor probe hole to keep it watertight. I haven't come up with a solution yet, so for now I've added a healthy dose of Saran Wrap.

Now that it's running, I've got it the data flowing into an AWS CloudWatch custom metric. A 5 minute interval seems to work fine for me, but realistically the water temperature isn't changing that often so I could make it 10 minutes or even hourly. I'll write up that side of the implementation soon!

{% asset_img cloudwatch.png "Graph showing lake temperature data over a 24 hour period"%}

Cheers!