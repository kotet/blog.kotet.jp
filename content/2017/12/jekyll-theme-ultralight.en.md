---
date: 2017-12-27
aliases:
- /2017/12/27/jekyll-theme-ultralight.html
title: "Ultralight: A Ultra-Lightweight, IPFS-Compatible Responsive Jekyll Theme"
tags:
- jekyll
- ipfs
- tech
excerpt: "I came across CNN's low-bandwidth text-only site [lite.cnn.io](http://lite.cnn.io/). It's incredibly lightweight. Yet it perfectly incorporates all the necessary elements for comfortable news browsing—in fact, it might be more user-friendly than the original [CNN](http://edition.cnn.com/) with its various additional features."
image: /assets/2017/12/27/twitter.png
---

I recently visited CNN's text-only low-bandwidth site [lite.cnn.io](http://lite.cnn.io/).
It's remarkably lightweight.
Yet it delivers all the necessary components for comfortable news consumption—in fact, it may even be more intuitive than the original [CNN](http://edition.cnn.com/) with its various additional features.

My own site had been using a Jekyll theme based on the [Minima](https://github.com/jekyll/minima) framework.

True to its name, it's quite minimalistic—but after seeing lite.cnn.io, even this theme started feeling excessive to me.
Visitors to my site aren't primarily interested in the page lists that transform into hamburger menus based on screen width—what they really want is the articles themselves, primarily their plain text content.

Moreover, considering my intention to eventually host the entire site on IPFS, using a theme that doesn't account for IPFS's unique requirements would be problematic.
Currently, IPFS treats the same content differently depending on domain and path—for example, as `ipfs.io/ipns/ipfs.io`, `ipfs.io/ipfs/QmQrX8hka2...`, or `localhost:8080/ipfs/QmQrX8hka2...`.
To ensure compatibility across all these environments, internal links would need to be kept as relative paths.
Using an existing theme would require manually locating and modifying all internal content URLs.

That's when I turned to [lite.cnn.io](http://lite.cnn.io), [Motherfucking Website](http://motherfuckingwebsite.com/), and

[Better Motherfucking Website](http://bettermotherfuckingwebsite.com/) as references, creating the Jekyll theme "ultralight" as a result.
Currently, this site is using this very theme.

### What We Removed and What We Kept

Various elements were removed from the old site.

For instance, the share button cluster—which had been optimized to load only when explicitly requested, significantly reducing load times.
But since even I didn't use most of these features, I decided to remove them entirely.
Users can simply use bookmarklets or browser-native sharing functions anyway, and I'd have ignored the share buttons even if they were there.

The styling has also been kept to an absolute minimum.
Even when combined, it doesn't add up to much—I actually experimented with embedding everything directly in HTML,
thinking it might meet the [ATF content requirement of under 14kb](https://developers.google.com/speed/docs/insights/mobile?hl=ja)
without needing to implement lazy loading.

Additionally, the header and footer lines use `<hr>` elements rather than `border` properties.
This ensures consistent rendering across text-based browsers like [Lynx](https://ja.wikipedia.org/wiki/Lynx_(%E3%82%A6%E3%82%A7%E3%83%96%E3%83%96%E3%83%A9%E3%82%A6%E3%82%B6)).
In fact, when I tested this recently, I was genuinely surprised by how perfectly it rendered.

![Screenshot](/assets/2017/12/27/lynx.png)

We retained center-aligned content, width constraints, and code block syntax highlighting.
These were essential to maintain—omitting them would create viewing frustration, and it would be difficult for users to compensate.

### Results

By carefully selecting only the minimum essential elements from scratch, we achieved a PageSpeed score of 100 for the ultralight demo page—using GitHub Pages alone.

Important note: These results are based on a demo page with minimal content.

![Screenshot](/assets/2017/12/27/pagespeed.png)

Furthermore, when measuring Speed Index using [www.webpagetest.org](https://www.webpagetest.org), we obtained results falling between Abe Hiroshi's website and google.com.

Even on dial-up connections, the first-view content loads in under a second. [View the test results](https://www.webpagetest.org/result/171227_Y6_52a1bff263c001164ab06ffb530567c2/).

| abehiroshi.la.coocan.jp/ | google.com | kotet.github.io/ultralight/ | kotet.github.io |
|--------------------------|------------|-----------------------------|-----------------|
| 258                      | 631        | 300                         | 351             |

Abe Hiroshi's site is simply too powerful...

### IPFS

All internal links use relative URLs.
Plans are underway to establish a continuously operational IPFS node around next year, at which point this site could easily be hosted on IPFS without requiring any special configuration.
One concern remains: how trackers and advertisements will behave on IPFS.
At the very least, both Google Analytics and A-ads don't appear to be designed with sites accessible across arbitrary domains in mind.

### Jekyll Themes

ultralight is currently under consideration for inclusion in [Jekyll Themes](http://jekyllthemes.org/).

