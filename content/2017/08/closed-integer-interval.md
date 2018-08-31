---
date: 2017-08-08
title: "整数閉区間のRange"
tags:
- dlang
- tech
excerpt: binary.h in Dで、 第二引数が含まれるiotaというか、そんな感じのRangeが欲しくなった。 つまり0と10が与えられたら[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]を返すようなやつである。
---

[binary.h in D](/2017/07/binary-h-in-d)で、
第二引数が含まれる`iota`というか、そんな感じのRangeが欲しくなった。
つまり`0`と`10`が与えられたら`[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]`を返すようなやつである。

### テンプレ

```d
int min = 0, max = 10;

// auto closedIntegerInterval = ...;

import std.stdio : writeln;
writeln(typeof(closedIntegerInterval).stringof, closedIntegerInterval);
```

### パターン1

```d
import std.range : iota;
import std.algorithm : map;

auto closedIntegerInterval = iota(min - 1, max).map!(n => n + 1);
```

```
MapResult!(__lambda1, Result)[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

### パターン2

```d
import std.range : iota;

auto closedIntegerInterval = iota(min, max + 1);
```

```
Result[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

パターン1、2ともにちゃんと動いてるっぽいが、パターン1の方は`min == int.min`のときに、
パターン2の方は`max == int.max`の時にバグる。
例の記事では型のすべての値を列挙したかったので、これではいけない。

### パターン3

```d
import std.range : chain, iota, only;

auto closedIntegerInterval = iota(min, max).chain(only(max));
```

```
Result[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

採用した方法。
これならどんな値にも対応できる。
もっとシンプルでわかりやすい書き方はないものか?