---
title: registering-a-thing
tags:
---

## Register a Thing
Previously, my device was unregistered- I had only generated and loaded certificates onto it, and was just publishing and subscribing to messages. In order to use Shadows, you need to actually register your Thing with AWS IoT. This is something that you should be doing anyway, as it unlocks a lot of powerful features.

To register a new Thing, head to the AWS IoT Core Console and click `Manage -> Things`, and then click the Create button, followed by 'Create a single thing'.

Give your new Thing a name, in my case I chose `led-lightstrip-1`.

Next, we want to give our new Thing a type. If this is your first time in this part of AWS IoT, we'll need to create that first. Types are a way of templating searchable attributes for Things, as well as how you set tags for devices, since you currently can't attach tags directly to Things.

I named my Thing Type `led-lightstrip`, and adding my usual project tags. Click 'Create thing type' to head back to the Thing creation screen.

The next step to add Thing Groups- thing groups **also** allow management of tags and attributes. I haven't dove into when it's appropriate to set tags via Groups as opposed to Types, but it is worth noting that a Thing's Type is set at creation and can't be changed, but its group can be changed at any point and groups can contain different Types.

Anyway, it's not needed for now, so I've skipped it in my current design. Click 'Next' to proceed to certificate generation.

The most straightforward option for this use case is 'One-click certificate creation', so choose that. If everything worked properly, you'll see a green 'Certificate created!' message, and links to download 3 different files. Download each of the files, along with the root CA. Once downloaded, click 'Activate' to activate the certificates.