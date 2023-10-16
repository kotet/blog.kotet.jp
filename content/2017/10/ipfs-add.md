---
date: 2017-10-25
aliases:
- /2017/10/25/ipfs-add.html
title: "P2PプロトコルIPFS体験記5:アップロード"
tags:
- ipfs
- tech
- log
- ipfs体験記
excerpt: 今回は普通に使ってみようと思う。
image: /assets/2017/10/25/twitter.png
---

今回は普通に使ってみようと思う。

### ファイルの追加

ファイルの追加は`ipfs add`でできる。

```console
$ echo "hello world" > test
$ ipfs add test
added QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o test
```

アドレスはファイルの中身のハッシュ値できまるので、初心者の"hello world"ファイルでネットワークが埋め尽くされることはない。
`test`というファイル名は保持されないので注意である。

### 閲覧

ファイルの中身は`ipfs cat`で見ることができる。

```console
$ ipfs cat QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
```

現在デーモンを起動中なので、ローカルゲートウェイを使ってアクセスすることもできる。
また、デーモンが起動しているということはネットワークに接続しているということなので、他人のパブリックゲートウェイからもアクセスできる。

```console
$ curl http://127.0.0.1:8080/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
$ curl https://ipfs.io/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
```

### 所持ノードの確認

`ipfs dht findprovs`で、リソースを提供できるピアのIDを探すことができる。
ピアとかノードとかファイルとかリソースとか、用語が安定しない。

```console
$ ipfs dht findprovs QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
QmcEYwrw73GpQrxDBN9Zn4y2K9S6f1epQNGrttXa3ZRPeg
QmVGkGSV25o3AMjcjjnPVb1PqJzrA1PvvhMiV57cMEuExb
QmUCHxxmZM5ozFCUw2zgRbf7HgbK5rq4byMQp89YgFSxhT
QmPDcnTLF5HftAhteRGVhAHnxwNfLzm541W7LL1rpaChy7
QmNqnFQNN522wpzvwXresRcEBGqbvMKHqH9yjVPeHLdmdK
QmQ9N2TJCjdX69Z6eRyxkjichXsxHk6zTubHumpSkxPBwR
QmQHTTRKtr43AbXuobZmgjSjmRd3vjfSbtPqqLjADHgY5T
QmS7tYQoexjzg5tgf9XkUCRG2eJKZdL5U1dGvNotfc1Qnt
QmUs6n9d9rUzkC84WsBW5eMhdpYA7yqngFNbFYeoqhAJiM
QmbdtmB77Nb1PgJfWYk9SCjkxcMogLHg9oS6xS37a5K1mY
QmcmyeFyP7RDd3bSWMke57H4YfAdusLBfuhsorfb5jPJfn
Qmeu1A2jc894rD3NQtdaCMEzMPpaQqGJJe2DrnbZZ2NzcZ
QmSoLSafTMBsPKadTEgaXctDQVcqN88CNLHXMkTNwMKPnu
QmbccS58t56NLpP7Xovhfnoyw24iQyjGYFKbc4FpFwLRba
QmSMSC9SmN1wmfPsiCHxm5uuprL1ciRxkpaUqXRDkGCSDU
QmZNzyQ5JJUWGVoM2ZRsLbLKhuBuyHxgfBqTMEBwjfeDqg
QmbHT8qkMAapFUdcXHgMximfGF5P1ZNhJ3Rf6nh5wY7wzm
Qmea9dCZu6iB1yKb6pDYvBDyKuix1gRNpzUK1W3X2cqufK
QmWQbadozRKdhtiLjfKSiaVKth2bssMGYWDw7L8XQLtY9d
QmSoLnSGccFuZQJzRadHn95W2CrSFmZuTdDWP8HXaHca9z
```

通常は自分と先ほどのパブリックゲートウェイの2件しか出てこないのだが、`hello world`という一般的なデータのため複数の人が持っていた。
もっとたくさんいるだろうが、デフォルトでは20件見つけたところで止まるようになっている。
たくさん提供者がいるので、このデータはたとえ自分がネットワークから去ったとしても以下のリンクからいつでもアクセスできる。

[https://ipfs.io/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o](https://ipfs.io/ipfs/QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o)

### ファイル名込みで追加、そして永続性について

`ipfs add --wrap-with-directory`、もしくは`ipfs add -w`で、ファイルをディレクトリオブジェクトでラップできる。

```console
$ ipfs add -w test
added QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o test
added QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG
```

詳しいことは[POSTDに日本語の解説がある](http://postd.cc/an-introduction-to-ipfs/)のでそちらを見て欲しいが、
IPFSのディレクトリは他のIPFSオブジェクトへの名前付きリンクからできている。
よってデータ`hello world`にはやはり名前情報はなく、ハッシュも先ほどと同じ`QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o`である。

ディレクトリは`ipfs cat`できない。

```console
$ ipfs cat QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG
Error: this dag node is a directory
```

ここでは"dag node"という名前が使われている。
なんだか混乱してくるので名前は気にしないことにする。

ディレクトリは`ipfs ls`で見ることができる。
`-v`は1行目の`Hash`、`Size`、`Name`というガイドを表示させるオプションである。

```console
$ ipfs ls QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG -v
Hash                                           Size Name
QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o 20   test
```

こちらも所有者がいないかさがしてみる。

```console
$ ipfs dht findprovs QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG
QmcEYwrw73GpQrxDBN9Zn4y2K9S6f1epQNGrttXa3ZRPeg
```

自分しかいない。
自分のコンピュータは常時作動しているわけではないし、パブリックゲートウェイもずっとデータをとっておいてはくれないので、基本的にアクセスできないだろう。

[https://ipfs.io/ipfs/QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG](https://ipfs.io/ipfs/QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG)

しかし自分がネットワークにいる間は他のノードがアクセスできる。

```console
$ google-chrome https://ipfs.io/ipfs/QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG
```

![スクショ](/assets/2017/10/25/screenshot.png)

もう一度所有者を探す。

```console
$ ipfs dht findprovs QmVyB39dubpAXaD6FKrLR3MrisQvaga1EefJZ5E3TmTcVG
QmcEYwrw73GpQrxDBN9Zn4y2K9S6f1epQNGrttXa3ZRPeg
QmZMxNdpMkewiVZLMRxaNxUeZpDUb34pWjZ1kZvsd16Zic
```

パブリックゲートウェイのIDが増えている（前回のChrome Extentionを入れているとローカルゲートウェイにリダイレクトされてしまい増えないので注意）。
ノード（今回は[ipfs.io](https://ipfs.io)）がリソースにアクセスすると、リソースはそのノードに一時的に保存され、そのノードも提供者になる。
他にリソースにアクセスしたい人が現れた時には、自分とそのノードで提供者が2人いることになる。
またその人も提供者になるので、同時期にアクセス数が増えても特定のサーバーの負荷は増えないし、むしろ減っていくというわけだ。
BitTorrentと同じである。

ただ、リソースはPinしない限りGCを動作させると消えてしまうので、しばらくの間誰からもアクセスされず、
なおかつPinしている人が誰もいない場合ネットワークからリソースは消失する。
アップロードしたらデータが永久にネットの海を漂い続け、自分のコンピュータの電源は切ってもいい……というわけではないので注意である。

自分は勘違いしていたのだが、「永続性」とはあくまで同じアドレスが同じリソースを指すということであり、ファイルが消えない「永遠性」とは違うのだ。

次回に続く。
