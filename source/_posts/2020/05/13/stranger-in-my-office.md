---
title: Strangers in my Office
tags:
  - iot
  - product design
date: 2020-05-13 12:00:00
---

For the last few days, strangers have been coming into my office and turning the lights on and off.

On Tuesday, I launched a [Light Control Application](https://master.d26o79twe1anbe.amplifyapp.com/) that allows complete and total strangers to control a [roll of LEDs](https://amzn.to/2Z0jHOv) on my desk. The app has an embedded [Twitch stream](https://www.twitch.tv/thomasphorton) so that you can watch the antics in real-time (for now).

In this post, I won't be going into the technical details of the application- instead, I'm going to talk about how I read signals from my audience to determine my product roadmap.

<div class="twitter-embed-wrapper">
    <blockquote class="twitter-tweet"><p lang="en" dir="ltr">Proof of life <a href="https://t.co/N9dG5VyTr2">pic.twitter.com/N9dG5VyTr2</a></p>&mdash; Tom Horton (@thomasphorton) <a href="https://twitter.com/thomasphorton/status/1259923419254132743?ref_src=twsrc%5Etfw">May 11, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>

<!-- more -->

## The Initial Plan
[I’ve been working on and off (that’s a light switch joke) on controllable LEDs for the past few months](/2020/02/02/weekly-recap-temp-sensor-and-leds/). My original goal was to create my own version of the [Philips Hue LightStrip](https://amzn.to/3cyETyU): a flexible RGB LED strip, as well as an application to controls it. The first thing I did was knock out the [device firmware](https://github.com/thomasphorton/esp8266-lights), and after that I began working on the application to control the lights, as well as management features such as adding and removing new devices.

## The Pivot
Halfway through writing the app, I got the urge to show off what I was building. At this point, I hadn’t figured out the authentication portion of the story- users had to create an account, but once they were logged in they had access to every registered device, not just the ones associated with their account. It’s relatively straightforward to implement that functionality, but before building it I wanted to the lack of restrictions as an opportunity to have some friends play with the lights while we were on a Zoom call.

After sharing the controls with a few people, I decided to show off what I had built a little bit. I shared the link on Twitter and had a few people sign up and flip the lights, but they had no way of knowing that things were actually changing on my end. Although I’d post video clips of the lights changing, it was a pretty boring experience.

<div class="twitter-embed-wrapper">
    <blockquote class="twitter-tweet"><p lang="en" dir="ltr">want to annoy the shit out of me today? Control the LEDs at my desk with this Amplify app that I plugged in to AWS <a href="https://twitter.com/hashtag/IoT?src=hash&amp;ref_src=twsrc%5Etfw">#IoT</a><br><br>This link will last until a) I figure out locking down devices to certain users or b) I go crazy and nuke it<a href="https://t.co/MYNcToRKE4">https://t.co/MYNcToRKE4</a> <a href="https://t.co/W0ogiieyis">pic.twitter.com/W0ogiieyis</a></p>&mdash; Tom Horton (@thomasphorton) <a href="https://twitter.com/thomasphorton/status/1259821879055069184?ref_src=twsrc%5Etfw">May 11, 2020</a></blockquote>
</div>

I mentioned it to my friend Austin, who immediately had an idea that made a ton of sense- set up a live stream of the lights so people could see what they’re doing! I scrambled to set up Streamlabs and create an interesting scene on my desk with the lights and a few succulents. I set up a few chat commands to drop links in Twitch chat and hit the big “Go Live” button. Fame awaits!

<div class="small-image-wrapper">
    {% asset_img twitch-stream.png "Twitch stream with LEDs and succulents"%}
</div>

## Optimizing the Product (Reading Signals)
It wasn’t long before I got my first bit of feedback. An old colleague entered the stream, said hello, asked a few questions, and then balked at the idea of creating an account. At first I was a little offended- but then I looked at the Cognito User Pool handling the accounts- 8 users.

I checked Twitter analytics- 75 link clicks.

Quick maths- only 10% of my visitors were creating an account to play with the lights. At this point, I didn’t have any actual on-page analytics, so I was working in the dark as to why the conversions were so low. I had some other clues to support the idea that creating an account was an issue:

<div class="twitter-embed-wrapper">
    <blockquote class="twitter-tweet"><p lang="en" dir="ltr">oof, why gotta do 2-step opt-in?</p>&mdash; Richard H. Boyd - Boston (@rchrdbyd) <a href="https://twitter.com/rchrdbyd/status/1259903522780348418?ref_src=twsrc%5Etfw">May 11, 2020</a></blockquote>
</div>

1. Manually verifying user accounts with fake email addresses- in hindsight, this was a dead giveaway. My first two users signed up with fake email addresses- “mail@gmail.com”, and “PJtheDOG@gmail.com” (our goldendoodle is PJ and as far as I’m aware, he doesn’t have a gmail account).
2. My tweet received multiple replies pointing out issues in the Auth flow- one person didn’t get an ‘incorrect password’ notification, another didn’t realize that they needed to confirm their email addresses. I was using the stock Amplify React Auth modules so none of that was really my fault… but those were real people voicing real concerns. I was annoyed that they were commenting on the “small things” and not about the really cool lights that I had built, but again- I only had 8 confirmed users and there were 2 people, right there, asking to be let in!

### The Auth had to go.

There’s nothing inherently wrong with the Amplify authentication. Almost every real-world application needs some sort of authentication and authorization when dealing with an API. I’m the broken one here- I wanted everyone to hit my API.

Amplify Auth was the happy path forward from a development perspective- the Amplify API library defaults to assuming that you’re using the Auth module, and tearing it out involves changing a few settings, tweaking the GraphQL schema, and a few other things that I’m still not sure were necessary. It took me a lot of trial and error before I eventually asked for help on Twitter, and Jeff Loiselle came in, like a knight in shining armor, to save the day.

<div class="twitter-embed-wrapper">
    <blockquote class="twitter-tweet"><p lang="en" dir="ltr">When I was trying to allow anonymous access, I also had to set up IAM auth, and then allow Cognito unauthenticated identity permission.<br><br>But I struggle with this all the time.<a href="https://t.co/rpXJDruztk">https://t.co/rpXJDruztk</a> <a href="https://t.co/vuSgE7ZjBc">pic.twitter.com/vuSgE7ZjBc</a></p>&mdash; Jeff Loiselle (@phishy) <a href="https://twitter.com/phishy/status/1260220329986793479?ref_src=twsrc%5Etfw">May 12, 2020</a></blockquote>
</div>

With his help, I was able to fully remove the Auth flows from my app, and open it up to the world. I tweeted out an update and immediately saw an uptick in activity on the lights and in the stream. More people were stopping by to flip the lights on and off!

### I’m not quite sure what I’m looking at…

At this point, the app had the light controls, and a link to the Twitch stream below. This made perfect sense to me, on my laptop. I had two browser windows open, one on the Twitch stream, the other on the app. I could easily control the lights and watch the stream at the same time. Looking good!

Leave it to my cousin Pete to hit me with the hard truth. I sent him a link to the app via text with a little explanation of what it did.

<div class="small-image-wrapper">
    {% asset_img pete-text.jpg "Text message: not quite sure what Im looking at..."%}
</div>

He followed it up with a screen shot, and it dawned on me- mobile users don’t really have the same options as far as viewing two browser windows side-by-side. 

<div class="small-image-wrapper">
    {% asset_img mobile-no-twitch.jpg "Screenshot of the app: no livestream embed, just a link"%}
</div>

Although I had shared it with him via text (guaranteeing that he was viewing it on mobile), I hadn’t considered that I was primarily sharing my link through Twitter, a **very** mobile-focused application. It was time to embed the stream and focus on a more mobile-friendly layout!

<div class="small-image-wrapper">
    {% asset_img mobile-with-twitch.jpg "Screenshot of the app: the livestream is embedded within the page"%}
</div>

Again, after making the changes, I perceived an uptick in activity on the lights. We’re doing real important work here, people.

## Where do we go from here?
To be honest? I don’t know. I can’t keep the live stream up forever. I might try and spike some traffic a few more times. These projects scratch an itch for me- there’s something addictive about building a product out with real-time feedback, especially with such a strong community around me. I couldn’t have done it without the helpful (and highly sarcastic) help from so many people, including but not limited to:
* [JP ](https://twitter.com/jpdel): lead QA/button pusher
* Pete: customer experience bar raiser
* Austin: marketing strategy
* [Richard](https://twitter.com/rchrdbyd): product roadmap/vision
* [Jeff](https://twitter.com/phishy): actually knows how this stuff works and isn’t a hack like me

## Want more?
Follow me on [Twitter](https://twitter.com/thomasphorton)! Smash that follow button on [Twitch](https://www.twitch.tv/thomasphorton)! Write a comment below!! I'll be doing a writeup on the actual tech behind this solution shortly- there's a lot of cool stuff to talk about. I'd love to hear what **you** think is interesting!