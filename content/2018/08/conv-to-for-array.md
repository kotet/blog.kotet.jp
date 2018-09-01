---
date: 2018-08-13
aliases:
- /2018/08/13/conv-to-for-array.html
title: "標準ライブラリの to で配列を変換する"
tags:
- dlang
- tech
---

D言語には`std.conv.to`という便利な関数がある。
これは配列の型も変換できるのだが、いままでうまく使えなくて毎回`.map!(to!long)`とかしてた。
この記事は自分みたいなエラーメッセージを読まない悲しい人間をこれ以上産まないためにある。

### うまくいかないパターン

```d
import std.conv : to;

string[] a = ["1", "2", "3", "4", "5"];
long[] b = a.to!long[];

assert(b == [1, 2, 3, 4, 5]);
```

`string`の配列を`long`の配列に変換したいのだが、これではコンパイルできない。
手元の DMD (v2.081.1) では以下のようなエラーが出る。

```
/usr/include/dlang/dmd/std/conv.d(222): Error: template std.conv.toImpl cannot deduce function from argument types !(long)(string[]), candidates are:
(中略)
app.d(5): Error: template instance `std.conv.to!long.to!(string[])` error instantiating
app.d(5): Error: only one index allowed to index long
```

### エラーメッセージを読め

つまりこういうことだ。
エラーが出ているのはこのコードである。

```d
long[] b = a.to!long[];
```

上のコードはこんな感じに解釈されている。

```d
long[] b = a.to!(long)()[];
```

こうして見ると何が問題かすぐにわかる (眠くて語彙が消失している)。

### 解決

テンプレート引数をカッコで囲んでやればいい。

```d
long[] b = a.to!(long[]);
```

こうしてやると正常に動くようになる。
1年くらい気づかずにいた気がする。
ひどい。