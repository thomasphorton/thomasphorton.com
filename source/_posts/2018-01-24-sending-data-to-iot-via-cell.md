---
title: Sending Data to AWS IoT via Cell
date: 2018-01-24 19:40:55
tags:
---

In my [previous post](/building-a-smart-boat-intro), I outlined my basic setup to use a GPS module hooked up to the Raspberry Pi to send data to the AWS IoT service. That's great when I'm at home with a hardwired connection (or wifi!), but I need to find a way to keep everything transportable and wireless.

<!-- more -->

My requirements:
* Wireless
* Low power consumption
* Inexpensive data transfer cost

After an admittably short time searching, I found a really cool solution in [Hologram](https://hologram.io/). They offer a USB cell phone modem, specifically built for IoT projects like this. I ended up ordering the [Nova Global 3G/2G Cellular Modem](https://hologram.io/store/nova-global-3g-2g-cellular-modem) for $49. I also ordered an extra SIM card, which ended up being unnecessary- the Nova comes with one!

Developer pricing for Hologram seems pretty reasonable. The first 1MB/mo is free, and then you pay $0.60/MB after that. You can set Data Limits by the byte as well, which is great for preventing overages while experimenting.

![Hologram Nova Unboxing](https://media.giphy.com/media/xThtadqxWqdC0c18K4/giphy.gif)

## Using the Hologram Nova
The Nova couldn't be simpler to use. It comes with a plastic casing that you can snap around the board, and two different basic antennas that can snap on. The board takes U.fl/IPEX connectors, so you can rig up a better antenna, which I'll do once I start testing on the boat itself.

![Hologram Nova Assembled](https://media.giphy.com/media/xThta5eiQkVjmdZAgE/giphy.gif)

From there, the setup is straightforward. You need to SSH into your Pi and download a few libraries (the instructions are included in the kit). Once you do that, you can use the included Hologram library to send messages to Hologram's IoT service, which seems pretty robust. I had already done a lot of work on AWS though, so I needed to open up the modem to general internet traffic.

Fortunately, that's simple as well. The Hologram SDK comes with a command:

```
hologram connect
```

After running the `hologram connect` command, the blue status light on the Nano will turn on. This indicates that you've started a session and have access to the internet!

# WARNING

At this point, you're being billed by the megabyte for everything that gets sent to your Pi. Be careful to disconnect the modem with `hologram disconnect` before downloading any further project dependencies!

For reference, jQuery 3.3.1 alone is 84kb- you can quickly rack up a bill if you surf the internet with Hologram still connected!

## Best Pi Antenna Solution
It's not necessary for testing, but I wanted to make sure I beefed up the antenna on the modem and on the GPS receiver. Both have U.fl/IPEX connectors, so I bought a pack of [pigtail adapters](http://amzn.to/2GfWDza) and a couple of these [GPS antennas](http://amzn.to/2DGYHSy).

The antennas are waterproof (supposedly), so I'm planning on running them from the cabin out through a hole near the lazarette. I'll probably use velcro to attach them, since I've got a fiberglass hull.

## Next Steps
The fun part is next! We're going to do a trial run with the full wireless system.