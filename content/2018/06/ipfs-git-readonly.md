---
date: 2018-06-04
title: "非中央集権静的Gitホスティング"
tags:
- ipfs
- tech
---

GitHubがMSに買収されたとかでなにやら騒がしいが、Gitリポジトリをホスティングするだけなら方法はいっぱいある。
最近IPFSの記事を書いていないしノードを動かしてもいなかったが、IPFSを使ったGitリポジトリのホスティング方法を思い出し、
今試してみたところうまくいったので書く。

### Git HTTP(S)サーバー

Gitサーバーには[様々なプロトコルが使える](https://git-scm.com/book/ja/v2/Git%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC-%E3%83%97%E3%83%AD%E3%83%88%E3%82%B3%E3%83%AB)が、
外部に公開するときに一番気軽なのはHTTP/HTTPSを使った方法だと思う。
`git clone http://...`とコマンドを入力したとき、GitクライアントはHTTPを使った"smart" HTTPプロトコルでの通信を試みる。
認証が求められたりするのはこっち。
サーバーがSmartプロトコルに反応しなかった場合、Gitクライアントは"dumb" HTTPプロトコルへフォールバックする。
これは非常に単純で、サーバーは通常のWebサーバーのように静的ファイルの配信をするだけでいい。
Gitクライアントは勝手に`info/refs`ファイルを読んで、それに沿ってファイルをダウンロードしていく[^1]。

[^1]: [Git - 転送プロトコル](https://git-scm.com/book/ja/v2/Git%E3%81%AE%E5%86%85%E5%81%B4-%E8%BB%A2%E9%80%81%E3%83%97%E3%83%AD%E3%83%88%E3%82%B3%E3%83%AB)

### IPFS上でGitリポジトリをホストする

そういうわけで一般的なWebサーバーがあれば認証なし & 読み込み専用のGitリポジトリは簡単に作ることができる。
IPFSを使えば中央集権的サーバーを用意することなくホスティングができる。[^2]
それなりに人気のあるハッシュはアップロード者が落ちても有効であり続けるだろう。
なお今回作ったハッシュは自分がいつもノードを動かしているわけではないしPCの移行のときに維持したりもしないのでたぶん高確率でアクセスできなくなる。

[^2]: [ipfs example \| Git, even more distributed](https://ipfs.io/docs/examples/example-viewer/example#../git/readme.md)

#### 1. リポジトリの用意

好きな方法でベアリポジトリ(作業ディレクトリのないリポジトリ)を作る。

```console
$ git clone --bare git@github.com:kotet/kotet.github.io.git
```

#### 2. info/refs ファイルの生成

`git update-server-info`で`info/refs`を生成する。
自分の環境だと補完も働かないし実行してもなにも出力されないしで本当にうまく行ったのか不安だった。

```console
$ cd kotet.github.io.git/
$ git update-server-info
```

確認してみるとちゃんとファイルが生成されているのがわかる。

```console
$ cat info/refs 
2e7df24a1aea2df87604ab14ff417a55c4936259	refs/heads/master
```

#### 3. IPFSにアップロード

ディレクトリ全体をまとめて追加する。

```console
$ ipfs add -r .
added QmWeKwYTKwBwVd7AKioXTmtpLFxTk3MBBk2ef2JtwCccAi kotet.github.io.git/HEAD
added Qmf7tR49yWCra16eNFVuAv4guxxaugbpmhBRrE8SAESmiJ kotet.github.io.git/config
added Qmdy135ZFG4kUALkaMhr6Cy3VhhkxyAh264kyg3725x8be kotet.github.io.git/description
added QmY2duvZ5Resxt8astYUgQ8RXQz1N9axe77gCb5j6M95Gf kotet.github.io.git/hooks/applypatch-msg.sample
added QmQbraCfKaCTZkqtdXCJPc11CWEiZGw1yYGwtbA6nbXWeh kotet.github.io.git/hooks/commit-msg.sample
added QmQopPV9svGfagTR7eYkiBBtoTNm3JW4qbVgwNzsUecR64 kotet.github.io.git/hooks/fsmonitor-watchman.sample
added QmQjYxVj9iwitDGkmR48Cemr1JTgc6pvwo5cFkumNWqnjm kotet.github.io.git/hooks/post-update.sample
added QmdzjzkpM31jTKd5YBJkWsbDXJeeW1Uy1UxVPwfKFxwy89 kotet.github.io.git/hooks/pre-applypatch.sample
added QmYhXPftGXF32KjjThPvZTYWjJqHN4grSF11GvXh9NQbDc kotet.github.io.git/hooks/pre-commit.sample
added QmXprUtrWGYLRETUvuA89HjwUGdufGrwJxYaXyGwQ7TMvQ kotet.github.io.git/hooks/pre-push.sample
added QmSQrei5kUrb4RaEp4c7oobLEHURhPJ8AFZS1uiRg4JfLv kotet.github.io.git/hooks/pre-rebase.sample
added QmRKbU9DFRNWjR1UwV4nC6MXPnrNanfsBM5579t4HLUuig kotet.github.io.git/hooks/pre-receive.sample
added QmPku8ai5p4sSCDHe19n9Ekfo21xM5urFdkq9Rg1wBHjcV kotet.github.io.git/hooks/prepare-commit-msg.sample
added QmfKMgUdSUwrS1wF6yfkQ9B6Vdbomrx87vGhpvpLfxgVn2 kotet.github.io.git/hooks/update.sample
added QmcfzxUpw36y8fu2GR3s7Vgq7RBgooKtc6BgsqFnadsDLc kotet.github.io.git/info/exclude
added QmP5gWXpJbPDLMkYGGZVGBuNYDM38aB98uCsBJpCffKmmg kotet.github.io.git/info/refs
added QmetNjSLoodwtZCeLe5Di6oQyQt6rGUQipX8EMKKh5Z1BE kotet.github.io.git/objects/info/packs
added QmTdgPMHPkBL2K6871AGwmrHjKDRcugMwyk2v6ign7Dmsa kotet.github.io.git/objects/pack/pack-b2ff545d3b7a58ae2061d08999ca82c1daf19329.idx
added QmX6UjPELiLVbLW3fADHvMKZCBv5NpMGTE4JwpesRcdUW4 kotet.github.io.git/objects/pack/pack-b2ff545d3b7a58ae2061d08999ca82c1daf19329.pack
added QmayXxbVRBFGVAtJKMEogGkSzjKrrXnJs8pMzcGaXdAfqJ kotet.github.io.git/packed-refs
added QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn kotet.github.io.git/branches
added QmZw7QkxLuf1hzWZDpsyjC2a9yKkoL2xp3SgAUMg2feHM7 kotet.github.io.git/hooks
added QmT7xFXijZ6HPH7atWwvMCbHPYC1QpBZMr6Kanyp2ufpEV kotet.github.io.git/info
added QmUoepziFtSEVbTe9XfhxQAtAYwMomvDUvJ83XvZ4GJ34d kotet.github.io.git/objects/info
added QmWrow3qjNWwMZ7y71ALvxyXwXAC8s3yTsn3pvZV3Wwyed kotet.github.io.git/objects/pack
added Qmd17UPVXHwasLs9H8DJ5khce9LN1xKHjtVpnYE5yGK25s kotet.github.io.git/objects
added QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn kotet.github.io.git/refs/heads
added QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn kotet.github.io.git/refs/tags
added QmWYtSEta2Fzgy4u4ttdwwiKMUikwZrFHxa5quWXMVyBhy kotet.github.io.git/refs
added QmZFk1QBuEfxqhY5n5Ez2ReSuGa3EoMURVMFxprJfX6mqS kotet.github.io.git
```

#### 4. クローンしてみる

とりあえずローカルのゲートウェイからクローンしてみる。
一瞬で終わる。

```console
$ git clone http://localhost:8080/ipfs/QmZFk1QBuEfxqhY5n5Ez2ReSuGa3EoMURVMFxprJfX6mqS
Cloning into 'QmZFk1QBuEfxqhY5n5Ez2ReSuGa3EoMURVMFxprJfX6mqS'...
```

次にパブリックゲートウェイからクローンしてみる。
こちらは初回はパブリックゲートウェイのノードがこちらのノードを見つけ出してコンテンツを取りに来るぶん遅かったりタイムアウトしたりする。
初回クローンのあとしばらく、パブリックゲートウェイのノードでGCが走るまでは高速にクローンできる。
記事の最初のほうでGitHubからクローンしてきたときより速いかもしれない……

```console
$ git clone https://ipfs.io/ipfs/QmZFk1QBuEfxqhY5n5Ez2ReSuGa3EoMURVMFxprJfX6mqS
Cloning into 'QmZFk1QBuEfxqhY5n5Ez2ReSuGa3EoMURVMFxprJfX6mqS'...
```

### Pushは?

当たり前だが今回はただファイルをアップロードしただけなので更新とかはできない。
一応上記の手順を毎回やって、IPNSと組み合わせることでリポジトリを最新の状態に保つことができるがめんどくさいので多分誰もやらない。
IPFSでそういうことをするためにはクライアント側で工夫が必要で、そういうツールがちゃんと存在するのだがそれはまたそのうち書く。
たぶん。