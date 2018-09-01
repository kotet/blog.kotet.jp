---
date: 2017-10-20
aliases:
- /2017/10/20/ipfs-browser-extention.html
title: "永続Web、IPFS体験記3:ブラウザ拡張1"
tags:
- ipfs
- tech
- log
- ipfs体験記
excerpt: "ブラウザ上でのIPFSの使用を補助する目的で作られたブラウザ拡張が存在する。
公式のものはFirefoxにも対応しているようだが、ここではChrome版についてのみ述べる。
今日はあまり体調が良くないが、だからこそあまり頭が記憶を整理してくれないため、記憶を外に書き出しておかないとそれだけで一杯になってしまうので少しだけ書く。"
---

ブラウザ上でのIPFSの使用を補助する目的で作られたブラウザ拡張が存在する。
公式のものはFirefoxにも対応しているようだが、ここではChrome版についてのみ述べる。
今日はあまり体調が良くないが、だからこそあまり頭が記憶を整理してくれないため、記憶を外に書き出しておかないとそれだけで一杯になってしまうので少しだけ書く。

まず、Chrome ウェブストアで"ipfs"と検索すると執筆時点で3つほどのChrome Extentionが出てくる。
そのうち[IPFS Companion](https://chrome.google.com/webstore/detail/ipfs-companion/nibjojkomfdiaoajekhjakgkdhaomnch)
というのが公式の拡張機能である。

以下、機能を見ていく。

### リダイレクト

IPFSパブリックゲートウェイへのリンクがあると、自動的にローカルゲートウェイにリダイレクトしてくれる。
たとえば[最初に見たreadme](https://ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme)は次のようなURLをしている。

```
https://ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme
```

上記のURLにアクセスすると次のようにローカルのゲートウェイを使うよう書き換えられる。

```
http://127.0.0.1:8080/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme
```

IPFSのゲートウェイのURLは必ず`<ゲートウェイのアドレス>/ip[nf]s/...`という形を取るため、機械的な書き換えも容易なのだ。
これならパブリックゲートウェイが閉鎖されてもリンク切れを起こすことはないだろう。
これからIPFS内にあるコンテンツへのリンクは普通にパブリックゲートウェイを使ったものを書くことにする。

逆にIPFSデーモンを使っていない人ならば、この拡張機能を使ってローカルゲートウェイ用のURLを適当なパブリックゲートウェイに書き換えるように設定することもできるのだろうか？

### アドレスのコピー

アドレスバーのアドレスは上記の機能によって書き換えられるため、そのままコピペするとローカルゲートウェイや書き換えの拡張機能を使っている人しかアクセスできない。
そこでアドレスのコピー機能がある。

アドレスの形式には2種類あり、まず1つはCanonical Adressである。

```
/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme
```

現在はこの形式のアドレスに対応しているのはコマンドラインツールくらいだが、最終的にはこの形式で様々なツールがIPFSのリソースにアクセスできるようにする予定なのだろうか。

もうひとつはPublic Gateway URLである。

```
https://ipfs.io/ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/readme
```

この形式ならIPFSに対応していないツールを使用している人でもアクセスできる。
しかしあまりアクセスする人が多いとパブリックゲートウェイの負荷が大きくなってしまうので、ローカルゲートウェイを使いたい人はツールで書き換えることもできる。
現状ではこの形式を使うのが最良の選択だろう。

次回に続く。
