---
date: 2017-12-28
aliases:
- /2017/12/28/ipfs-archive.html
title: "13:非中央集権型ウェブ魚拓"
tags:
- ipfs体験記
- ipfs
- tech
excerpt: IPFSでウェブページのアーカイブをするツールが複数存在する。 アーカイブのIPFSハッシュが公開されていれば、それを保持してくれているノードがいるかぎり誰にも削除できない。 今回は簡単に魚拓やスクショを公開するツールを紹介していく。
---

IPFSでウェブページのアーカイブをするツールが複数存在する。
アーカイブのIPFSハッシュが公開されていれば、それを保持してくれているノードがいるかぎり誰にも削除できない。
今回は簡単に魚拓やスクショを公開するツールを紹介していく。

### ipfs-archive

[jirwin/ipfs-archive: Use IPFS to archive a url.](https://github.com/jirwin/ipfs-archive)

IPFSノードがなくても動くWebバージョンもある。

[ipfs archive network](https://ipfs.archive.network/)

こちらを使ってみた。
作ったアーカイブはどれくらいの期間保存されるのだろうか。
一定期間で消されるようならば自分でPinしなければならない。

リポジトリの[README](https://github.com/jirwin/ipfs-archive/blob/master/README.md)で試した。
以降のIPFSハッシュは一応すべて自分のノードでPinしているが、今の所ずっと動いているわけではないので見られないかもしれない。

[/ipfs/QmULiZkkXXKtNu5vsLNJQG8sDRn4L6bbLzrKXNgNpKrxn8](https://gateway.archive.network/ipfs/QmULiZkkXXKtNu5vsLNJQG8sDRn4L6bbLzrKXNgNpKrxn8)

### ipfscrape

[VictorBjelkholm/ipfscrape: Scrape pages and store them in IPFS](https://github.com/victorbjelkholm/ipfscrape)

PRが2年ほど放置されたりしている。
すごく小さなシェルスクリプトで、ipfsがコンピュータにインストールされている必要がある。
現在のgo-ipfsでも動作した。
実行するとアーカイブを生成し、IPFSにアップロードし、自動的にPinされる。


```console
$ ./run.sh https://github.com/VictorBjelkholm/ipfscrape/blob/master/readme.md

Dumping "https://github.com/VictorBjelkholm/ipfscrape/blob/master/readme.md" into IPFS

readme.md.html                            [ <=>                                                                   ]  11.11K  --.-KB/s 時間 0.1s    
frameworks-1c2c316b7a17f15536c6a26ed7 100%[======================================================================>]  23.34K  --.-KB/s 時間 0.02s   
github-8100b9bf1eb6ed8b38eaad2fe7ba51 100%[======================================================================>]  92.80K  --.-KB/s 時間 0.02s   
...中略...
star-bg.svg                           100%[======================================================================>]   3.95K  --.-KB/s 時間 0s      
site-signup-prompt.png                100%[======================================================================>]  97.57K  --.-KB/s 時間 0.01s   
Moving readme.md.html to index.html

###############
## DUMP COMPLETE
##
## Urls:
## http://localhost:8080/ipfs/QmZDKaqySW8URZ36i7x8sK8d2VkQwuGvSx3N4GVXNHBTpW
## https://ipfs.io/ipfs/QmZDKaqySW8URZ36i7x8sK8d2VkQwuGvSx3N4GVXNHBTpW

```

[/ipfs/QmZDKaqySW8URZ36i7x8sK8d2VkQwuGvSx3N4GVXNHBTpW](https://ipfs.io/ipfs/QmZDKaqySW8URZ36i7x8sK8d2VkQwuGvSx3N4GVXNHBTpW)

ipfs-archiveでGitHubをアーカイブするとNet neutralityについてのバナーが出ているが、こっちではそういうことはない。
アーカイブを作成する場所の問題だろう。
このように場所によって見え方が違うサイトをアーカイブするならローカルでやるのが確実だろう。

### http2ipfs-web

以降は魚拓とはちょっと違うものである。

[jbenet/http2ipfs-web](https://github.com/jbenet/http2ipfs-web)

これはURLを指定してIPFS上にファイルをアップロードするWebアプリケーションである。
ただしIPFSの、しかもWritableなApiサーバを用意する必要がある。
IPFSデーモンは起動時に指定しないとWritableにならなかったと思うので、ちょっと使うのがめんどくさい。

### ipfs-screencap

[jbenet/ipfs-screencap: Capture screenshots, publish them to IPFS, and copy the link to the clipboard.](https://github.com/jbenet/ipfs-screencap)

スクショをダイレクトにIPFS上にアップロードするツール。
まずはインストールする。

```console
$ ipfs get /ipfs/QmQgQYuzYRGdhNtfpLRQmL5jJfoxPnSuTzgwUJGjwcDays/ipfs-screencap
$ cd ipfs-screencap
$ sh install.sh
$ sudo chmod +x /usr/local/bin/portable-screencap
$ sudo chmod +x /usr/local/bin/ipfs-screencap
```

実行して画面の範囲を選択すると、スクリーンショットを取り、IPFSにアップロード、URLを出力する。
ディレクトリオブジェクトでラップされるのでファイル名がつく。

```console
$ ipfs-screencap -v
capturing screen... QmbD8tWjc5o5pBD5X3N1rv2ZrinWQTmg8sx1BPveHZbvvu
constructing dir... QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn
http://gateway.ipfs.io/ipfs/QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn/screencap.2017-12-28T13:53:30Z.png
```

[/ipfs/QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn/screencap.2017-12-28T13:53:30Z.png](https://ipfs.io/ipfs/QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn/screencap.2017-12-28T13:53:30Z.png)

![/ipfs/QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn/screencap.2017-12-28T13:53:30Z.png](https://ipfs.io/ipfs/QmQjVSYec1rLTcMJfepPKYaCiBUtqYEy7tM7ZbReuYHyhn/screencap.2017-12-28T13:53:30Z.png)