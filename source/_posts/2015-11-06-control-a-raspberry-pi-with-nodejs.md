---
title: Control a Raspberry Pi with Node.js
date: 2015-11-06 19:40:55
---

In the last few years, I’ve ended up with a Raspberry Pi, Arduino, and a handful of LEDs and other gizmos that have been sitting in a box under my desk. All of the new AWS IoT announcements piqued my curiosity again, and I finally found the time to sit down and play with my toys. I wanted to put my web dev knowledge to work, so I figured I’d learn to control the Raspberry Pi with Node.js.

<!-- more -->

## Create a Circuit with an LED
### Materials
- [ ] [Raspberry Pi](http://amzn.to/2CZ7Lzy)
- [ ] [Breadboard](http://amzn.to/2CI313j)
- [ ] [LED](http://amzn.to/2GiqlUf)
- [ ] [Resistor](http://amzn.to/2GjK6L5) (TODO: What size was this?)
- [ ] 2 [Male to Female Jumper Wires](http://amzn.to/2EbOKdN)

### Code
- [raspberry-pi-gpio-webserver](https://github.com/thomasphorton/raspberry-pi-gpio-webserver)
 
Read through this first, because you can ruin an LED pretty easily if you put anything in the wrong order.

A basic circuit on a breadboard with a resistor before an LED
Red (-) -> Resistor -> LED -> Black (+)

All the Raspberry Pi is doing at this point is acting as a power source. Create a basic circuit by connecting a jumper from Pin #1 (3.3v) -> Resistor -> LED -> Pin #6 (GND). The LED should stay lit. If the LED gets bright and then turns off, you didn’t put the resistor before the bulb and you burnt it out. If the LED never lit, it’s in backwards. The longer end should be on the negative side- the side the resistor is on.

## Control the Raspberry Pi with Node.js
Before I could even worry about the pins, I spent a bunch of time working on basic Unix permissions and updating node/npm. I can’t find the documentation right now, but there was also an issue where the node binary is actually called nodejs on Ubuntu, so I had to install a package called nodejs-legacy that either provided a new binary or corrected some symlinks. It was all a blur, sorry.

The second hurdle was setting up permissions to affect the actual pins. I found the [quick2wire-gpio-admin repository](https://github.com/quick2wire/quick2wire-gpio-admin) and gave it a shot. I ended up having to edit gpio-admin.c and recompile. My diff:

```
TODO: Figure out what this was
```

Each pin is controlled by placing files in certain paths, and at some point they changed the path and this repo never caught up. There are open PRs on GitHub, but it doesn’t look like anyone’s maintaining it any more.

Once that was done, I added my $USER to the gpio-admin group and wrote a test script. I used the npm library [rpi-gpio](https://github.com/JamesBarwell/rpi-gpio.js) because it seemed to have more support than pi-gpio and a little better support for asynchronous events.

```
var gpio - require('rpi-gpio');
var pin = 11;

gpio.setup(pin, gpio.OUT, function() {
	gpio.write(pin, true, function(err) {
		if (err) throw err;
	});
});
```

Attach the negative lead to Pin #11 (GPIO 17) and run the test script. I’m still trying to figure out some permissions issues, so this only runs for me with sudo, so my command ends up being `sudo node rpi-gpio-test`. The light should come on.

## Control the Raspberry Pi with a Phone
The next step is to set up a web server. You can check out my [GitHub Repo](https://github.com/thomasphorton/raspberry-pi-gpio-webserver) to see where I’ve taken it. I used expressjs to spin up a quick server, and started setting up a basic API. Right now I’m just using basic HTTP GETs to toggle the light on and off, but there really isn’t an end in sight as far as what you can do here. I’ve been doing a little bit of Swift/iOS, so a dummy app for my phone would be a cool party trick (I’m terrible at parties).

I use screen to run the express server so I can close my SSH terminal and the server will continue running.

```
screen sudo node app
```

You can then access the web server by determining the Pi’s local IP (run `ifconfig` on the Pi and look for the inet adds line under wlan0). Combine that with the port number your express app is running on and you should be able to access the front-end- for example, I can access mine at http://192.168.0.105:3000. Make sure your phone is connected to the same network as the Raspberry Pi, navigate to your bootstrapped UI, and start toggling lights!