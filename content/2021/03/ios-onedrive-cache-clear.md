---
title: "iOS版OneDriveアプリのキャッシュを削除する"
date: 2021-03-30
tags:
- log
---

iOS版OneDriveアプリは、ダウンロードしたファイルをキャッシュする。
通常なら便利なのだが、このキャッシュはかなり時間が立ってもずっと保持され続けている。
なので動画等の大きなファイルをOneDriveに置いて、
適宜ダウンロードして閲覧するような使い方をしているとどんどんキャッシュが溜まっていき数十GBにもなる。
これでiPhoneのストレージがかなり圧迫されて困っていた。

軽く検索してみても古い情報しかなく、定期的にアプリを再インストールするくらいしか解決策がなかった。
今日キャッシュクリアの方法を発見したので記録しておく。

### キャッシュクリア

SettingsのHelp & FeedbackにClear Cacheボタンがある。
これを押すとキャッシュが消去される。

なんでHelp & Feedbackに置いてあるんだろうか？

![](/img/blog/2021/03/onedrive-settings.png)

![](/img/blog/2021/03/onedrive-help-feedback.png)

![](/img/blog/2021/03/onedrive-clear-cache.png)