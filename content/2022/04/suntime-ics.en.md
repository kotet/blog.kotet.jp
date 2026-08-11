---
title: "Generating ICS Files to Display Sunrise and Sunset Times on Google Calendar"
date: 2022-04-17
tags:
  - python
  - tech
---

I developed a tool to calculate sunrise and sunset times for any given location and generate files in a format compatible with Google Calendar.
This article documents the development process and provides usage instructions.

---

**Update**: Since this page appears to be getting some traffic, I've created a simplified ICS file distribution site for non-programmers.

[World and Japanese Sunrise/Sunset Calendar - ICS File Distribution](https://kotet.jp/suntime-ics-distribution/)

You can copy iCal calendar URLs for various regions. For example, Aichi Prefecture is available here:

[Sunrise and Sunset Times for Aichi Prefecture Office - ICS File Distribution](https://kotet.jp/suntime-ics-distribution/japan/23/)

To add these to Google Calendar, follow the "Adding a publicly available calendar using a link" instructions in the Google Calendar help documentation.


Here's the relevant link:

[How to Subscribe to Another User's Google Calendar - PC - Google Calendar Help](https://support.google.com/calendar/answer/37100)

---

### Background

Recently, I've noticed my mood and physical condition significantly deteriorate during bad weather or dark hours. The cost of staying awake during these periods has become prohibitively high, and what little productive work I can get done isn't worth the effort. Instead, most of my time is spent trying to distract myself with food and alcohol.
Therefore, I've resolved to adopt a sleep schedule that keeps me in bed when it's dark outside.

To achieve this, I needed to accurately track sunrise and sunset times. While I wanted to display this information in my regular Google Calendar, the existing solutions I found were somewhat unsatisfactory.
I did come across [what was quite close to my ideal solution](https://github.com/allanlaal/sunrise-calendar-feed), but it was no longer being maintained.

Left with no choice, I decided to create my own solution.

### Design Considerations

Google Calendar can parse the ics file format.
If you publish an ics file on the web, you can subscribe to it and add it to your calendar using the "Add by URL" feature.
This also supports automatic updates similar to RSS feeds.
Since it adds the calendar as a separate entity, managing visibility settings becomes straightforward.

You can import an ics file generated locally by "Importing" it, then add the events from that file to your existing calendar.
This feature appears to be designed for users switching from other calendar applications—rather than creating a new calendar, it simply adds events to your existing one.
If you make a mistake during this process or accidentally add a large number of incorrect events, undoing them could be quite challenging.
For my intended use case, I'd recommend creating a dedicated calendar for sunrise/sunset events and then importing the relevant data into it.


The existing service I mentioned above was written in PHP, which dynamically calculates sunrise/sunset times for the specified coordinates each time a request is made and generates the ics data.
It also appears to fetch time zone information based on the coordinates using Google's API.
The reason this service has stopped operating likely stems from the burden of maintaining a server to run PHP scripts and managing API permissions.
Given that this service had global demand, it must have received substantial traffic.
This approach of dynamically generating data proves to be unsustainable.

Learning from past failures, we should generate the data statically instead.
While we could set up a mechanism to periodically refresh the data and distribute updates, for personal use, generating the data once would suffice for several years, so we can consider automatic updates later when I'm more energetic.

### Implementation


With this in mind, we'll create a tool to generate ics files for sunrise and sunset times.
Since Python is well-known for being able to build anything by combining existing libraries, we'll write it in Python.
While this makes it incredibly easy to realize what I want to create with minimal effort, I'm somewhat concerned that it might lead me to stop properly writing programs from scratch.

For generating ics files, we can use the [ics](https://pypi.org/project/ics/) library.
For calculating sunrise/sunset times, we can use the [suntime](https://pypi.org/project/suntime/) library.
Combining these two libraries completes the implementation.

[^mp]: Meaning: "Serious Points"

### Completion

And so it's finally complete.

[kotet/suntime-ics-generator: A tool for generating ics files for sunrise and sunset times](https://github.com/kotet/suntime-ics-generator)


The generated data is written to standard output.
To make it easier for others to use, we've included several parameter options.
For example, suppose you want to calculate Tokyo Station's sunrise time and generate 400 entries ("SUNRISE" events) spanning 100 days prior to today through 300 days afterward.
After looking up Tokyo Station's latitude and longitude (35.6812405, 139.7649361), you would use the following command:

```console
$ poetry run python generate-calendar.py --disable-sunset --sunset-name="SUNRISE" --latitude=35.6812405 --longitude=139.7649361 --start-date-offset=-100 --end-date-offset=300 > tokyo-sunrise.ics
```

### Demo: Sunrise and Sunset Times for Nagoya

Below are the sunrise and sunset times I generated specifically for Nagoya Station.
These should differ by no more than about 10 minutes anywhere within Japan, so anyone who finds it difficult to use my tool should feel free to utilize it.

<iframe src="https://calendar.google.com/calendar/embed?src=hkskj9ernjar4s5quona33jj5o7h1gl8%40import.calendar.google.com&ctz=Asia%2FTokyo" style="border: 0" width="800" height="600" frameborder="0" scrolling="no"></iframe>

