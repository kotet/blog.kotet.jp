---
date: 2018-08-08
aliases:
- /2018/08/08/dpp.html
title: "dppでCのヘッダファイルを自動変換"
tags:
- dlang
- tech
- log
- cpplang
---

dpp というパッケージが登場し、使った人の好意的な声をよく聞くようになった。
自分はいまのところ C と連携するようなプログラムを書く予定はないが、
興味が出たので使ってみることにした。

### d++ - #include C and C++ headers in D files

D言語で書かれたプログラムは C のプログラムと互換性があり、リンクすることができる。
しかしそのためにはヘッダファイルを変換した D プログラムを用意する必要があり、
それが手間である。
ここを自動化できればとても嬉しく、D言語くんのO脚も治る(慣用句)。

dpp はそのためのソフトウェアである。

[Package dpp version 0.0.2 - DUB - The D package registry](https://code.dlang.org/packages/dpp)

### 使ってみる

さっそくREADMEの例を試してみる。

#### c.h

```c
#ifndef C_H
#define C_H

#define FOO_ID(x) (x*3)

int twice(int i);

#endif
```

#### c.c

```c
int twice(int i) { return i * 2; }
```

#### foo.dpp

```
#include "c.h"
void main() {
    import std.stdio;
    writeln(twice(FOO_ID(5)));  // yes, it's using a C macro here!
}
```

D プログラムの拡張子は`.dpp`にする。
C と同じように`#include`してやる。
D のフォーマッター等が動かなくなるのがちょっとつらい。

dpp は`.dpp`ファイルを`.d`プログラムに変換して dmd などに渡すラッパーである。
READMEではビルドしてできる`d++`という実行ファイルを使っているが、
`dub run`でも動かせる。
clang をインストールしておく必要があるので注意。

```console
$ dub fetch dpp
Fetching dpp 0.0.2...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.
$ dub run dpp -- foo.dpp c.o
Building package dpp in /home/kotet/.dub/packages/dpp-0.0.2/dpp/
Package unit-threaded can be upgraded from 0.7.46 to 0.7.47.
Package libclang can be upgraded from 0.0.6 to 0.0.7.
Use "dub upgrade" to perform those changes.
Performing "debug" build using /usr/bin/dmd for x86_64.
libclang 0.0.6: target for configuration "library" is up to date.
dpp 0.0.2: target for configuration "executable" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
Running ../../.dub/packages/dpp-0.0.2/dpp/bin/d++ foo.dpp c.o
$ ./foo 
30
```

`c.d` を書かずに C プログラムのリンクができた。

### 他にも試してみる

すでに`stdio.h`など複数のヘッダファイルが完全に変換できるようになっているらしい。
以前やった
[C の標準ライブラリの利用](/2017/04/use-c-stdio-in-d)
と同じことを dpp でやってみる。

#### app.dpp

```
#include "/usr/include/stdio.h"
import std.string : toStringz;

void main()
{
	puts("hello".toStringz);
}
```

C の標準ライブラリは自動的にリンクされるので`app.dpp`だけを渡せばいい。

```console
$ dub run dpp -- app.dpp
Building package dpp in /home/kotet/.dub/packages/dpp-0.0.2/dpp/
Package unit-threaded can be upgraded from 0.7.46 to 0.7.47.
Package libclang can be upgraded from 0.0.6 to 0.0.7.
Use "dub upgrade" to perform those changes.
Performing "debug" build using /usr/bin/dmd for x86_64.
libclang 0.0.6: target for configuration "library" is up to date.
dpp 0.0.2: target for configuration "executable" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
Running ../../../.dub/packages/dpp-0.0.2/dpp/bin/d++ app.dpp
$ ./app
hello
```

今回の場合は必要な行数が変わってないのであまりうまみがないが、
そうでない状況があることは容易に想像できる。

### C++

dpp は今のところ C のヘッダーファイルにしか対応していないが、
将来的には C++ のヘッダーファイルへの対応も予定しているそうだ。
まだバージョン 0.0.2 で問題も多いが、使えるようになれば
D を使った開発がより簡単になると思うのでうまくいくといいなと思った。 
