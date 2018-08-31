---
date: 2017-09-10
title: "Dで巡るソートアルゴリズム その1"
tags:
- log
- dlang
- tech
excerpt: "最近はプログラミングについてあまり大きいものを作ったり複雑なものを考えたりする時間がとれないので、
1.それなりにプログラムしてる感がある
2.達成感を得るまでの作業量が少ない
という課題が欲しかった。 そこでソートの実装をすることにした。"
---

最近はプログラミングについてあまり大きいものを作ったり複雑なものを考えたりする時間がとれないので、

1. それなりにプログラムしてる感がある
2. 達成感を得るまでの作業量が少ない

という課題が欲しかった。
そこでソートの実装をすることにした。
なんだかんだいって今までバブルソートしか書いたことがない。
最近体調が良くなったことに関連してか頭が働き、Wikipediaの解説を読んで理解できるようになっていたので、
実際に書いてみたくなったのである。
そこそこ数が増えてきたので、それぞれのソートを書いた時に知ったことなどを記録する。

すべてのコードは[kotet/sort](https://github.com/kotet/sort)にある。

### テスト

まずはテスト用のコードを書く。
このモジュールの`mixin template test(alias F)`は、与えられた関数`F`の実行時間を計測する。
`mixin test!<ソート関数の名前>`と書けばその場にユニットテストのコードが生成される。
要素数`10 ^^ n`の配列を`F`でソートするというのを100ミリ秒間ひたすら繰り返し、平均の実行時間を出す。
なお、ソートする配列は`iota(10 ^^ n)`をシャッフルしたものである。
つまり、要素は整数で、重複はない。

#### [sort/test.d at cced9aa354ad54af4ba072f28775350503beb298 · kotet/sort](https://github.com/kotet/sort/blob/cced9aa354ad54af4ba072f28775350503beb298/source/test/test.d)

```d
module test;

static import std.algorithm.sorting;

mixin test!(std.algorithm.sorting.sort);

mixin template test(alias F)
{
    unittest
    {
        import std.stdio : writefln;
        import std.traits : fullyQualifiedName;
        import std.algorithm : map, reduce;
        import std.range : iota;

        writefln!"Test %s:"(fullyQualifiedName!F);

        size_t sample;
        size_t n;
        do
        {
            import std.datetime : StopWatch;
            import core.time : TickDuration;

            n++;
            sample = 0;
            double result = 0;
            StopWatch s;
            s.start();
            do
            {
                sample++;
                result += () {
                    import std.random : randomShuffle;
                    import std.range : array, iota;
                    import std.datetime : StopWatch, to;
                    import std.conv : to;

                    auto random = iota(10 ^^ n).array();
                    random.randomShuffle();
                    auto answer = iota(10 ^^ n).array();

                    StopWatch s;
                    s.start();

                    F(random);

                    s.stop();

                    assert(random == answer);
                    return s.peek().to!("msecs", double);
                }();
            }
            while (s.peek() < TickDuration.from!"msecs"(100));

            writefln!"    N = 10^^%s avg: %s msecs (sample: %s)"(n, result / sample, sample);
        }
        while (1 < sample);
    }
}
```

以下こんな感じのPCでテストしている。
計測時間はこの環境で`dub test`した結果の抜粋である。

```
メモリ: 7.7 GiB
プロセッサ: Intel® Core™ i7-3770S CPU @ 3.10GHz × 8 
```
```console
$ uname -a
Linux USB 4.4.0-93-generic #116-Ubuntu SMP Fri Aug 11 21:17:51 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
$ cat /etc/lsb-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.3 LTS"
```

### [`std.algorithm.sorting.sort`](https://dlang.org/phobos/std_algorithm_sorting.html#.sort)

まずは標準ライブラリのソートの実行時間を計測してみる。

```
Test std.algorithm.sorting.sort:
    N = 10^^1 avg: 0.000459964 msecs (sample: 55200)
    N = 10^^2 avg: 0.0158511 msecs (sample: 3797)
    N = 10^^3 avg: 0.178063 msecs (sample: 359)
    N = 10^^4 avg: 2.1236 msecs (sample: 32)
    N = 10^^5 avg: 24.5707 msecs (sample: 3)
    N = 10^^6 avg: 275.012 msecs (sample: 1)
```

特にパラメータを指定せずに呼ぶと、
この関数は[イントロソートになる](https://github.com/dlang/phobos/blob/416e0c76cd15a3695637b33a281f3790a562f8f0/std/algorithm/sorting.d#L1850)。

### [バブルソート](https://ja.wikipedia.org/wiki/%E3%83%90%E3%83%96%E3%83%AB%E3%82%BD%E3%83%BC%E3%83%88)

たぶん一番シンプルな部類のソート。
インプレース(ここでは入力のサイズが大きくなっても確保するメモリの量が変わらないことを言うことにする)。
普通に書いたのに`@nogc`をつけることができて驚いた。
スライスや`foreach`ではGCは一切動かないらしい。

#### [sort/v1.d at 5c09eab81b390230fa986ca72d6b24a5bf5aa06f · kotet/sort](https://github.com/kotet/sort/blob/5c09eab81b390230fa986ca72d6b24a5bf5aa06f/source/bubble/v1.d)

```d
module bubble.v1;

import test;

mixin test!sort;

void sort(T)(T[] random) @nogc nothrow pure
{
    foreach (i, n; random)
    {
        foreach (j, m; random[0 .. $ - i - 1])
        {
            if (random[j + 1] < m)
            {
                random[j] = random[j + 1];
                random[j + 1] = m;
            }
        }
    }
}
```
```
Test bubble.v1.sort:
    N = 10^^1 avg: 0.000674258 msecs (sample: 30006)
    N = 10^^2 avg: 0.0330249 msecs (sample: 2087)
    N = 10^^3 avg: 2.09396 msecs (sample: 46)
    N = 10^^4 avg: 257.32 msecs (sample: 1)
```

### [コムソート](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%A0%E3%82%BD%E3%83%BC%E3%83%88)

これも`@nogc`かつインプレース。

#### [sort/v1.d at 20fb6d7179e74c788b2810241c1a53cc1e5bfcb4 · kotet/sort](https://github.com/kotet/sort/blob/20fb6d7179e74c788b2810241c1a53cc1e5bfcb4/source/comb/v1.d)

```d
module comb.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{
    size_t gap = array.length;
    bool complete;
    do
    {
        complete = true;
        if (gap != 1)
            gap = gap * 10 / 13; // gap /= 1.3
        foreach (i, n; array[0 .. $ - gap])
        {
            if (array[i + gap] < n)
            {
                complete = false;
                array[i] = array[i + gap];
                array[i + gap] = n;
            }
        }
    }
    while (!(complete && (gap == 1)));
}
```

同じ時間でバブルソートの100倍くらい長いデータを処理できるようになった。

```
Test comb.v1.sort:
    N = 10^^1 avg: 0.000322626 msecs (sample: 59212)
    N = 10^^2 avg: 0.00597093 msecs (sample: 5986)
    N = 10^^3 avg: 0.0972022 msecs (sample: 502)
    N = 10^^4 avg: 1.40517 msecs (sample: 42)
    N = 10^^5 avg: 17.3313 msecs (sample: 4)
    N = 10^^6 avg: 214.626 msecs (sample: 1)
```

### [ストゥージソート](https://ja.wikipedia.org/wiki/%E3%82%B9%E3%83%88%E3%82%A5%E3%83%BC%E3%82%B8%E3%82%BD%E3%83%BC%E3%83%88)

再帰があるのでインプレースではないが`@nogc`。
バブルソートよりも遅いソート。

#### [sort/v1.d at bed400da50b4e9484ca250b354667e59e515b970 · kotet/sort](https://github.com/kotet/sort/blob/bed400da50b4e9484ca250b354667e59e515b970/source/stooge/v1.d)

```d
module stooge.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{
    if (array[$ - 1] < array[0])
    {
        immutable tmp = array[0];
        array[0] = array[$ - 1];
        array[$ - 1] = tmp;
    }
    if (3 <= array.length)
    {
        sort(array[0 .. $ - ($ / 3)]);
        sort(array[$ / 3 .. $]);
        sort(array[0 .. $ - ($ / 3)]);
    }
}
```
見ての通りものすごい勢いで実行時間が増えていく。
```
Test stooge.v1.sort:
    N = 10^^1 avg: 0.00468215 msecs (sample: 16549)
    N = 10^^2 avg: 3.32466 msecs (sample: 30)
    N = 10^^3 avg: 789.923 msecs (sample: 1)
```

### [マージソート](https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%BC%E3%82%B8%E3%82%BD%E3%83%BC%E3%83%88)

#### v1

素直に書いたもの。
1再帰ごとに配列を新しく2つ作るので`@nogc`ではないしインプレースでもない。
配列の中身をコピーする際は`array = ...`ではなく`array[] = ...`と書かなければならないことを知る。

##### [sort/v1.d at 80841549125d5d308af2c426c9539df69fb847c5 · kotet/sort](https://github.com/kotet/sort/blob/80841549125d5d308af2c426c9539df69fb847c5/source/merge/v1.d)

```d
module merge.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) nothrow pure
{
    array[] = mergeSort(array);
}

private T[] mergeSort(T)(T[] array) nothrow pure
{
    import std.range : empty, front, popFront;

    if (array.length < 2)
    {
        return array;
    }
    else
    {
        auto a = mergeSort(array[0 .. $ / 2]);
        auto b = mergeSort(array[$ / 2 .. $]);
        T[] result;

        foreach (i; 0 .. a.length + b.length)
        {
            if (a.empty)
            {
                result ~= b.front;
                b.popFront();
            }
            else if (b.empty || a.front < b.front)
            {
                result ~= a.front;
                a.popFront();
            }
            else
            {
                result ~= b.front;
                b.popFront();
            }
        }

        return result;
    }
}
```
```
Test merge.v1.sort:
    N = 10^^1 avg: 0.00433028 msecs (sample: 17535)
    N = 10^^2 avg: 0.0651478 msecs (sample: 1314)
    N = 10^^3 avg: 0.838199 msecs (sample: 107)
    N = 10^^4 avg: 9.77354 msecs (sample: 10)
    N = 10^^5 avg: 111.571 msecs (sample: 1)
```

#### v2

入力を再利用することで使うメモリの量を半分にしたもの。
関数を分ける必要もなくなった。

##### [sort/v2.d at 1ec94956420cb3463a357c99c05c7980fd48e994 · kotet/sort](https://github.com/kotet/sort/blob/1ec94956420cb3463a357c99c05c7980fd48e994/source/merge/v2.d)

```d
module merge.v2;

import test;

mixin test!sort;

void sort(T)(T[] array) nothrow pure
{
    import std.range : empty, front, popFront;

    if (array.length < 2)
    {
        return;
    }

    sort(array[0 .. $ / 2]);
    sort(array[$ / 2 .. $]);

    auto f = array[0 .. $ / 2].dup;
    size_t b = array.length / 2;
    foreach (i; 0 .. array.length)
    {
        if (f.empty)
        {
            array[i] = array[b];
            b++;
        }
        else if (!(b < array.length) || f.front < array[b])
        {
            array[i] = f.front;
            f.popFront();
        }
        else
        {
            array[i] = array[b];
            b++;
        }
    }
}
```

そのおかげかどうか知らないが高速になっている。
```
Test merge.v2.sort:
    N = 10^^1 avg: 0.00138706 msecs (sample: 36282)
    N = 10^^2 avg: 0.019115 msecs (sample: 3258)
    N = 10^^3 avg: 0.252587 msecs (sample: 283)
    N = 10^^4 avg: 3.0727 msecs (sample: 25)
    N = 10^^5 avg: 35.7877 msecs (sample: 3)
    N = 10^^6 avg: 408.831 msecs (sample: 1)
```
#### v3

並列処理が大好きなので並列化を試みた。
`std.parallelism`のドキュメントにある[`parallelSort`](https://dlang.org/phobos/std_parallelism.html#.task)を参考にした。
複数のスレッドが同じ配列に同時にアクセスしているはずだが、スライスで渡しているので間違えて違う領域にアクセスしていたら教えてくれる……はず。
好きな割に並列処理の知識がないので危険なことをしているかもしれない。
あと`spinForce`、`yieldForce`、`workForce`の違いがわかっていない。

##### [sort/v3.d at e165ee036421132e17760a9c264c260a2cf93dc9 · kotet/sort](https://github.com/kotet/sort/blob/e165ee036421132e17760a9c264c260a2cf93dc9/source/merge/v3.d)

```d
module merge.v3;

import test;

mixin test!sort;

void sort(T)(T[] array)
{
    parallelSort(array);
}

void parallelSort(T)(T[] array)
{
    if (array.length < 10 ^^ 4)
    {
        serialSort(array);
    }
    else
    {
        import std.parallelism : task;

        auto t = task!parallelSort(array[$ / 2 .. $]);
        t.executeInNewThread();

        parallelSort(array[0 .. $ / 2]);

        t.yieldForce();

        merge(array);
    }
}

void serialSort(T)(T[] array)
{
    if (array.length < 2)
        return;
    sort(array[0 .. $ / 2]);
    sort(array[$ / 2 .. $]);
    merge(array);
}

void merge(T)(T[] array)
{
    import std.range : empty, front, popFront;

    auto f = array[0 .. $ / 2].dup;
    size_t b = array.length / 2;
    foreach (i; 0 .. array.length)
    {
        if (f.empty)
        {
            array[i] = array[b];
            b++;
        }
        else if (!(b < array.length) || f.front < array[b])
        {
            array[i] = f.front;
            f.popFront();
        }
        else
        {
            array[i] = array[b];
            b++;
        }
    }
}
```
無事に速くなり、`10 ^^ 6`要素のソートでは標準のソートよりもいい結果を出した。
欲を出せばv2の半分まで速くなって欲しかったが……
```
Test merge.v3.sort:
    N = 10^^1 avg: 0.00155898 msecs (sample: 34202)
    N = 10^^2 avg: 0.0208756 msecs (sample: 3090)
    N = 10^^3 avg: 0.266927 msecs (sample: 273)
    N = 10^^4 avg: 2.77565 msecs (sample: 27)
    N = 10^^5 avg: 26.7383 msecs (sample: 3)
    N = 10^^6 avg: 240.102 msecs (sample: 1)
```

### [選択ソート](https://ja.wikipedia.org/wiki/%E9%81%B8%E6%8A%9E%E3%82%BD%E3%83%BC%E3%83%88)

インプレースで`@nogc`。

#### [sort/v1.d at beb460e0fae52440e9995d9871bd4e219c973cf2 · kotet/sort](https://github.com/kotet/sort/blob/beb460e0fae52440e9995d9871bd4e219c973cf2/source/selection/v1.d)

```d
module selection.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{
    foreach (i; 0 .. array.length)
    {
        select(array[i .. $]);
    }
}

void select(T)(T[] array) @nogc nothrow pure
{
    auto i = min(array);
    auto tmp = array[0];

    array[0] = array[i];
    array[i] = tmp;
}

size_t min(T)(T[] array) @nogc nothrow pure
{
    size_t result = 0;
    foreach (i; 0 .. array.length)
    {
        if (array[i] < array[result])
        {
            result = i;
        }
    }
    return result;
}
```
そんなに速くない。
```
Test selection.v1.sort:
    N = 10^^1 avg: 0.000410303 msecs (sample: 56998)
    N = 10^^2 avg: 0.0159089 msecs (sample: 3806)
    N = 10^^3 avg: 1.1031 msecs (sample: 84)
    N = 10^^4 avg: 105.882 msecs (sample: 1)
```

### [ヒープソート](https://ja.wikipedia.org/wiki/%E3%83%92%E3%83%BC%E3%83%97%E3%82%BD%E3%83%BC%E3%83%88)

#### v1
インプレースで`@nogc`。
スワップを関数に分けた。
`upHeap`、`downheap`がバグって手こずった。

##### [sort/v1.d at 0a9ef66f909f539fb46f752c661b4482a3854901 · kotet/sort](https://github.com/kotet/sort/blob/0a9ef66f909f539fb46f752c661b4482a3854901/source/heap/v1.d)

```d
module heap.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{

    foreach (i; 0 .. array.length)
    {
        upHeap(array[0 .. i + 1]);
    }
    foreach_reverse (i; 0 .. array.length)
    {
        downHeap(array[0 .. i + 1]);
    }
}

void upHeap(T)(T[] heap) @nogc nothrow pure
{
    size_t element = heap.length;
    while (element != 1)
    {
        size_t parent = (element) / 2;
        if (heap[parent - 1] < heap[element - 1])
        {
            swap(heap[parent - 1], heap[element - 1]);
            element = parent;
        }
        else
        {
            return;
        }
    }
}

void downHeap(T)(T[] heap) @nogc nothrow pure
{
    swap(heap[0], heap[$ - 1]);
    auto newHeap = heap[0 .. $ - 1];

    size_t element = 1;
    while (element * 2 - 1 < newHeap.length)
    {
        size_t bigChild = () {
            immutable child1 = element * 2;
            immutable child2 = child1 + 1;

            immutable child2Exists = child2 - 1 < newHeap.length;

            if (child2Exists && newHeap[child1 - 1] < newHeap[child2 - 1])
                return child2;
            else
                return child1;
        }();

        if (newHeap[element - 1] < newHeap[bigChild - 1])
        {
            swap(newHeap[element - 1], newHeap[bigChild - 1]);
            element = bigChild;
        }
        else
        {
            return;
        }
    }
}

void swap(T)(ref T a, ref T b) @nogc nothrow pure
{
    immutable tmp = a;
    a = b;
    b = tmp;
}
```
```
Test heap.v1.sort:
    N = 10^^1 avg: 0.000534433 msecs (sample: 51557)
    N = 10^^2 avg: 0.0112959 msecs (sample: 4492)
    N = 10^^3 avg: 0.166156 msecs (sample: 371)
    N = 10^^4 avg: 2.22345 msecs (sample: 31)
    N = 10^^5 avg: 28.2982 msecs (sample: 3)
    N = 10^^6 avg: 349.845 msecs (sample: 1)
```

#### v2

一部計算をビット操作に置き換えてみた。

##### [sort/v2.d at 016e05f004263f72b27c087d202e5e69f17971da · kotet/sort](https://github.com/kotet/sort/blob/016e05f004263f72b27c087d202e5e69f17971da/source/heap/v2.d)

```d
module heap.v2;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{

    foreach (i; 0 .. array.length)
    {
        upHeap(array[0 .. i + 1]);
    }
    foreach_reverse (i; 0 .. array.length)
    {
        downHeap(array[0 .. i + 1]);
    }
}

void upHeap(T)(T[] heap) @nogc nothrow pure
{
    size_t element = heap.length;
    while (element != 1)
    {
        size_t parent = element >> 1; // element / 2;
        if (heap[parent - 1] < heap[element - 1])
        {
            swap(heap[parent - 1], heap[element - 1]);
            element = parent;
        }
        else
        {
            return;
        }
    }
}

void downHeap(T)(T[] heap) @nogc nothrow pure
{
    swap(heap[0], heap[$ - 1]);
    auto newHeap = heap[0 .. $ - 1];

    size_t element = 1;
    while ((element << 1) - 1 < newHeap.length) // (element * 2 - 1 < newHeap.length)
    {
        size_t bigChild = () {
            immutable child1 = element << 1; // element * 2;
            immutable child2 = child1 + 1;

            immutable child2Exists = child2 - 1 < newHeap.length;

            if (child2Exists && newHeap[child1 - 1] < newHeap[child2 - 1])
                return child2;
            else
                return child1;
        }();

        if (newHeap[element - 1] < newHeap[bigChild - 1])
        {
            swap(newHeap[element - 1], newHeap[bigChild - 1]);
            element = bigChild;
        }
        else
        {
            return;
        }
    }
}

void swap(T)(ref T a, ref T b) @nogc nothrow pure
{
    immutable tmp = a;
    a = b;
    b = tmp;
}
```
全く変化がない。この程度のことは自動でやってくれるということか……
```
Test heap.v2.sort:
    N = 10^^1 avg: 0.000520677 msecs (sample: 53282)
    N = 10^^2 avg: 0.0110707 msecs (sample: 4587)
    N = 10^^3 avg: 0.167113 msecs (sample: 371)
    N = 10^^4 avg: 2.24725 msecs (sample: 31)
    N = 10^^5 avg: 28.6215 msecs (sample: 3)
    N = 10^^6 avg: 351.185 msecs (sample: 1)
```

[つづく](/2017/09/sort-algorithm-in-d-2)