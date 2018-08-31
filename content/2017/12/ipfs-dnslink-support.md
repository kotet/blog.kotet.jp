---
date: 2017-12-22
title: "12:ブラウザ拡張のDNSLINKサポート"
tags:
- ipfs体験記
- ipfs
- tech
excerpt: "IPFSのブラウザ拡張について書いた以前の記事 には理解できなかったものが抜けている。 ipfs体験記12回めのこの記事ではその中のDNSLINK Supportという項目を理解できたので書く。"
---

[IPFSのブラウザ拡張について書いた以前の記事](/2017/10/ipfs-browser-extention)
には理解できなかったものが抜けている。
[ipfs体験記](/tags/#ipfs体験記)12回めのこの記事ではその中のDNSLINK Supportという項目を理解できたので書く。

IPNSには普通のドメインを使ってコンテンツにアクセスする機能もある。
TXTレコードを読んで指定されたIPFS/IPNSアドレスを読むことができるのだ。
たとえば`ipfs.io`の場合TXTレコードは以下のようになっている。

```console
$ dig TXT ipfs.io +short
"google-site-verification=RRzoSXE1iCp7EC--YGJ1hJlQHnUdRQPj7Q5LmlQSgBc"
"dnslink=/ipfs/QmQrX8hka2BtNHa8N8arAq16TCVx5qHcb46c5yPewRycLm"
```

IPFSは`dnslink`を読んで以下のように解決をする。

```console
$ ipfs resolve -r /ipns/ipfs.io
/ipfs/QmQrX8hka2BtNHa8N8arAq16TCVx5qHcb46c5yPewRycLm
```

`/ipns/ipfs.io`と`/ipfs/QmQrX8hka2BtNHa8N8arAq16TCVx5qHcb46c5yPewRycLm`は同じコンテンツを指しており、
どちらのアドレスでもアクセスできる。
しかしあるドメインがIPNS用の情報を提供しているかはなかなか気づけない。

ブラウザ拡張の試験的機能であるDNSLINK Supportはその確認を自動的におこなって、場合によってはリダイレクトしてくれる機能である。
たとえばこの機能をオンにした状態で`ipfs.io`にアクセスするとアドレスバーが`http://127.0.0.1:8080/ipns/ipfs.io/`に書き換わる。

ブログなどの頻繁に変わるコンテンツはIPFS版のサイトには含まれていないらしく、404になる。
他のサイトでも画像などのコンテンツが含まれていなかったりして、見られないことが多い。
おそらくこれがDNSLINK Supportが試験的機能であるゆえんだろう。