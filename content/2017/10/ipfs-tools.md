---
date: 2017-10-26
aliases:
- /2017/10/26/ipfs-tools.html
title: "IPFS体験記6:ipget"
tags:
- ipfs
- tech
- log
- ipfs体験記
excerpt: "そろそろキャッチコピーを考えるのが辛くなってきたのでやめる。
今回はIPFS用に作られたツールを見ていこうと思う。
いろいろ試したのだが、うまくインストールできたのはipgetだけだったのでそれだけ書く。"
---

そろそろキャッチコピーを考えるのが辛くなってきたのでやめる。
今回はIPFS用に作られたツールを見ていこうと思う。
いろいろ試したのだが、うまくインストールできたのはipgetだけだったのでそれだけ書く。

### ipget

wgetのIPFS版。
IPFSデーモン無しで動く。

インストールにGoが必要なので、まずはGoをインストールした。

```console
$ go version
go version go1.9.2 linux/amd64
$ go env
GOARCH="amd64"
GOBIN=""
GOEXE=""
GOHOSTARCH="amd64"
GOHOSTOS="linux"
GOOS="linux"
GOPATH="/home/kotet/go/bin"
GORACE=""
GOROOT="/home/kotet/go"
GOTOOLDIR="/home/kotet/go/pkg/tool/linux_amd64"
GCCGO="gccgo"
CC="gcc"
GOGCCFLAGS="-fPIC -m64 -pthread -fmessage-length=0 -fdebug-prefix-map=/tmp/go-build035064841=/tmp/go-build -gno-record-gcc-switches"
CXX="g++"
CGO_ENABLED="1"
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
```

Readmeの手順に従う。
gxというIPFSを使ったパッケージマネージャを使っているので`go get`ではインストールできないようだ。

```console
$ go get -d github.com/ipfs/ipget
package gx/ipfs/QmQa2wf1sLFKkjHCVEbna8y5qhdMjL8vtTJSAc48vZGTer/go-ipfs/path: unrecognized import path "gx/ipfs/QmQa2wf1sLFKkjHCVEbna8y5qhdMjL8vtTJSAc48vZGTer/go-ipfs/path" (import path does not begin with hostname)
package gx/ipfs/QmVcLF2CgjQb5BWmYFWsDfxDjbzBfcChfdHRedxeL3dV4K/cli: unrecognized import path "gx/ipfs/QmVcLF2CgjQb5BWmYFWsDfxDjbzBfcChfdHRedxeL3dV4K/cli" (import path does not begin with hostname)
package gx/ipfs/Qmdk8Ea9GkbwHr7UNKVYaLRwwHSt69xBXuSvRVyNWZ9sZE/fallback-ipfs-shell: unrecognized import path "gx/ipfs/Qmdk8Ea9GkbwHr7UNKVYaLRwwHSt69xBXuSvRVyNWZ9sZE/fallback-ipfs-shell" (import path does not begin with hostname)
$ cd ${GOPATH}/src/github.com/ipfs/ipget
$ make install
// 中略
$ ipget
usage: ipget <ipfs ref>
```

使ってみる。

```console
$ ipget QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
$ cat QmT78zSuBmuS4z925WZfrqQ1qHaJ56DQaTfyMUF7F8ff5o
hello world
```

なんだろう、あまり有り難みがない。
なにかIPFSからファイルをダウンロードしてくるツールを作るときに使うのだろうか。
