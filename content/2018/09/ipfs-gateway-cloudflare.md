---
title: "18:CloudflareがIPFSゲートウェイとホスティング支援サービスを提供"
date: 2018-09-18
tags:
- ipfs体験記
- log
- tech
excerpt: "Cloudflare がIPFSゲートウェイを公開したようだ。この機会に自分のIPFSパブリックゲートウェイの使い方について書く。"
---

Cloudflare がIPFSゲートウェイを公開したようだ。

[Cloudflare goes InterPlanetary - Introducing Cloudflare’s IPFS Gateway](https://blog.cloudflare.com/distributed-web-gateway/)

この機会に自分のIPFSパブリックゲートウェイの使い方について書く。

### パブリックゲートウェイ

IPFSパブリックゲートウェイはhttpやhttpsを通して、
通常のウェブページのようにIPFS上のコンテンツにアクセスするためのものである。
モバイル環境やその他ネット環境の都合でP2Pが使えないときでもIPFSのコンテンツにアクセスできる。
もちろん完全に1つのゲートウェイしか使わなくなってしまうと分散の意味がなくなってしまうので、
できるなら自分のローカルゲートウェイを使わなければいけない。

主に自分が使うのは[ipfs.io](https://ipfs.io)である。
ドメイン名が短いので使い勝手が良い。

### 使用例

たとえばIPFSハッシュが与えられたとき、その内容をブラウザで見たいときはどうすればいいだろうか。

```txt
QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH
```

まずはハッシュをアドレスバーにコピペして、それから`localhost:8080/ipfs/`と書き加える。
このようにローカルゲートウェイに渡してやれば良いのだが、ちょっとURLが長いし、覚えにくかったりする。
それに自分は時々IPFSネットワークに接続できなくなるので、
せっかく長いURLを打ち終わってもアクセスできなかったりする。
そういうときは結局パブリックゲートウェイのドメインを打ち直したりする。

```txt
localhost:8080/ipfs/QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH
```

なので、自分は最初から`ipfs.io/ipfs/`と書く。
短いし、覚えやすい。
さらにローカルゲートウェイが動いているときは、
ブラウザ拡張によって自動的にそちらにリダイレクトされる。
いいことづくめというわけだ。

ちなみにこのハッシュはIPFS界のexample.com（今考えた）こと"test"である。

[https://cloudflare-ipfs.com/ipfs/QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH/](https://cloudflare-ipfs.com/ipfs/QmeomffUNfmQy76CQGy9NdmqEnnHU9soCexBnGU3ezPHVH/)

### cloudflare-ipfs.comは何に使えばいいのか

[cloudflare-ipfs.com](https://cloudflare-ipfs.com/)は少々長いし、Typoもしやすそうだ。
上に書いたような使い方には今回のゲートウェイは向いていないだろう。
ただ、他人にURLを渡す場合、
負荷分散のためにも先程のリンクのように複数のパブリックゲートウェイを使い分けたほうがいいだろうか。

そしてこちらが本題。
どうもCloudflareはIPFSを使ったウェブサイトのホスティング支援サービスを行っているらしい。

> If you have content stored in IPFS that you want to serve from a custom domain name,
> you can do so in just a few minutes using this gateway. All you need is a domain name you own,
> access to your DNS records, and the hash of the content stored on IPFS. More in-depth
> instructions, including how to get your content onto IPFS in the first place,
> can be found in our developer documentation.
>
> [Distributed Web Gateway | Cloudflare](https://www.cloudflare.com/distributed-web-gateway/)

独自ドメインかつHTTPSでサイトを運営するために証明書を発行してくれるようだ。
これによりWebサーバーを運営する必要はなくなり、
IPFSノードだけを動かすだけで通常通りサイトの公開ができるようになる！
こちらはかなり便利そうだ。
早く常時動かせるIPFSノードを用意して試してみたい……
