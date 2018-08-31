---
date: 2018-03-02
title: "15:ipfs mount"
tags:
- ipfs体験記
- ipfs
- tech
---

実に1ヶ月ぶりの投稿になる。
今回は`ipfs mount`というコマンドを試してみたのだが、あまり便利には思えなかった。

### ipfs mount

このコマンドは、IPFSをあたかも普通のファイルシステムのようにアクセスできるようにするものだ。
実際やってみたほうがわかりやすいと思う。

以下デーモンはすでに実行中だとする。
指定したディレクトリ(デフォルトでは`/ipfs`と`/ipns`)をマウントポイントとして`ipfs mount`する。

```console
$ sudo mkdir /ipfs /ipns
$ sudo chown `whoami` /ipfs /ipns
$ ipfs mount
IPFS mounted at: /ipfs
IPNS mounted at: /ipns
```

すると通常のファイルやディレクトリのように`cat`や`ls`が使えるようになる。

```console
$ ls /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/
about  contact  help  ping  quick-start  readme  security-notes
$ cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/about

                  IPFS -- Inter-Planetary File system

IPFS is a global, versioned, peer-to-peer filesystem. It combines good ideas
from Git, BitTorrent, Kademlia, SFS, and the Web. It is like a single bit-
torrent swarm, exchanging git objects. IPFS provides an interface as simple
as the HTTP web, but with permanence built in. You can also mount the world
at /ipfs.

<--後略-->
```

ただし読み込み専用なので注意。
たぶんデーモンが終了した時点でマウントも解除される。

デーモンが動いているなら普通にローカルゲートウェイや`ipfs ls`などのコマンドを使ったほうが良さそうな気もする。
自分は若干のタイプ数の減少以上の活用法を見いだせなかった。
