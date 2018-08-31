---
date: 2017-10-30
title: "IPFS体験記7:Windows"
tags:
- ipfs
- tech
- log
- ipfs体験記
excerpt: "今回はWindowsでIPFSを使ってみる。
一応ローカルゲートウェイを動かすことに成功した。"
---

今回はWindowsでIPFSを使ってみる。
一応ローカルゲートウェイを動かすことに成功した。

### ipfs-update

[ipfs-update](https://dist.ipfs.io/#ipfs-update)をダウンロードして展開、めんどくさいのでPATHを通さずその場で実行してみる。
`install.sh`は特に使うわけではないっぽい。
以下Powershell。

```
PS C:\Users\kotet_000\Downloads\ipfs-update_v1.5.2_windows-amd64\ipfs-update> ./ipfs-update
NAME:
   ipfs-update.exe - Update ipfs.

USAGE:
   ipfs-update.exe [global options] command [command options] [arguments...]

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

大丈夫そうに見える。さっそく最新の安定板をインストールする。

```
PS C:\Users\kotet_000\Downloads\ipfs-update_v1.5.2_windows-amd64\ipfs-update> ./ipfs-update versions
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
v0.4.12-rc1
PS C:\Users\kotet_000\Downloads\ipfs-update_v1.5.2_windows-amd64\ipfs-update> ./ipfs-update install v0.4.11
fetching go-ipfs version v0.4.11
binary downloaded, verifying...
install failed, reverting changes...
error initializing with new binary: exec: "C:\\Users\\KOTET_~1\\AppData\\Local\\Temp\\ipfs-update124567527\\ipfs-new": file does not exist:
```

どうも失敗したようだ。
実はどうも現在バグがあるらしい。

[ipfs-update doesn't work on Windows · Issue #32 · ipfs/ipfs-update](https://github.com/ipfs/ipfs-update/issues/32)

### 手動

しかたがないので手動でインストールする。

[go-ipfs](https://dist.ipfs.io/#go-ipfs)をダウンロードして展開。
READMEも改行コードがWindows仕様になってないし、やはりバイナリ以外は不要である。
`ipfs.exe`をPATHの通っているところに置くのだがやはりめんどくさいのでデスクトップに置く。

```
PS C:\Users\kotet_000\Desktop> ./ipfs version
ipfs version 0.4.11
PS C:\Users\kotet_000\Desktop> ./ipfs init
initializing IPFS node at C:\Users\kotet_000\.ipfs
generating 2048-bit RSA keypair...done
peer identity: QmeasmjdkwedopwF8GLwUThF8kxVKMbn5rLyXCUgMuzXd5
to get started, enter:

        ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme

PS C:\Users\kotet_000\Desktop> ./ipfs cat /ipfs/QmS4ustL54uo8FzR9455qaxZwuMiUhyvMcX9Ba8nUH4uVv/readme
Hello and Welcome to IPFS!

██╗██████╗ ███████╗███████╗
██║██╔══██╗██╔════╝██╔════╝
██║██████╔╝█████╗  ███████╗
██║██╔═══╝ ██╔══╝  ╚════██║
██║██║     ██║     ███████║
╚═╝╚═╝     ╚═╝     ╚══════╝

If you're seeing this, you have successfully installed
IPFS and are now interfacing with the ipfs merkledag!

 -------------------------------------------------------
| Warning:                                              |
|   This is alpha software. Use at your own discretion! |
|   Much is missing or lacking polish. There are bugs.  |
|   Not yet secure. Read the security notes for more.   |
 -------------------------------------------------------

Check out some of the other files in this directory:

  ./about
  ./help
  ./quick-start     <-- usage examples
  ./readme          <-- this file
  ./security-notes
```

いい感じである。
デーモンも起動してみる。
ファイアウォールで通信がブロックされ、ダイアログが出るのでアクセスを許可する。

```
PS C:\Users\kotet_000\Desktop> ./ipfs daemon
Initializing daemon...
Swarm listening on /ip4/127.0.0.1/tcp/4001
Swarm listening on /ip4/192.168.0.12/tcp/4001
Swarm listening on /ip4/192.168.56.1/tcp/4001
Swarm listening on /ip6/::1/tcp/4001
Swarm listening on /p2p-circuit/ipfs/QmeasmjdkwedopwF8GLwUThF8kxVKMbn5rLyXCUgMuzXd5
Swarm announcing /ip4/115.38.229.146/tcp/29125
Swarm announcing /ip4/127.0.0.1/tcp/4001
Swarm announcing /ip4/192.168.0.12/tcp/4001
Swarm announcing /ip4/192.168.56.1/tcp/4001
Swarm announcing /ip6/::1/tcp/4001
API server listening on /ip4/127.0.0.1/tcp/5001
Gateway (readonly) server listening on /ip4/127.0.0.1/tcp/8080
Daemon is ready
19:12:55.646 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:58.083 ERROR core/serve: ipfs resolve -r /ipns/ipfs.io/blog/index.json: no link named "blog" under QmPCawMTd7csXKf7QVr2B1QRDZxdPeWxtE4EpkDRYtJWty gateway_handler.go:593
19:12:59.319 ERROR core/serve: ipfs cat /ipns/ipfs.io/images/ipfs-illustrations-how-3.svg: Failed to get block for QmYrWgJ33ptegZS2coWTfSLnA6gBJmJ9jQBGMKBJdBStCZ: open C:\Users\kotet_000\.ipfs\blocks\KE\CIQJYOZWNOSPYJHT46H3GAMCAUPTUFQBDMBUJ4ECAUITI423B3BMKEQ.data: The process cannot access the file because it is being used by another process. gateway_handler.go:593
19:12:59.321 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.322 ERROR core/serve: ipfs cat /ipns/ipfs.io/images/ipfs-illustrations-how-5.svg: Failed to get block for QmS2ZnyfFvUrYAnrQ9kJTzuVMNHq5eMKkQyGkxYatSqppC: open C:\Users\kotet_000\.ipfs\blocks\L7\CIQDNTF4BXBAAAHBHGNZPGUWBCIPRLGJWNOSDGFNM6LAFSHASKG4L7I.data: The process cannot access the file because it is being used by another process. gateway_handler.go:593
19:12:59.505 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.507 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.506 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.515 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.633 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:12:59.756 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:14:25.015 ERROR        dht: checking dht client type: context canceled notif.go:81
19:14:59.797 ERROR        dht: checking dht client type: context canceled notif.go:81
19:18:29.629 ERROR core/serve: ipfs resolve -r /ipns/ipfs.io/blog/index.json: no link named "blog" under QmPCawMTd7csXKf7QVr2B1QRDZxdPeWxtE4EpkDRYtJWty gateway_handler.go:593
19:18:45.995 ERROR core/serve: ipfs resolve -r /ipns/ipfs.io/blog/index.json: no link named "blog" under QmPCawMTd7csXKf7QVr2B1QRDZxdPeWxtE4EpkDRYtJWty gateway_handler.go:593
19:20:43.918 ERROR        dht: checking dht client type: context canceled notif.go:81
19:21:04.290 ERROR core/serve: ipfs resolve -r /ipfs/QmPhnvn747LqwPYMJmQVorMaGbMSgA7mRRoyyZYz3DoZRQ/locale/webui-ja.json: no link named "webui-ja.json" under Qmc6bAsXTFFdvV3RoLuf6jjV3jzsRLntfsivWQZ75s8QaL gateway_handler.go:593
19:21:09.050 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:36.324 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:36.354 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:36.355 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:45.039 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:45.040 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:45.043 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:45.044 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:49.531 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:49.533 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.147 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.684 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.704 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.704 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.797 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.870 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.952 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:50.985 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.060 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.061 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.062 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.135 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.135 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.135 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.136 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.136 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.136 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.136 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.136 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.322 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.322 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.322 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.322 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.322 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.468 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.468 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.468 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
19:21:51.469 ERROR    bitswap: Error writing block to datastore: Access is denied. bitswap.go:317
// 後略
```

早速利用してみたが、エラーがものすごい勢いで出ている。
しかしとりあえず利用できる程度には動いているので今日のところは良しとする。
