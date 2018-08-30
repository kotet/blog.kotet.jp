---
date: 2017-12-20
title: "11:IPFSによる分散型SoundCloud"
tags:
- ipfs体験記
- ipfs
- tech
excerpt: "今まで前回、次回の記事に手動でリンクを貼っていたが、記事を投稿するたびに複数のファイルを編集しなければならないのがめんどくさいのでやめる。"
---

今まで前回、次回の記事に手動でリンクを貼っていたが、記事を投稿するたびに複数のファイルを編集しなければならないのがめんどくさいのでやめる。
[ipfs体験記](/tags/#ipfs体験記)というタグを作ったのでそこから記事一覧にアクセスできる。
今までタグに日本語を使うのを避けていたが、やってみたら意外と問題が起きなかった。

追記: どうもシーダーがいなくなってアクセスできなくなってしまった様子のリソースがいくつかあるが、そのままにしておく。

SoundCloud的ウェブサイトがあった。

- [DSound - Decentralized Sound Platform](https://dsound.audio/#/feed)

以下は作者の書いた記事である。

- [Introducing DSound: a decentralized sound platform using STEEM and IPFS — Steemit](https://steemit.com/music/@prc/introducing-dsound-a-decentralized-sound-platform-using-steem-and-ipfs)
- [DSound: The launch, what's new now that the 1st alpha is closed and the FULL decentralization of it — Steemit](https://steemit.com/music/@prc/dsound-the-launch-what-s-new-now-that-the-1st-alpha-is-closed-and-the-full-decentralization-of-it)

音声などのデータをIPFS上に保存しており、たとえば
[https://gateway.ipfsstore.it:8443/ipfs/QmQV535FtqctNyKb82Qh5XUbdh2bdmjyzS5AHcwEPWTaJS](https://gateway.ipfsstore.it:8443/ipfs/QmQV535FtqctNyKb82Qh5XUbdh2bdmjyzS5AHcwEPWTaJS)
のように内部でパブリックゲートウェイを使ってアクセスしている。
[以前紹介したブラウザ拡張]({% include relative %}{% post_url 2017/10/2017-10-20-ipfs-browser-extention %})
を有効にした状態で閲覧するとこのURLがローカルゲートウェイのものに書き換えられ、自分のIPFSノードからダウンロードされるようになる。
または、ログインするとローカルゲートウェイを使うよう設定できるらしい。
するとIPFSの効果により負荷が分散されるというわけだ。

`ipfs bitswap wantlist`を見ていると再生ボタンを押したあとにwantlistにハッシュが大量に追加されるのを見ることができる。
wantlistはソートされておらず実行するたびに順番が違うので、`watch`などで監視する場合は`sort`する必要があるので注意しよう。

しかし自分の環境だと1回目は途中でダウンロードが止まってしまうことがある。
止まってしまってからページをリロードして、もう一度再生するとちゃんとwantlistがすべて消化される。
これはこのサイトのバグだろうか、`go-ipfs`のバグだろうか、それとも単に自分とデータ保持者の回線の問題だろうか?

コンテンツが完全に分散されているので、アクセスする人が多くてもローカルゲートウェイを使っており、シーダーが十分に多いなら管理者の負担にはならない。
なので、通常なら禁止されがちのファイルへの直リンクが上記の記事では逆に紹介されている。

```html
<video src="https://ipfs.io/ipfs/QmQAJq3xfPhekc8zph3KjssjYUBLBT3jnMAPHzJU1X9ELz" poster="https://ipfs.io/ipfs/Qme9AJ61nQJezRej79BZTxvT5uXuUzLTiFGH5kWewCJYLR" controls></video>
<audio src="https://ipfs.io/ipfs/QmQAJq3xfPhekc8zph3KjssjYUBLBT3jnMAPHzJU1X9ELz" controls></audio>
```

<!-- video/audioタグが貼れない…… -->
<div id="videoandaudio"></div>
<script>
    let div = document.querySelector("#videoandaudio");
    let v = document.createElement("video");
    v.src = 'https://ipfs.io/ipfs/QmQAJq3xfPhekc8zph3KjssjYUBLBT3jnMAPHzJU1X9ELz';
    v.poster = 'https://ipfs.io/ipfs/Qme9AJ61nQJezRej79BZTxvT5uXuUzLTiFGH5kWewCJYLR';
    v.controls = "controls";
    v.style = 'width: 100%;';
    div.appendChild(v);
    let a = document.createElement("audio");
    a.src = 'https://ipfs.io/ipfs/QmQAJq3xfPhekc8zph3KjssjYUBLBT3jnMAPHzJU1X9ELz';
    a.controls = "controls";
    a.style = 'width: 100%;';
    div.appendChild(a);
</script>

分散されているのはデータだけかと最初思ったが、どうやら完全に分散型のサービスらしい。
データベースに[Steem](https://steem.io/)というものを使っているらしいが、Steemについての知識がゼロのためどれくらい分散されているのかわからない。

なかなか実用的で素晴らしいと思う。
あとはブラウザやスマホで動くIPFSノードがあれば……