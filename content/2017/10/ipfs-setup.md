---
date: 2017-10-18
aliases:
- /2017/10/18/ipfs-setup.html
title: "惑星間ファイルシステムIPFS体験記1:セットアップ"
tags:
- ipfs
- tech
- log
- ipfs体験記
image: /assets/2017/10/18/twitter.png
excerpt: "“InterPlanetary File System“というあまりにも魅力的な名前から、 以前よりIPFSを試してみたかった。 やってみたいなーとずっと言っているだけなのもアレなので、少しづつ触っていこうと思う。 今後「IPFS体験記」として投稿するのは、その記録である。 試したことをただ時系列順に書くだけなので、参考にするには読みづらいかもしれない。"
---

"[InterPlanetary File System](https://ipfs.io/)"というあまりにも魅力的な名前から、
以前よりIPFSを試してみたかった。
やってみたいなーとずっと言っているだけなのもアレなので、少しづつ触っていこうと思う。
今後「IPFS体験記」として投稿するのは、その記録である。
試したことをただ時系列順に書くだけなので、参考にするには読みづらいかもしれない。

とりあえずこのサイトをIPFS上でホスティング、更新を自動化するまでを当面の目標にする。
今回はインストールからWebUIを開くまでである。

### インストール

`ipfs`をインストール、更新するために`ipfs-update`というツールが用意されているようなのでそれを使う。

[IPFS Distributions](https://ipfs.io/ipns/dist.ipfs.io/#ipfs-update)からバイナリをダウンロードしてきて、
適当なところに置く。

```console
$ sudo cp ipfs-update /usr/bin/
$ ipfs-update -h
NAME:
   ipfs-update - Update ipfs.

USAGE:
   ipfs-update [global options] command [command options] [arguments...]

VERSION:
   1.5.1

COMMANDS:
     versions  Print out all available versions.
     version   Print out currently installed version.
     install   Install a version of ipfs.
     stash     stashes copy of currently installed ipfs binary
     revert    Revert to previously installed version of ipfs.
     fetch     Fetch a given version of ipfs. Default: latest.
     help, h   Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --verbose         Print verbose output.
   --distpath value  specify the distributions build to use
   --help, -h        show help
   --version, -v     print the version
```

`ipfs-update versions`でインストール可能なバージョンを一覧できる。

```console
$ ipfs-update versions
v0.3.2
v0.3.4
v0.3.5
v0.3.6
v0.3.7
v0.3.8
v0.3.9
v0.3.10
v0.3.11
v0.4.0
v0.4.1
v0.4.2
v0.4.3
v0.4.4
v0.4.5
v0.4.6
v0.4.7
v0.4.8
v0.4.9
v0.4.10
v0.4.11
```

できるだけ最新のバージョンをインストールする。
`ipfs-update install latest`でも最新版が得られるようだが、
`v0.4.7-rc1`のような安定版でないものをインストールしてくることがあるため、
明示的にバージョンを指定することが推奨されている。

```console
$ ipfs-update install v0.4.11
fetching go-ipfs version v0.4.11
binary downloaded, verifying...
success! tests all passed.
install failed, reverting changes...
could not find good install location
$ mkdir ~/bin
$ echo 'export PATH=$PATH:/home/kotet/bin' >> ~/.profile
$ source .profile
$ ipfs-update install v0.4.11
fetching go-ipfs version v0.4.11
binary downloaded, verifying...
success! tests all passed.
installing new binary to /home/kotet/bin/ipfs
checking if repo migration is needed...

Installation complete!
$ ipfs version
ipfs version 0.4.11
```

`~/bin`があるとそこにインストールしてくれるようだ。

### `ipfs init`

"global local object repository"なるものを作ってくれるらしい。
globalなのかlocalなのかはっきりしてほしい。

```console
$ ipfs init
initializing IPFS node at /home/kotet/.ipfs
generating 2048-bit RSA keypair...done
peer identity: QmcEYwrw73GpQrxDBN9Zn4y2K9S6f1epQNGrttXa3ZRPeg
to get started, enter:

	ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme

```

### readmeを読む

先ほど言われたとおりにしてみる。

```console
$ ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme
Hello and Welcome to IPFS!

██╗██████╗ ███████╗███████╗
██║██╔══██╗██╔════╝██╔════╝
██║██████╔╝█████╗  ███████╗
██║██╔═══╝ ██╔══╝  ╚════██║
██║██║     ██║     ███████║
╚═╝╚═╝     ╚═╝     ╚══════╝

If you're seeing this, you have successfully installed
IPFS and are now interfacing with the ipfs merkledag!

-
| Warning:                                              |
|   This is alpha software. Use at your own discretion! |
|   Much is missing or lacking polish. There are bugs.  |
|   Not yet secure. Read the security notes for more.   |
-

Check out some of the other files in this directory:

  ./about
  ./help
  ./quick-start     <-- usage examples
  ./readme          <-- this file
  ./security-notes
```

ここに貼り付けたものは表示が崩れてしまっているかもしれないが、自分の環境ではちゃんといい感じになっている。

![logo](/assets/2017/10/18/ipfs-logo.png)

### デーモンの起動

ログイン時に`ipfs daemon`してくれるようにする。

#### `~/.config/systemd/user/ipfs.service`

```
[Unit]
Description=IPFS daemon
After=network.target

[Service]
ExecStart=/home/kotet/bin/ipfs daemon
Restart=on-failure

[Install]
WantedBy=default.target
```

```console
$ systemctl --user enable --now ipfs
Created symlink from /home/kotet/.config/systemd/user/default.target.wants/ipfs.service to /home/kotet/.config/systemd/user/ipfs.service.
```

`http://localhost:5001/webui`をブラウザで開く。

![webui](/assets/2017/10/18/webui.png)

無事に"Fancy Web Console"を開くことができた。
"Connections"を見ると、接続中のPEERの数が100から500くらいの間で増えたり減ったりしている。
しかしコンピュータのファンの音が少し大きくなり、ちょっとリソースを使い過ぎな気もする。
今日はここまでにする。
次回は設定を確認してみようと思う。

### 読んだもの

- [IPFS Docs](https://ipfs.io/ipns/ipfs.io/docs/)
- [IPFS - ArchWiki](https://wiki.archlinux.jp/index.php/IPFS#.E3.82.B5.E3.83.BC.E3.83.93.E3.82.B9.E3.82.92.E4.BD.BF.E3.81.A3.E3.81.A6.E3.83.87.E3.83.BC.E3.83.A2.E3.83.B3.E3.82.92.E8.B5.B7.E5.8B.95)
