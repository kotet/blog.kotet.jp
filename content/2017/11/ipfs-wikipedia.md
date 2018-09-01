---
date: 2017-11-29
aliases:
- /2017/11/29/ipfs-wikipedia.html
title: "IPFS体験記9:Wikipediaミラープロジェクト"
tags:
- ipfs
- tech
- ipfs体験記
excerpt: "IPFS上にWikipediaを構築することにより政府がWikipediaをブロックするのを妨害するというプロジェクトがある。今回はそれに参加してみる。"
---

IPFS上にWikipediaを構築することにより政府がWikipediaをブロックするのを妨害するというプロジェクトがある。

[Uncensorable Wikipedia on IPFS](https://ipfs.io/blog/24-uncensorable-wikipedia/)

今回はそれに参加してみる。

### リポジトリの拡張

それなりに大きなディスク容量（トルコ版で10ギガバイト、英語版で250ギガバイト）が必要なので、少しリポジトリを拡張する。
29ギガバイトのストレージが落ちていたのでそれを使う。

#### config

```diff
-     "StorageMax": "2GB"
+     "StorageMax": "29GB"
```

### 保存する

早速Pinしてみる。
最新版のハッシュは[こちら](https://github.com/ipfs/distributed-wikipedia-mirror/blob/master/snapshot-hashes.yml)にある。
執筆時点でトルコ語版のハッシュは`/ipfs/QmT5NvUtoM5nWFfrQdVrFtvGfKFmG7AHE8P34isapyhCxX`である。

Pin前にサイズを知る方法はないのだろうか？

```console
$ ipfs pin add QmT5NvUtoM5nWFfrQdVrFtvGfKFmG7AHE8P34isapyhCxX --progress
```

ディスクがすごく遅いのと、提供ノードがあまり多くないのが原因でかなり時間がかかる。

### 見てみる

執筆時点でも終わっていないが閲覧は問題なく行える。

ページ右上に検索窓があるので、とりあえず日本を検索してみる。

![スクショ](/assets/2017/11/29/search.png)

初回は少し時間がかかるが問題なく使用できる。
どうもJavascriptを使い完全にクライアントサイドで動いているように見える。

自分はトルコ語を使えないので特に何もできることがない。
というわけでこの記事はここで終わりである。
