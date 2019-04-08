---
title: "iPhoneが再接続できないときの対症療法"
date: 2018-09-25
tags:
- linux
- tech
excerpt: "古すぎず、新しすぎでもないPCにはUSBポートが当然のようについているものだ。
自分のほぼLinux機としてしか使っていないDELL XPS 13 (9360)にもUSBポートが2つついている。"
---

古すぎず、新しすぎでもないPCにはUSBポートが当然のようについているものだ。
自分のほぼLinux機としてしか使っていないDELL XPS 13 (9360)にもUSBポートが2つついている。
このラップトップはバッテリー容量がかなりあるので、
USBデバイスをつないだ程度ではほとんど残り使用時間に影響がない。
というわけで最近は高級モバイルバッテリーとしても使われつつあるラップトップである。

### iPhoneを再接続しても認識しない

しかしひとつ問題がある。
時々つなぎ直しても充電ができなくなるのだ。
一度ケーブルから端末を外して、もう一度つなぐと反応がない。
気づいたら全く充電されていないなんてことが多々あるので困っていた。

USBのオートサスペンド機能が悪さをしているのかと思って無効にしてみたりしたが効果がない。
一度ケーブルを抜くと、再起動するまでそのポートが「つぶれて」しまうのだ。
ずっと困っていたのだが、とりあえず再起動しなくていい解決法を見つけられたので書き残しておく。

### usbmuxdの再起動

[Connecting iPhone to Linux PC via USB cable works only once - Super User](https://superuser.com/questions/1257911/connecting-iphone-to-linux-pc-via-usb-cable-works-only-once)

`usbmuxd`を再起動すれば認識してくれる。

```console
$ sudo systemctl restart usbmuxd.service
```

完全に対症療法だが、毎回OS全体を再起動するよりはいいだろう。
