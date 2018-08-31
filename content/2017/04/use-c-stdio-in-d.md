---
date: 2017-04-28
title: "dubで自力でCの標準ライブラリを呼び出す"
tags:
- dlang
- tech
---

D言語はC言語のコードを使えるとは聞いたことはあったが、実際にそれをやったことはなくていまいち理解していなかったのでいろいろ試してみる。
調べても具体的な手順の全体について日本語の情報が少なかったので、基本的なことから細かく書いていきたい。

Cのコードを一切書かずに使えることを確認したいので、もともとあるライブラリを使いたい。
とりあえずサクッと試せるCのライブラリが思いつかなかったので、`core.stdc.stdio`を使わずにCの`puts`を呼び出してHelloWorldを書いてみる。

### 1 - `dub init`

まずは普通に`dub init`する。

```console
$ dub init
Package recipe format (sdl/json) [json]: 
Name [test]: 
Description [A minimal D application.]: 
Author name [kotet]: 
License [proprietary]: 
Copyright string [Copyright © 2017, kotet]: 
Add dependency (leave empty to skip) []: 
Successfully created an empty project in '/tmp/test'.
Package successfully created in .
```

```console
$ tree
.
├── dub.json
└── source
    └── app.d

1 directory, 2 files
```

### 2 - 関数の宣言

`stdio.h`は`/usr/include/`にあるので読んで`puts`を探してみる。

```console
$ cat /usr/include/stdio.h | grep puts
extern int fputs (const char *__restrict __s, FILE *__restrict __stream);
extern int puts (const char *__s);
/* This function does the same as `fputs' but does not lock the stream.
extern int fputs_unlocked (const char *__restrict __s,
```

使いたいのは`extern int puts (const char *__s);`なので、これだけDで宣言してみる。

#### `source/stdio.d` (New file)

```d
extern(C) int puts(const char* __s);
```

一行、これだけでいい。

### 3 - 使う

#### `source/app.d`

```d
import stdio;
import std.string : toStringz;

void main()
{
	puts("hello".toStringz);
}
```

`toStringz`はDの文字列をCの0終端文字列に変換するもの。

### 4 - `dub build`

Cの標準ライブラリはデフォルトで勝手にリンクされるので、今回は特に何かする必要はない。

```console
$ dub build
Performing "debug" build using dmd for x86_64.
test ~master: building configuration "application"...
Linking...
```

### 5 - 完成

```console
$ ./test
hello
```

簡単だった。
次は標準以外のライブラリを使ってみたい。

### 追記

[次回:sqrtを使う](/2017/04/29/use-c-math-in-d.html)