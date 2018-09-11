---
title: "17:普通のファイルシステムのようにIPFSで読み書き"
date: 2018-09-11
tags:
- ipfs体験記
- ipfs
- tech
- log
excerpt: "ipfs mount というコマンドがある。 FUSE を使って IPFS を通常のファイルシステムとしてマウントできる。 ただし、以下に書かれているようにこれはあくまで読み込み専用であり、 これを使って IPFS になにか働きかけたりはできない。……と思っていた。"
---

`ipfs mount` というコマンドがある。
[FUSE](https://ja.wikipedia.org/wiki/Filesystem_in_Userspace)
を使って IPFS を通常のファイルシステムとしてマウントできる。
ただし、以下に書かれているようにこれはあくまで読み込み専用であり、
これを使って IPFS になにか働きかけたりはできない。

```bash
$ ipfs mount -h
USAGE
  ipfs mount - Mounts IPFS to the filesystem (read-only).

  ipfs mount [--ipfs-path=<ipfs-path> | -f] [--ipns-path=<ipns-path> | -n]

  Mount IPFS at a read-only mountpoint on the OS (default: /ipfs and /ipns).
  All IPFS objects will be accessible under that directory. Note that the
  root will not be listable, as it is virtual. Access known paths directly.
  
  You may have to create /ipfs and /ipns before using 'ipfs mount':
  
  > sudo mkdir /ipfs /ipns
  > sudo chown $(whoami) /ipfs /ipns
  > ipfs daemon &
  > ipfs mount

Use 'ipfs mount --help' for more information about this command.

```

……と思っていた。

[Transparent FUSE · Issue #341 · ipfs/ipfs](https://github.com/ipfs/ipfs/issues/341)

> We can *almost* do parts of this, it's just really buggy. You can mount `/ipns` and read/write to `/ipns/local`. This will even update your IPNS address to point to the latest version of the directory.
>
> However, it's really buggy and slow.
>
> ---
>
> But yeah, many of us have been wanting to do this for a while.

マジで？

### IPNS

IPFS 上で変化するものを公開する方法のひとつとして、IPNS がある。
これは ID と IPFS 上のリソースを結びつけるものだ。
いわば IPFS 上に作ることのできる自分専用のディレクトリである。
これはたとえば以下のように使う。

```bash
$ echo hello! > test.txt
$ ipfs add test.txt 
added QmUCChJVPoiGqHmSCdoDBoTU1BgC3AGBoy4sAk1wYcFhPg test.txt
 7 B / 7 B [=========================================================================================================================================] 100.00%
$ ipfs name publish /ipfs/QmUCChJVPoiGqHmSCdoDBoTU1BgC3AGBoy4sAk1wYcFhPg
Published to QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5: /ipfs/QmUCChJVPoiGqHmSCdoDBoTU1BgC3AGBoy4sAk1wYcFhPg
$ ipfs cat /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
hello!
```

コンテンツを変更したくなったら、もう一度 `ipfs name publish` すればよい。

```bash
$ echo "hello world!" > test.txt
$ ipfs add test.txt 
added QmeV1kwh3333bsnT6YRfdCRrSgUPngKmAhhTa4RrqYPbKT test.txt
 13 B / 13 B [=======================================================================================================================================] 100.00%
$ ipfs name publish /ipfs/QmeV1kwh3333bsnT6YRfdCRrSgUPngKmAhhTa4RrqYPbKT
Published to QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5: /ipfs/QmeV1kwh3333bsnT6YRfdCRrSgUPngKmAhhTa4RrqYPbKT
$ ipfs cat /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
hello world!
```

もちろんディレクトリでも大丈夫。

```bash
$ mkdir test
$ echo hey! > test/test.txt
$ ipfs add -r test/
added QmNqugRcYjwh9pEQUK7MLuxvLjxDNZL1DH8PJJgWtQXxuF test/test.txt
added QmRf8ffz9d7nK8BXbGjaAb4i1GoDX8CZyyqXqRjrBefY29 test
 5 B / 65 B [==========>-----------------------------------------------------------------------------------------------------------------------------]   7.69%
$ ipfs name publish /ipfs/QmRf8ffz9d7nK8BXbGjaAb4i1GoDX8CZyyqXqRjrBefY29
Published to QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5: /ipfs/QmRf8ffz9d7nK8BXbGjaAb4i1GoDX8CZyyqXqRjrBefY29
$ ipfs ls /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
QmNqugRcYjwh9pEQUK7MLuxvLjxDNZL1DH8PJJgWtQXxuF 13 test.txt 
```

IPFS だけでウェブサイトを配信したいときなんかは必須ではないだろうか。

これは今回の話とはあまり関係ないが、ここまでの `ipfs name publish` などが尋常でなく遅い。
バグだろうか、それとも自分がなにか遅くなるようなことをしているのだろうか……。
とりあえず、コマンドを実行して返事が帰ってこなくても気長に待つことだ。

### /ipns/local

自分の ID が `/ipns/local` にリンクされているようだ。

```bash
$ sudo mkdir /ipfs /ipns
$ sudo chown $(whoami) /ipfs /ipns
$ ipfs mount
IPFS mounted at: /ipfs
IPNS mounted at: /ipns
$ ls -l /ipns
total 0
lr-xr-xr-x 1 root  root  0 Sep 11 19:57 local -> QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
dr-xr-xr-x 1 kotet users 0 Sep 11 19:57 QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
$ ls /ipns/local
test.txt
$ cat /ipns/local/test.txt
hey!
```

さらに書き込みもできるようになっている。

```bash
$ echo "hello world!" >> /ipns/local/test.txt
$ echo "another world!" > /ipns/local/test2.txt
```

やはりこちらも反映にとても時間がかかる。
何もしないで待つには長すぎるほどだ。
お茶でものんで気長に待とう。

```bash
$ ipfs ls /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
QmQwQzEedqC7vP6VWQujNKr6at9jSRtAJVraF7p7rdxoBs 128 test.txt
QmTjiABbErriHkDp9QCbrbarHEcgCRqicX62fTqgKdDihJ 73  test2.txt
$ ipfs cat /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5/test.txt
hey!
hello world!
$ ipfs cat /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5/test2.txt
another world!
```

### 実用っぽいことをしてみる

試しにこのサイトを生成して置いてみる。

```bash
$ hugo -d /ipns/local

                   | EN   
+------------------+-----+
  Pages            | 216  
  Paginator pages  |   0  
  Non-page files   |   0  
  Static files     | 105  
  Processed images |   0  
  Aliases          | 148  
  Sitemaps         |   1  
  Cleaned          |   0  

Total in 79556 ms
```

いつもなら0.5秒あれば終わるところを1分以上かかっている。
別の場所で生成してからコピーしてみたらそのコピーにも同じだけの時間がかかった。
書き込み中は CPU 使用率が上がっていたりするので、
変更があるたびに何かしらの処理をしているのだろう。
20メガバイトに満たないサイトにもかかわらずこれだけの時間がかかっているので、
もっと大規模なサイトはちょっとつらそうだ。

ともかく、ちゃんとサイトが公開された。
一応言っておくがこの IPFS ノードは基本的に止めてある。
なので、この記事を読んでいる現時点では
`/ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5`
にアクセスすることはおそらくできないだろう。
そもそも現状このサイトは IPFS で公開してもちゃんと表示できるようにはできていない。

```bash
ipfs ls /ipns/QmYFjBY2jGetJV6zCYgWWt1zcgzFYooAdbNiXU9paM4uz5
Qmb8rMxBfc3ZcDoYTBy1pPW2pVncEDvRwP2jcAaQn7pWji 229815   2016/
QmdJy32q1mwfr2n3NsyaejFUFbDa14vwLQ5zsp1L5EvUzC 1391891  2017/
Qma3xvg2ez7cXL71L7yjC4srbuUGGkv9kj6cu2raGmyxAP 601006   2018/
QmQyFnH5V3JQYCwYuCa7Ug8AT8aCSMR8KCahG8rsbcHANC 7372     about/
QmfK2rJYqLPuhFFj9tUacs14uDcesfsmkdNpoJMPW73gw7 13827370 assets/
QmXneZHFVikyzRNYXTnZ7gxy2K5PUEsphyuWQaR2yBkaLV 2302     favicon.ico
QmeUsXAK4MD61bKn2CZUmTe1dYx48f7Rwj8QNUL1VFuoEo 26594    img/
QmZrUnUaxcRFNgR2154A6YdDyxmrkHvMCrKrozXAz4nNCy 95432    index.html
QmeYr4jfFGVtzogDBacgWCfxsg4T4Xm16XM1tgdgCA2p1d 84278    index.xml
QmPQQ4Rt8ucv5XUNBoei7JWGGMPo9VS8f5ADbWPbjRFtQz 1466     main.css
QmZXWCcXJHbxjWAzt7m4SFRXv41oaGnRYxt7CDyTNvvkRG 4384     products/
QmPFEBFAP2Q7P2cZXAwYjexEXsrUXEMRpkkujHMMFfS8mD 963      single.css
QmVxw1h7qHT6r5ND5CCHVD489yndbApe99VSyKeUWnRTud 25458    sitemap.xml
QmX5oxwU4CEkpMWpH4bfWkx8v482PFZAdiouvgrw1KCyhC 381452   tags/
```

### 自動化が楽になりそう

この機能を使わずにウェブサイトのデプロイをする場合、
専用のスクリプトを組んで複数のコマンドを組み合わせないといけないはずだ。
対してこちらは `/ipns/local` に何も考えず放り込めばいいので、
自動化のハードルが一段下がる。
とてもよい。

しかし *it's really buggy and slow* である。
ドキュメントに書かれていないのはバグが多くまだ使ってほしくないということだろうか。
それとなぜこんなに遅いのだろうか。
Go を読めるようになって実装を見てみなければならない。
早く実用できる段階になってほしいものだ。