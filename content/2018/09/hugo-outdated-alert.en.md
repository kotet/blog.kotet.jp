---
title: "Display Warnings for Outdated Articles"
date: 2018-09-19
tags:
- hugo
- tech
---

This blog contains various articles I've written since 2016.
Some were written while still learning the necessary prerequisites, and others were composed during periods of poor health when my mental state wasn't at its best.
There are also likely some articles with outdated information that have slipped through the cracks without anyone noticing.

Recently, I enhanced this blog's tag functionality, which significantly improved searchability and made it easier to find older articles.
While many old articles would ideally be deleted periodically,
my fundamental policy is to refrain from removing any records whenever possible.
To maintain my own peace of mind, I've decided to include disclaimers for such articles.

Therefore, this article is for those using Hugo-generated sites who would like to implement the "This article was last updated more than n years ago" notice similar to what Qiita provides.

Searching for "hugo outdated article warning" didn't yield any relevant results.
I'm hoping that anyone with similar search sensibilities will find this article useful.

### Hugo Template

Below is a template that only activates for articles older than one year. You can either embed the code directly or create a partial template for it.

```html
{{ if gt (now.AddDate -1 0 0) .Date }}
<!-- Insert your HTML content here as desired -->
{{ end }}
```

### Date and Time Comparison in Hugo

Initially, I considered writing an if statement that subtracts the current date from the post date and checks if the difference exceeds one year. However, based on my research, there doesn't appear to be any direct method to convert dates into absolute time units like years or days.

However, I found the `AddDate` function.
This function takes a specified year, month, and day and adds it to the given date. By using `now.AddDate -1 0 0`, it effectively subtracts one year from the current date,

meaning it subtracts one year.
Since date comparisons work perfectly with `gt`, I constructed the condition:
"Is the current date minus one year greater than (newer than) the post date?"

As a result, articles older than one year from the current date (the date the site was generated) will now include a warning notice.
This should help keep older articles from being deleted and ensure they remain accessible.
