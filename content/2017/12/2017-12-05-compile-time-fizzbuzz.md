---
date: 2017-12-05
title: "マイナス時間で完了するfizzbuzz"
tags:
- dlang
- tech
excerpt: '"D言語なら、この程度の処理はマイナス時間で完了する。コンパイル時にメッセージまで出力し、プログラムが開始する前に全てを終わらせられるのだ。"'
---

> [D言語なら、この程度の処理はマイナス時間で完了する。
コンパイル時にメッセージまで出力し、プログラムが開始する前に全てを終わらせられるのだ。 - outland_karasuのコメント / はてなブックマーク](http://b.hatena.ne.jp/entry/348113957/comment/outland_karasu)

[前回]({% include relative %}{% post_url 2017/05/2017-05-13-compile-time-fizzbuzz %})からdmdのバージョンが上がり、
`static foreach`も入ったので[D言語 Advent Calendar 2017](https://qiita.com/advent-calendar/2017/dlang) 5日目の記事としてもう一度fizzbuzzを書いてみる。

しかし自分は記憶力がないのでそもそもfizzbuzzとは何かを忘れている。
ここであらためてfizzbuzzを説明しよう。

> 1から100までの数をプリントするプログラムを書け。
> ただし3の倍数のときは数の代わりに｢Fizz｣と、5の倍数のときは｢Buzz｣とプリントし、3と5両方の倍数の場合には｢FizzBuzz｣とプリントすること。[^1]

[^1]: [どうしてプログラマに・・・プログラムが書けないのか?](http://www.aoky.net/articles/jeff_atwood/why_cant_programmers_program.htm)

というわけで`static foreach`を使ってFizzBuzzを書いた。
解説するところがほぼ無いほど見た目だけは普通のFizzBuzzになった。

`std.conv.to`を使っている。
`mixin template`のなかで`import`すると`fizzbuzz`の外にも適用されてしまうのでは？と思っていたが[別にそんなこともない](https://dpaste.dzfl.pl/37f2916891e3)ようだ。
コンパイルオプション`-main`によって手書きしなければならない関数はゼロになった。

```d
/// fizzbuzz.d

mixin template fizzbuzz(long N) if (0 < N)
{
    import std.conv : to;
    static foreach (i; 1 .. N + 1)
    {
        static if (i % (3 * 5) == 0)
        {
            pragma(msg, "FizzBuzz");
        }
        else static if (i % 3 == 0)
        {
            pragma(msg, "Fizz");
        }
        else static if (i % 5 == 0)
        {
            pragma(msg, "Buzz");
        }
        else
        {
            pragma(msg, i.to!string);
        }

    }
}

mixin fizzbuzz!(100);

```

コンパイルするとFizzBuzzの結果が表示される。
なおコンパイルによる成果物を実行してもなにも表示されない。
「FizzBuzzを実行する」と心のなかで思ったなら、その時すでにFizzBuzzは終わっているのだ。

```console
$ dmd fizzbuzz.d -main
1
2
Fizz
4
Buzz
Fizz
7
8
Fizz
Buzz
11
Fizz
13
14
FizzBuzz
16
17
Fizz
19
Buzz
Fizz
22
23
Fizz
Buzz
26
Fizz
28
29
FizzBuzz
31
32
Fizz
34
Buzz
Fizz
37
38
Fizz
Buzz
41
Fizz
43
44
FizzBuzz
46
47
Fizz
49
Buzz
Fizz
52
53
Fizz
Buzz
56
Fizz
58
59
FizzBuzz
61
62
Fizz
64
Buzz
Fizz
67
68
Fizz
Buzz
71
Fizz
73
74
FizzBuzz
76
77
Fizz
79
Buzz
Fizz
82
83
Fizz
Buzz
86
Fizz
88
89
FizzBuzz
91
92
Fizz
94
Buzz
Fizz
97
98
Fizz
Buzz
```