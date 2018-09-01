---
date: 2018-07-01
aliases:
- /2018/07/01/quine-mccluskey-d.html
title: "Dで書くクワイン・マクラスキー法"
tags:
- dlang
- tech
- log
mathjax: on
---

先日大学でクワイン・マクラスキー法(Quine-McCluskey algorithm)を習った。
簡単にプログラムに落とし込めそうでテンションが上がり、実際に書いてみることにした。
理解しようとググったときに、スライドのPDFとか、
ほぼコードをのせただけみたいな記事が多くて困ったので、解説も含めて記事にする。

### 論理式の簡単化

まずここにWikipediaの
[クワイン・マクラスキー法](https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AF%E3%82%A4%E3%83%B3%E3%83%BB%E3%83%9E%E3%82%AF%E3%83%A9%E3%82%B9%E3%82%AD%E3%83%BC%E6%B3%95)
のページから持ってきたブール関数\\(f\\)の真理値表がある。
ここで\\(x\\)はDon't care、つまり結果がどうなってもいいということを意味する。


|   | A | B | C | D | f |
| :-: | :-: | :-: | :-: | :-: | :-: |
| m0 | 0 | 0 | 0 | 0 | 0 |
|m1|0|0|0|1|0|
|m2|0|0|1|0|0|
|m3|0|0|1|1|0|
|m4|0|1|0|0|1|
|m5|0|1|0|1|0|
|m6|0|1|1|0|0|
|m7|0|1|1|1|0|
|m8|1|0|0|0|1|
|m9|1|0|0|1|x|
|m10|1|0|1|0|1|
|m11|1|0|1|1|1|
|m12|1|1|0|0|1|
|m13|1|1|0|1|0|
|m14|1|1|1|0|x|
|m15|1|1|1|1|1|


この真理値表から機械的に積和形の式を書くとめっちゃ長くなるが、論理変数の数が最も少ない最簡形まで簡単化すると下のようにめっちゃ短い2通りの論理式になる。

\\(
    \begin{align}
    f(A,B,C,D) &= B \overline{C} \overline{D} + A \overline{D} + A C\\\\ \\
    &= B \overline{C} \overline{D} + A \overline{B} + A C
    \end{align}    
\\)

論理式が簡単になると何が嬉しいのかというと、まず人間が読めるようになるというのがある。
文字数が減ると入力間違いが減る。

あと回路やプログラムに論理式を使うときも嬉しいと思う。
簡単化した式はそのぶん必要な論理演算の数が減っており、電子回路なら小型化できるし、プログラムなら冗長性を減らせる。

気をつけなければならないのが、この最簡形は空間的に最適だが時間的に最適とは限らないということだ。
計算に必要な論理ゲートの数を減らすのと引き換えに、論理ゲートの段数が増えることがある。
そうなると結果的に計算に必要な時間は増えてしまう。


### クワイン・マクラスキー法

そんな簡単化をする方法は色々あるが、その中でコンピュータで自動化しやすいのがクワイン・マクラスキー法である。
クワイン・マクラスキー法では[加法標準形](https://ja.wikipedia.org/wiki/%E9%81%B8%E8%A8%80%E6%A8%99%E6%BA%96%E5%BD%A2)という形の論理式を最簡化する。
要するに上の式みたいにANDとNOTでできた項をORで繋いだ形のことである。

クワイン・マクラスキー法は以下のステップに分かれている。

1. 真理値表などを加法標準形に変換
1. 主項(素項)を見つける
    1. 項をハミング重みで分類
    1. 項をまとめる
    1. くりかえす
1. 主項を組み合わせて最簡形にする

自分は加法標準形への変換以外の部分を書いた。
以降コードとともに手順を書いていく。

#### 入出力の定義

最初に関数の形を決めておく。

```d
enum Literal
{
    T, // Term
    N, // ¬Term
    X // Null
}

alias Conjunction = Literal[];
alias DNF = Conjunction[]; // Disjunctive normal form

DNF[] qm(DNF dnfin, size_t[] dontcare)
```

項はリテラルの配列として表す。
たとえば\\(B \overline{C} \overline{D}\\)なら`[X, T, N, N]`というふうになる。
配列の長さは変数の数であり、ばらばらの長さの配列が与えられることはないとする。

加法標準形の式は項の配列として表す。
つまり\\(B \overline{C} \overline{D} + A \overline{D} + A C\\)なら`[[X, T, N, N], [T, X, X, N], [T, X, T, X]]`となる。

リテラル、項、式をそれぞれ`Literal`、`Conjunction`、`DNF`として定義する。
クワイン・マクラスキー法の関数`qm`は、`DNF`とDon't careの項のインデックスを受取りそのすべての最簡形を`DNF[]`として返す。

簡単な動作確認としてユニットテストがついている。
もうなんかめんどくさいのでこのテストが通ったら完成とする。

```d
unittest
{
    // https://ja.wikipedia.org/wiki/%E3%82%AF%E3%83%AF%E3%82%A4%E3%83%B3%E3%83%BB%E3%83%9E%E3%82%AF%E3%83%A9%E3%82%B9%E3%82%AD%E3%83%BC%E6%B3%95
    DNF input = () {
        with (Literal)
            return [// dfmt off
                [N, T, N, N],
                [T, N, N, N],
                [T, N, N, T],// Don't care
                [T, N, T, N],
                [T, T, N, N],
                [T, N, T, T],
                [T, T, T, N],// Don't care
                [T, T, T, T]
            ];
            // dfmt on
    }();
    DNF[] output = () {
        with (Literal)
            return // dfmt off
            [
                [[X, T, N, N], [T, X, X, N], [T, X, T, X]], // B¬C¬D + A¬D + AC
                [[X, T, N, N], [T, N, X, X], [T, X, T, X]] // B¬C¬D + A¬B + AC
            ];
            // dfmt on
    }();
    assert(qm(input, [2, 6]) == output);
}
```

#### ハミング重み、ハミング距離、項のマージ

ここで`qm`の実装に必要な関数を作っておく。
まずはハミング重み。
これは項の中の`T`の数を数える。

```d
size_t hammingWeight(Conjunction a)
{
    import std.algorithm : filter, map, sum;

    return a.filter!(x => x == Literal.T)
        .map!(x => 1)
        .sum;
}

unittest
{
    with (Literal)
    {
        assert(hammingWeight([N, N, N]) == 0);
        assert(hammingWeight([N, N, T]) == 1);
        assert(hammingWeight([T, T, T]) == 3);
        assert(hammingWeight([X, N, T]) == 1);
    }
}
```

次にハミング距離。
2つの項の中で異なるリテラルの数を数える。

```d
size_t hammingDistance(Conjunction a, Conjunction b)
{
    import std.algorithm : filter, map, sum;
    import std.range : zip;

    return zip(a, b).filter!(t => t[0] != t[1])
        .map!(x => 1)
        .sum;
}

unittest
{
    with (Literal)
    {
        assert(hammingDistance([T, T, T], [T, T, T]) == 0);
        assert(hammingDistance([N, N, N], [N, N, T]) == 1);
        assert(hammingDistance([T, N, T], [N, T, N]) == 3);
        assert(hammingDistance([T, N, X], [T, X, T]) == 2);
    }
}
```

`hammingDistance(a, b) == 1`のとき、`a`、`b`は

\\(
    \begin{align}
    X\cdot P + \overline{X}\cdot P &= (X + \overline{X})\cdot P\\\\ \\
    &= I\cdot P = P
    \end{align}
\\)

を用いてマージできる。

```d
Conjunction merge(Conjunction a, Conjunction b)
{
    assert(hammingDistance(a, b) == 1);
    auto result = new Conjunction(a.length);
    foreach (i, ref l; result)
        if (a[i] == b[i])
        {
            l = a[i];
        }
        else
        {
            l = Literal.X;
        }
    return result;
}

unittest
{
    with (Literal)
    {
        assert(merge([T, T, T], [T, T, N]) == [T, T, X]);
        assert(merge([N, X, N], [N, X, T]) == [N, X, X]);
    }
}

```

#### 主項をみつける

`qm`に戻って、いよいよアルゴリズムを書いていくが、
その前にクワイン・マクラスキー法がなぜクワイン・マクラスキー法というかをここで解説しておく。

まず最初にクワイン法というものがあった。
これはさっきの\\(X\cdot P + \overline{X}\cdot P = P\\)を適用できる項があるかをひたすら全部の組み合わせについて見ていく方法である。
アルゴリズムとしてはハミング距離が1になっている組を総当りで見つけてマージ、というのを繰り返していくことになると思う。

ここで、マクラスキー法によって総当りしなくてもハミング重みが1違う組だけを調べればいいということがわかった。
2つを組み合わせてクワイン・マクラスキー法というわけだ。

速度を考えずにとりあえず動くものを書くことを目標にしている今回はすべての項のハミング距離を調ベようと考えていたのだが、
そうしてしまうとマクラスキー要素がなくなってしまうのでちゃんと書く。

あと、ここでマージ元を覚えておく。
そのために`TaggedConjunction`というものを新たに作って、関数内部ではそれを使うようにしている。

```d
DNF[] qm(DNF dnfin, size_t[] dontcare)
{

    import std.algorithm : sort, uniq, any, fold, equal, filter, map, sum;
    import std.range : array, iota, back, popBack, zip, empty;

    size_t size = dnfin[0].length;

    struct TaggedConjunction
    {
        bool flag;
        size_t[] mergedfrom;
        Conjunction conjunction;
    }

    TaggedConjunction[] merged;
    TaggedConjunction[] prime;

    foreach (i, c; dnfin)
        merged ~= TaggedConjunction(false, [i], c);
```

そして以下がマージ部。
マージされた項を`flag`で覚えておいて、マージされなかった項は主項として`prime`に追加しておく。
`foreach`が3重になっており、その中の`merge`でもループがあるので繰り返し1回ごとに4重ループが回る。
実用するためにはマクラスキー要素で総当りの量を減らせると嬉しいのがわかる。

```d
    do
    {
        auto table = new TaggedConjunction[][](size + 1);
        foreach (c; merged)
            table[hammingWeight(c.conjunction)] ~= c;

        merged = [];

        foreach (i; 0 .. size)
            foreach (ref c1; table[i])
                foreach (ref c2; table[i + 1])
                    if (hammingDistance(c1.conjunction, c2.conjunction) == 1)
                    {
                        auto mergedfrom = (c1.mergedfrom ~ c2.mergedfrom).sort.uniq.array();
                        auto mergedconjunction = merge(c1.conjunction, c2.conjunction);
                        merged ~= TaggedConjunction(false, mergedfrom, mergedconjunction);

                        c1.flag = true;
                        c2.flag = true;
                    }

        foreach (t; table)
            foreach (c; t)
                if (c.flag == false && !any!(x => x == c)(prime))
                    prime ~= c;
    }
    while (merged != []);
```

#### 最簡形を求める

先程求められた主項`prime`の、入力の式を完全にカバーする組み合わせを見つける。
このためにマージ元を覚えておいてある。
入力の**Don't care以外の**すべての項がカバーされるように主項を選ぶ。
「Don't care以外の」というところをここに来るまで見落としていて大変なことになった。

あらかじめ絶対必要な項を見つけておいて総当りの量を減らしたり、
ペトリック法というアルゴリズムを使ったりするようだが気にせず総当り。
ペトリック法は日本語の情報が少ない。
そのうち調べてみたい。

```d
    size_t min = size_t.max;
    DNF[] result;
    bool[] stack = [false];

    while (true)
    {
        if (stack.length < prime.length)
        {
            stack ~= false;
        }
        else
        {
            bool isCovered = zip(stack, prime).map!(x => (x[0]) ? x[1].mergedfrom : [])
                .fold!((a, b) => a ~ b)
                .sort
                .uniq
                .filter!(n => !any!(d => d == n)(dontcare))
                .equal(iota(0, dnfin.length).filter!(n => !any!(d => d == n)(dontcare)));
            if (isCovered)
            {
                auto tmp = zip(stack, prime).filter!(x => x[0])
                    .map!(x => x[1].conjunction)
                    .array;
                size_t s = tmp.fold!((a, b) => a ~ b)
                    .map!(l => (l != Literal.X) ? 1 : 0)
                    .sum();
                if (s < min)
                {
                    min = s;
                    result = [tmp];
                }
                else if (s == min)
                {
                    result ~= tmp;
                }
            }

            while (!stack.empty && stack.back)
                stack.popBack();
            if (stack.empty)
                return result;
            stack.popBack();
            stack ~= true;
        }
    }
```

#### 完成

そういうわけでクワイン・マクラスキー法が実装できた。
動かしてみる。

```console
$ time dmd -main -unittest qm.d && ./qm 

real	0m1.040s
user	0m0.850s
sys	0m0.178s
```

ユニットテストをしているだけなので何も表示されなくてちょっとさみしい。
コンパイル時間も含めて1秒で計算が終わった。
こんな雑に書いても人間に比べれば一瞬で終わらせられるのがコンピューターのいいところだと思う。

### できたもの

全体はgistに上げた。

[Quine-McCluskey algorithm](https://gist.github.com/kotet/e0ba2b1e74705f5d9a170d2459589797)

まだどう書けばいいのかはっきり思い浮かばないが、気力があったらHaskellでも書いてみたい。

### 参考文献

[ブール代数とその応用 (東海大学出版会): 1983](http://iss.ndl.go.jp/books/R100000002-I000001611921-00)