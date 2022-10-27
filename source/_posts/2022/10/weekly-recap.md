---
title: 'Weekly Recap: 10/27'
date: 2022-10-27 12:00:00
tags:
  - weekly recap
  - F1
  - nodejs
  - computer vision
---

# What I did
## Tech
* Started F1 Telemetry Streaming project
    * stream data from F1 game -> nodejs UDP server
    * nodejs publishes to Ably (pub/sub PaaS)
    * twitch extension subscribes to messages from Ably and displays them
    * issues: CSP for twitch extensions and loading external JS

* Built a [edge detection demo](https://github.com/thomasphorton/edge-detection-audit) for auditing results of manual data labelling.
    * Used [scale.com](https://scale.com/image) results
    * Cropped bounding box images from the original image
    * Detected edges in the image by applying a convolution matrix.
    * Determined if there was useful information in the image by counting values of edge pixels.

Original:
{% asset_img one-way-original.jpg "Unprocessed image of a one-way sign" %}

Edge Detected:
{% asset_img one-way-edge-detected.jpg "Results of edge detection convolution matrix on an image of a one-way sign" %}

## House
* Cleaned off deck
* Prep for shower build

# What I'm gonna do
* Writeup for F1 Streaming project
* Work on F1 Telemetry Twitch Extension
    * Start with web app portion