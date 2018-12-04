---
date: 2017-12-04
aliases:
- /2017/12/04/d-from-source.html
title: "DMDとDUBをソースからインストールする"
tags:
- dlang
- log
- tech
- advent_calendar
excerpt: "最近D言語を書いていない。というかプログラミングらしいことをしていない。さらに今使っているコンピュータにはDMDがインストールされてすらいない。"
---

最近D言語を書いていない。
というかプログラミングらしいことをしていない。
さらに今使っているコンピュータにはDMDがインストールされてすらいない。

以前いろいろと前提となる基礎知識が欠けていてDMDのソースからのインストールができなかったのを思い出したので、とりあえずDMDのビルドをしようと思った。
[D言語 Advent Calendar 2017](https://qiita.com/advent-calendar/2017/dlang)の4日目のこの記事はその時の記録である。

出力はその場の気分で省略したりしなかったりしてある。
ものすごくのんびりやったため実際の作業は数日にわかれている。

`v2.077.0`と最新版をインストールしたのだが、思っていたよりも遥かに簡単で時間もかからなかった。
速すぎて冬場の暖房には使えないかもしれない。

### DMD

#### ソースのダウンロード

まずはソースをダウンロードしてくる。
最初は最新版ではなくバージョンを`v2.077.0`に指定してやってみようと思う。

```console
~$ mkdir src/dlang-v2.077.0
~$ cd src/dlang-v2.077.0/
~/src/dlang-v2.077.0$ git clone -b v2.077.0 https://github.com/dlang/dmd
~/src/dlang-v2.077.0$ git clone -b v2.077.0 https://github.com/dlang/druntime
~/src/dlang-v2.077.0$ git clone -b v2.077.0 https://github.com/dlang/phobos
~/src/dlang-v2.077.0$ git clone -b v2.077.0 https://github.com/dlang/tools
```

#### DMDのビルド

ある一定以上バージョンが上のDMDのビルドにはDMDが必要なので、
古いバージョンのDMDを自分でビルドするか、バイナリをダウンロードしてくる必要がある。
……と思っていたのだが、どうもそのあたりも[自分でやってくれる](https://wiki.dlang.org/Building_under_Posix#Bootstrap_dmd)らしい。
もちろんPATHの通ったDMDがすでにあるならそちらを使ってビルドを高速化できる。
しかしそんなことをしなくても割とあっという間に終わった。

```console
~/src/dlang-v2.077.0/dmd$ make -f posix.mak -j8 AUTO_BOOTSTRAP=1
```
```console
~/src/dlang-v2.077.0/dmd$ ./generated/linux/release/64/dmd --version
DMD64 D Compiler v2.077.0
Copyright (c) 1999-2017 by Digital Mars written by Walter Bright
```

#### その他のビルド

標準ライブラリのphobosをビルドする。
PATHを通していないのに`../dmd/generated/linux/release/64/dmd`を使ってくれる。
しかも`druntime`もいっしょにビルドされている。

```console
~/src/dlang-v2.077.0$ cd phobos/
~/src/dlang-v2.077.0/phobos$ make -f posix.mak -j8
```
```console
~/src/dlang-v2.077.0$ tree phobos/generated/
phobos/generated/
└── linux
    └── release
        └── 64
            ├── etc
            │   └── c
            │       └── zlib
            │           ├── adler32.o
            │           ├── compress.o
            │           ├── crc32.o
            │           ├── deflate.o
            │           ├── gzclose.o
            │           ├── gzlib.o
            │           ├── gzread.o
            │           ├── gzwrite.o
            │           ├── infback.o
            │           ├── inffast.o
            │           ├── inflate.o
            │           ├── inftrees.o
            │           ├── trees.o
            │           ├── uncompr.o
            │           └── zutil.o
            ├── libphobos2.a
            ├── libphobos2.so -> libphobos2.so.0.77.0
            ├── libphobos2.so.0.77 -> libphobos2.so.0.77.0
            ├── libphobos2.so.0.77.0
            └── libphobos2.so.0.77.o

6 directories, 20 files
~/src/dlang-v2.077.0$ tree druntime/generated/
druntime/generated/
└── linux
    └── release
        └── 64
            ├── bss_section.o
            ├── errno_c.o
            ├── libdruntime.a
            ├── libdruntime.so.a
            ├── libdruntime.so.o
            └── threadasm.o

3 directories, 6 files
```

#### 動作確認

`static foreach`を使ったことがないので試してみる。

```d
/// test.d

import std.stdio;

static foreach(i;0..10)
{
    pragma(msg,i);
}

void main()
{
    writeln("hello");
}
```
```console
~/src/dlang-v2.077.0$ dmd/generated/linux/release/64/dmd test.d
0
1
2
3
4
5
6
7
8
9
~/src/dlang-v2.077.0$ ./test 
hello
```

ちゃんと動いた。

#### インストール

適当な場所に置く。

```console
~/src/dlang-v2.077.0$ ln -s ~/src/dlang-v2.077.0/dmd/generated/linux/release/64/dmd ~/bin/ # ~/bin はPATHを通してあるディレクトリ
```
```console
~/src/dlang-v2.077.0$ which dmd
/home/kotet/bin/dmd
```

というわけで、これでDMD 2.077.0のインストールが完了した。
思っていたよりも短い時間でできてびっくりした。

### DUB

せっかくなのでこの調子でDUBもインストールする。

#### ビルド

DMDとlibcurlが必要らしいが両方あるのでそのまま`build.sh`を実行する。

```console
~/src$ git clone -b v1.6.0 https://github.com/dlang/dub.git dub-v1.6.0
~/src$ cd dub-v1.6.0/
~/src/dub-v1.6.0$ ./build.sh 
Generating version file...
Running dmd...
source/dub/internal/sdlang/token.d(26): Deprecation: struct core.time.FracSec is deprecated - FracSec has been deprecated in favor of just using Duration for the sake of simplicity
source/dub/internal/sdlang/token.d(26): Deprecation: struct core.time.FracSec is deprecated - FracSec has been deprecated in favor of just using Duration for the sake of simplicity
DUB version 1.6.0, built on Nov 15 2017
DUB has been built as bin/dub.

You may want to run
sudo ln -s /home/kotet/src/dub-v1.6.0/bin/dub /usr/local/bin
now.
```

#### インストール

`/usr/local/bin`へのインストールをおすすめされているが今回は`~/bin`にした。

```console
~/src/dub-v1.6.0$ ln -s /home/kotet/src/dub-v1.6.0/bin/dub ~/bin
```
```console
~/src/dub-v1.6.0$ which dub
/home/kotet/bin/dub
~/src/dub-v1.6.0$ dub --version
DUB version 1.6.0, built on Nov 15 2017
```

#### 動作確認

[D言語くんが走りだす](https://qiita.com/lempiji/items/03629cd46fcbd948ca41)。

```console
~$ dub fetch dl
Fetching dl 1.0.1...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.
~$ dub run dl
Building package dl in /home/kotet/.dub/packages/dl-1.0.1/dl/
Performing "debug" build using dmd for x86_64.
dl 1.0.1: building configuration "executable"...
Linking...
Running .dub/packages/dl-1.0.1/dl/dl 



  _   _
 (_) (_)
/______ \
\\(O(O \/
 | | | |
 | |_| |
/______/
  <   >
 (_) (_)
```

というわけでD言語の基本的なツールがインストールできた。
想像以上に簡単だった。
やはり何事もやってみることが大事ということだ。

### 最新版のビルド

せっかくなので最新版もビルドしてみる。
全く同じようにインストールを行える。

#### DMD

同じようにダウンロード。

```console
~/src$ mkdir dlang-$(date -I)
~/src$ ls
dlang-2017-11-22  dlang-v2.077.0  dub-v1.6.0
~/src$ cd dlang-2017-11-22/
~/src/dlang-2017-11-22$ git clone https://github.com/dlang/dmd
~/src/dlang-2017-11-22$ git clone https://github.com/dlang/druntime
~/src/dlang-2017-11-22$ git clone https://github.com/dlang/phobos
~/src/dlang-2017-11-22$ git clone https://github.com/dlang/tools
```

すでにDMDをインストール済みなのでそれを使ってくれる。

```console
~/src/dlang-2017-11-22/dmd$ make -f posix.mak -j8
```

```console
~/src/dlang-2017-11-22/dmd$ ./generated/linux/release/64/dmd --version
DMD64 D Compiler v2.077.0-251-g46fc949
Copyright (c) 1999-2017 by Digital Mars written by Walter Bright
```

続けてPhobos等のビルド。

```console
~/src/dlang-2017-11-22/dmd$ cd ../phobos/
~/src/dlang-2017-11-22/phobos$ make -f posix.mak -j8
```

インストール。

```console
~/src/dlang-2017-11-22/phobos$ ln -s ~/src/dlang-2017-11-22/dmd/generated/linux/release/64/dmd ~/bin/dmd-latest
```

動作確認。

```console
~$ which dmd-latest
/home/kotet/bin/dmd-latest
~$ dmd-latest --version
DMD64 D Compiler v2.077.0-251-g46fc949
Copyright (c) 1999-2017 by Digital Mars written by Walter Bright
~$ dmd-latest test.d
0
1
2
3
4
5
6
7
8
9
~$ ./test
hello
```

ちゃんと最新版の方のPhobosが使われているか確認するのを忘れていた。

```console
~$ dmd-latest --help
DMD64 D Compiler v2.077.0-251-g46fc949
Copyright (c) 1999-2017 by Digital Mars written by Walter Bright

Documentation: http://dlang.org/
Config file: /home/kotet/src/dlang-2017-11-22/dmd/generated/linux/release/64/dmd.conf
...
$ cat /home/kotet/src/dlang-2017-11-22/dmd/generated/linux/release/64/dmd.conf
[Environment32]
DFLAGS=-I%@P%/../../../../../druntime/import -I%@P%/../../../../../phobos -L-L%@P%/../../../../../phobos/generated/linux/release/32 -L--export-dynamic

[Environment64]
DFLAGS=-I%@P%/../../../../../druntime/import -I%@P%/../../../../../phobos -L-L%@P%/../../../../../phobos/generated/linux/release/64 -L--export-dynamic -fPIC
$ readlink -f /home/kotet/src/dlang-2017-11-22/dmd/generated/linux/release/64/../../../../../phobos/generated/linux/release/64
/home/kotet/src/dlang-2017-11-22/phobos/generated/linux/release/64
```

大丈夫そう。

#### DUB

せっかくなので先ほどの最新版を使ってビルドする。

```console
~/src$ git clone https://github.com/dlang/dub.git dub-$(date -I)
~/src$ cd dub-2017-11-22/
~/src/dub-2017-11-22$ DMD="dmd-latest" ./build.sh
Generating version file...
Running dmd-latest...
source/dub/internal/sdlang/token.d(26): Deprecation: struct core.time.FracSec is deprecated - FracSec has been deprecated in favor of just using Duration for the sake of simplicity
source/dub/internal/sdlang/token.d(26): Deprecation: struct core.time.FracSec is deprecated - FracSec has been deprecated in favor of just using Duration for the sake of simplicity
DUB version 1.6.0+28-gf7d620b, built on Nov 22 2017
DUB has been built as bin/dub.

You may want to run
sudo ln -s /home/kotet/src/dub-2017-11-22/bin/dub /usr/local/bin
now.
~/src/dub-2017-11-22$ ln -s /home/kotet/src/dub-2017-11-22/bin/dub ~/bin/dub-latest
```

動作確認。

```console
~$ which dub-latest 
/home/kotet/bin/dub-latest
~$ dub-latest --version
DUB version 1.6.0+28-gf7d620b, built on Nov 22 2017
~$ dub-latest fetch dl
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.
~$ dub-latest run dl
Building package dl in /home/kotet/.dub/packages/dl-1.0.1/dl/
Performing "debug" build using dmd for x86_64.
dl 1.0.1: target for configuration "executable" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
Running .dub/packages/dl-1.0.1/dl/dl 



  _   _
 (_) (_)
/______ \
\\(O(O \/
 | | | |
 | |_| |
/______/
  <   >
 (_) (_)

```