---
date: 2017-04-29
title: "dubで自力でCのsqrt()を呼び出す"
tags:
- dlang
- tech
---

[前回](/2017/04/28/use-c-stdio-in-d.html)の続き。
今度はヘッダファイルを読むのにプリプロセスの必要なものを使いたい、
ということで`core.stdc.math`を使わずにD言語のアプリケーションからC言語の`sqrt`を呼び出してみる。
自分みたいな初心者のための基礎的な記事を量産することを目標にしているので、細かい手順をできるだけ詳細に具体的に書いていきたい。

### 1 - `dub init`

前回と同じ。

```console
$ tree
.
├── dub.json
└── source
    └── app.d

1 directory, 2 files
```

### 2 - 関数の宣言を探す

`/usr/include/math.h`を読んでみる。

```console
$ cat /usr/include/math.h | grep sqrt
# define M_2_SQRTPI     1.12837916709551257390  /* 2/sqrt(pi) */
# define M_SQRT2        1.41421356237309504880  /* sqrt(2) */
# define M_SQRT1_2      0.70710678118654752440  /* 1/sqrt(2) */
# define M_2_SQRTPIl    1.128379167095512573896158903121545172L /* 2/sqrt(pi) */
# define M_SQRT2l       1.414213562373095048801688724209698079L /* sqrt(2) */
# define M_SQRT1_2l     0.707106781186547524400844362104849039L /* 1/sqrt(2) */
```

どうも宣言っぽいのは見つからない。

### 3 - プリプロセス

ヘッダファイル内のマクロとかを全部展開する必要がある。
`gcc -E`でコンパイルをせずにプリプロセスだけを行える。

```console
$ cat /usr/include/math.h | wc -l
537
$ gcc -E /usr/include/math.h | wc -l
5314
```

行数が10倍ほどになっている……

lessで開いて検索したところ、`sqrt`の宣言らしきものを見つけた。

```c
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h"
extern double
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
sqrt (
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h"
double
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
__x) __attribute__ ((__nothrow__ , __leaf__))
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h"
; extern double __sqrt
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
(
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h"
double
# 156 "/usr/include/x86_64-linux-gnu/bits/mathcalls.h" 3 4
__x) __attribute__ ((__nothrow__ , __leaf__));
```

超絶読みにくいが、整理するとこんなことが書いてある。

```c
extern double sqrt ( double __x) __attribute__ ((__nothrow__ , __leaf__));
extern double __sqrt ( double __x) __attribute__ ((__nothrow__ , __leaf__));
```

### 4 - 関数の宣言

というわけで前回と同じように`sqrt`だけを宣言する。

#### `source/math.d` (New file)

```d
extern (C) double sqrt(double __x);
```

### 5 - 使う

#### `source/app.d`

```d
import math;
import std.stdio;

void main()
{
	writeln("sqrt( 2 ) == ", sqrt(2));
}
```

### 6 - `dub build`

リンカオプションを渡してやる必要があると思ったがそんなことはなかったぜ!
今回はリンクするライブラリを指定する回になる予定だったのだが、結果的にプリプロセスをする回になった。

### 7 - 完成

```console
$ ./test
sqrt( 2 ) == 1.41421
```

---

### 追記

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr"><a href="https://twitter.com/kotetttt">@kotetttt</a> <a href="https://t.co/2CWXBfFs2k">https://t.co/2CWXBfFs2k</a><br>なんかちょっと解説みたいなの書いてみるか〜とかしたら怪文書になってしまいました。。蛇足はほんとに蛇足なので読まないでもぜんぜんいいやつです。</p>&mdash; ありがとうけものフレンズ (@shitsyndrome) <a href="https://twitter.com/shitsyndrome/status/859101734173458433">2017年5月1日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

---

[次回:OpenSSLを使う](/2017/05/03/use-c-sha256-in-d.html)