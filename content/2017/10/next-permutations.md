---
date: 2017-10-14
aliases:
- /2017/10/14/next-permutations.html
title: "D言語の2つのnext_permutation"
tags:
- dlang
- tech
excerpt: "このツイートを見て「そうだったのか！知らなかった！」と言ってググったが目が節穴なのでこうして記事を書きはじめるまで目の前の検索結果が読めなかった。 "
---

<blockquote class="twitter-tweet" data-lang="en"><p lang="ja" dir="ltr">D言語にもnextPermutationあるんですけどね(ごり押し)</p>&mdash; W521 (@yosupot) <a href="https://twitter.com/yosupot/status/918779682127994880?ref_src=twsrc%5Etfw">October 13, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

このツイートを見て「そうだったのか！知らなかった！」と言ってググったが~~目が節穴なのでこうして記事を書きはじめるまで目の前の検索結果が読めなかった。
悔しいので無視して~~「D言語 next_permutation」では出てこなかったので記事を書く。

### [`std.algorithm.sorting.nextPermutation`](https://dlang.org/library/std/algorithm/sorting/next_permutation.html)

C++の[`next_permutation`](https://cpprefjp.github.io/reference/algorithm/next_permutation.html)と同じもの。

```d
void main()
{
    import std.stdio;
    import std.algorithm : nextPermutation;

    auto ary = [1,2,3];
    do
    {
        writeln(ary);
    }
    while(nextPermutation(ary));
}
```

`BidirectionalRange`を全部の並べ方を列挙できるようにIn-placeで入れ替える。
最後になると`false`を返すため、上記のようにdo-whileで全パターンを列挙できる。

```
[1, 2, 3]
[1, 3, 2]
[2, 1, 3]
[2, 3, 1]
[3, 1, 2]
[3, 2, 1]
```

C++と同じように、全パターンを列挙するためには最初がソート済みでなければならない。

```d
void main()
{
    import std.stdio;
    import std.algorithm : nextPermutation;

    auto ary = [3,2,1]; // ソートされていない
    do
    {
        writeln(ary);
    }
    while(nextPermutation(ary));
}
```

```
[3, 2, 1]
```

### [`std.algorithm.iteration.Permutations`](https://dlang.org/library/std/algorithm/iteration/permutations.html)

こちらはより汎用的に使える。
与えられた`Range`のすべての並べ方の`Permutations!Range`、順列を返す。
ソート済みでなくても、そもそも要素が比較可能でなくともいいようだ。

```d
void main()
{
    import std.stdio;
    import std.algorithm : permutations, nextPermutation;
    import std.complex : complex;

    auto ary = [complex(1,1),
                complex(2,0),
                complex(3,-1)]; // 比較ができないためnextPermutationは動かない
    permutations(ary).writeln();
}
```

```
[[1+1i, 2+0i, 3-1i], [2+0i, 1+1i, 3-1i], [3-1i, 1+1i, 2+0i], [1+1i, 3-1i, 2+0i], [2+0i, 3-1i, 1+1i], [3-1i, 2+0i, 1+1i]]
```

"Heap's algorithm"というのを使っているらしいが、日本語の情報が全然なくてつらいので理解できたらまた別に記事を書こうと思う。

### 追記

Wikipediaの記事 "Heap's algorithm"を翻訳した。

[Heapのアルゴリズム - Wikipedia](https://ja.wikipedia.org/wiki/Heap%E3%81%AE%E3%82%A2%E3%83%AB%E3%82%B4%E3%83%AA%E3%82%BA%E3%83%A0)
