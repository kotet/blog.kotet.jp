---
date: 2024-02-05
title: "Creating a Night-Only Colab Notebook to Pursue Green Software Principles"
tags:
    - python
    - technology
image: /img/blog/2024/02/cover.png
highlights:
    - python
---

A new book titled "Building Green Software" is set to be published.

[Building Green Software [Book]](https://www.oreilly.com/library/view/building-green-software/9781098150617/)


I watched a video of Sara Bergman, one of the book's authors, delivering a lecture on Green Software principles.

## What is Green Software?

<iframe width="560" height="315" src="https://www.youtube.com/embed/_lYT-knNMTI?si=ba1Z_UT10cQ3jn6s" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

The main points from the lecture that directly relate to software development are as follows:

- Given the rapid increase in global carbon dioxide levels, we need to actively reduce CO2 emissions from our software as well.

  - Here, "Carbon" refers to greenhouse gases converted to CO2 equivalent values (carbon dioxide equivalent, CO2e).
- She is a founding member of the Green Software Foundation (established May 2021) and participates as an individual contributor.
- Green Software is defined as software that minimizes carbon emissions:
  - Improving software's power efficiency by optimizing code and operational practices to reduce energy consumption.
  - Improving hardware's power efficiency by extending product lifespan, ensuring hardware compatibility, and reducing environmental impact during manufacturing.
  - Being mindful of carbon intensity. Since carbon emissions per unit of electricity vary by time, using power during periods with lower environmental impact is advisable.
- We introduce software carbon intensity (SCI) as an indicator, calculated by multiplying energy consumption by the carbon intensity of the electricity used.

  - SCI = Σ (energy consumption) * (carbon intensity of electricity at that time) + （carbon emissions from hardware operation)

The Linux Foundation appears to offer a course on Green Software. While the cover is in Japanese, I wonder if the entire course content is also available in Japanese?
Since it's free, I think I'll consider taking it later.

[Green Software Training for Practitioners | Linux Foundation](https://training.linuxfoundation.org/en/training/green-software-for-practitioners-lfc131/)

## Considering Practical Applications

I've personally always been interested in systems that operate efficiently with limited resources. I've previously explored various approaches to this.
I've also considered whether it might be possible to develop programs that run during periods when electricity has lower carbon intensity.
The presentation featured several real-world examples of such systems.

- Windows 11 collects carbon intensity data and schedules update installations during times of lower carbon emissions.

  - [Windows Update Now Carbon-Aware - Microsoft Support](https://support.microsoft.com/en-us/windows/windows-update-now-carbon-aware-a53f39bc-5531-4bb1-9e78-db38d7a6df20)
- An iPhone feature that schedules charging during times when environmental impact is lower. Available only in the U.S.
  - [Use Clean Energy Charging on your iPhone - Apple Support](https://support.apple.com/en-us/108068)
- An Xbox feature that schedules updates during times when environmental impact is lower.
  - [Xbox Becomes the First Carbon-Aware Console - Update Rolling Out to All Users Soon - Xbox Wire](https://news.xbox.com/en-us/2023/01/11/xbox-carbon-aware-console-sustainability/)

In these examples, scheduling is implemented by referencing actual carbon intensity data. However, as the iPhone feature is explicitly noted as only available in the U.S., real-time carbon intensity data is only accessible in limited regions.

Living in Japan, even after thorough research, I was unable to find a reliable method.

One relatively stable trend to consider is that daytime charging typically involves lower carbon emissions per unit of electricity due to greater utilization of solar power. Of course, solar power generation percentages vary by region and are significantly affected by weather conditions. Additionally, in regions with nuclear power generation capabilities, nighttime when total demand is lower may actually have lower carbon emissions. Nevertheless, this remains a relatively effective criterion for universally applicable decision-making. I'd like to see even more reliable and user-friendly methods become available...

For this reason, at least we should aim to avoid running programs that consume significant power during nighttime hours.

## Google Colab Notebook for Determining Instance Operation Hours


Among my power-intensive activities, using GPU instances on Google Colab is particularly noteworthy. I perform tasks such as image generation and audio transcription. Before running GPU-intensive Notebooks, I've added a cell to estimate the time zone of the instance's location and automatically pause operations if it's nighttime. By including the following cell at the notebook's beginning, it will continue running normally between 8 AM and 4 PM local time. For all other times, the instance will be terminated.

When operations are interrupted, options are limited. Since the instance's operating region is randomly assigned (or likely a region with available resources), waiting about 30 minutes and retrying may result in execution on a different region. However, there's also the possibility that you might accidentally get caught in nighttime operations and never escape the evening time zone.

Considering this rough "run during daytime" policy, there's no need to force things too much. For those urgent situations where immediate execution is required, I've prepared a `IGNORE_DAYTIME` variable. If set to True, the time check will be bypassed.

```python
!pip install pytz

IGNORE_DAYTIME=False

import requests
from datetime import datetime
import json
import pytz

def is_daytime(verbose: bool):
  API_ENDPOINT = "https://ipinfo.io/json"
  response = requests.get(API_ENDPOINT)
  if response.status_code != 200:
    raise Exception(f"{response.status_code} from {API_ENDPOINT}")
  timezone_name = json.loads(response.content)["timezone"]
  timezone_info = pytz.timezone(timezone_name)
  local_time = datetime.now(timezone_info)
  if verbose:
    print(f"timezone: {timezone_name} - {local_time}")
  hour = local_time.hour
  return 8 <= hour and hour <= 16

if not IGNORE_DAYTIME and not is_daytime(verbose=True):
  print("It's nighttime, exiting.")
  from google.colab import runtime

  runtime.unassign()
```

The implementation works by using `ipinfo.io`, an IP geolocation service, to retrieve the estimated timezone of the instance's location. The `ipinfo.io` API returns timezone names like `Asia/Tokyo`, so we use `pytz` to obtain the UTC offset. If the local time falls between 8 AM and 4 PM, execution continues normally. Otherwise, we use `google.colab.runtime.unassign()` to terminate the instance.

The `import` statements are placed within an if statement to minimize startup overhead and reduce the load on the time check itself. Additionally, this prevents a known issue where `print` statements followed by immediate `unassign` calls sometimes fail to display messages. Initially I tried using `time.sleep`, but Python's import process is notoriously slow - even with this optimization, the check succeeded only about 70% of the time.

While we want to keep this cell's execution time as short as possible, the `import` statements remain the bottleneck.

Re-downloading libraries just to retrieve a UTC offset is particularly inefficient. Since this implementation prioritizes being copy-paste-ready anywhere, it took this form. However, using more feature-rich IP geolocation services with proper registration might improve efficiency further.

When executed, this cell produces output similar to the following:
First output when hitting a daytime region:

```
Requirement already satisfied: pytz in /usr/local/lib/python3.10/dist-packages (2023.4)
timezone: Asia/Singapore - 2024-02-06 14:58:10.596164+08:00
```

Next output when hitting a nighttime region:

```
Requirement already satisfied: pytz in /usr/local/lib/python3.10/dist-packages (2023.4)
timezone: America/New_York - 2024-02-06 02:16:52.692341-05:00
It is night, exiting.
```

For now, this represents about the extent of what can be done with Google Colab. If anyone knows of a good method for obtaining carbon intensity data for power grids when running locally on a Japanese computer, please let me know.

