---
date: 2017-09-16
aliases:
- /2017/09/16/sort-algorithm-in-d-2.html
title: "Dで巡るソートアルゴリズム その2"
tags:
- log
- dlang
- tech
excerpt: "前回の続き。 今週は挿入ソート、コムソート、マージソートを書いた。 ここ一週間あまり体調が良くなかったため、気力と思考力の面であまりソートが書けなかった。"
---

[前回](/2017/09/sort-algorithm-in-d)の続き。
今週は挿入ソート、コムソート、マージソートを書いた。
ここ一週間あまり体調が良くなかったため、気力と思考力の面であまりソートが書けなかった。

### テストの変更

要素数が1の時もテストするようにした。
また、配列が正しくソートされているかの検証に[`std.algorithm.sorting.isSorted`](https://dlang.org/library/std/algorithm/sorting/is_sorted.html)を使うようにした。

#### [sort/test.d at ed9ad93c433ee210171b6358fad302f6116b9df1 · kotet/sort](https://github.com/kotet/sort/blob/ed9ad93c433ee210171b6358fad302f6116b9df1/source/test/test.d)

```d
/// 前略
        do
        {
            import std.datetime : StopWatch;
            import core.time : TickDuration;

            sample = 0;
            double result = 0;
            StopWatch s;
            s.start();
            do
            {
                sample++;
                result += () {
                    import std.algorithm.sorting : isSorted;
                    import std.random : randomShuffle;
                    import std.range : array, iota;
                    import std.datetime : StopWatch, to;
                    import std.conv : to;

                    auto random = iota(10 ^^ n).array();
                    random.randomShuffle();

                    StopWatch s;
                    s.start();

                    F(random);

                    s.stop();

                    assert(random.isSorted);
                    return s.peek().to!("msecs", double);
                }();
            }
            while (s.peek() < TickDuration.from!"msecs"(100));

            writefln!"    N = 10^^%s avg: %s msecs (sample: %s)"(n, result / sample, sample);
            
            n++;
        }
        while (1 < sample);
    }
}
```

### [挿入ソート](https://ja.wikipedia.org/wiki/%E6%8C%BF%E5%85%A5%E3%82%BD%E3%83%BC%E3%83%88)

nogcかつIn-place。
二分探索で挿入箇所を探し、ずらして挿入する。

#### [sort/v1.d at c10ef9bc1da82abec0093beff94dfa64ff9bc25a · kotet/sort](https://github.com/kotet/sort/blob/c10ef9bc1da82abec0093beff94dfa64ff9bc25a/source/insertion/v1.d)

```d
module insertion.v1;

import test;

mixin test!sort;

void sort(T)(T[] array) @nogc nothrow pure
{
    if (array.length < 2)
        return;

    auto sorted = array[0 .. 1];

    foreach (i, n; array[0 .. $])
    {
        if (i == 0)
            continue;

        auto insertion = bisection(sorted, n);
        shift(array[insertion .. i + 1]);
        array[insertion] = n;

        sorted = array[0 .. i + 1];
    }
}

size_t bisection(T)(T[] sorted, T n) @nogc nothrow pure
{
    if (sorted.length == 1)
        return (sorted[0] < n) ? 1 : 0;

    if (sorted[$ - 1] < n)
        return sorted.length;

    size_t min = -1;
    size_t max = sorted.length;

    while (max - min != 1)
    {
        size_t mid = (max + min) / 2;

        if (sorted[mid] < n)
            min = mid;
        else
            max = mid;
    }

    return min + 1;
}

void shift(T)(T[] array) @nogc nothrow pure
{
    foreach_reverse (i; 1 .. array.length)
    {
        array[i] = array[i - 1];
    }
}
```
要素数が少ない時のオーバーヘッドは比較的小さいがそんなに速くはない。
```
Test insertion.v1.sort:
    N = 10^^0 avg: 2.52021e-05 msecs (sample: 361305)
    N = 10^^1 avg: 0.000356714 msecs (sample: 73572)
    N = 10^^2 avg: 0.0109691 msecs (sample: 5237)
    N = 10^^3 avg: 0.604773 msecs (sample: 147)
    N = 10^^4 avg: 53.3391 msecs (sample: 2)
    N = 10^^5 avg: 5295.32 msecs (sample: 1)
```

### [マージソート](https://ja.wikipedia.org/wiki/%E3%83%9E%E3%83%BC%E3%82%B8%E3%82%BD%E3%83%BC%E3%83%88)

#### v4

並列バージョン。
v3では要素数が一定以下になるまでタスクを分割していたが、今回は`std.parallelism.totalCPUs`をもとに分割するようにした。
`totalCPUs`以上のタスクは生成されない。

##### [sort/v4.d at 7ce8383662e16377d796d19b2d3105f72bd48f5c · kotet/sort](https://github.com/kotet/sort/blob/7ce8383662e16377d796d19b2d3105f72bd48f5c/source/merge/v4.d)

```d
module merge.v4;

import test;

mixin test!sort;

void sort(T)(T[] array)
{
    import std.parallelism : totalCPUs;

    parallelSort(array, totalCPUs);
}

void parallelSort(T)(T[] array, uint available)
{
    if (available == 1 || array.length < 2)
    {
        serialSort(array);
    }
    else
    {
        import std.parallelism : task;

        auto t = task!parallelSort(array[$ / 2 .. $], available / 2);
        t.executeInNewThread();

        parallelSort(array[0 .. $ / 2], available / 2);

        t.yieldForce();

        merge(array);
    }
}

void serialSort(T)(T[] array)
{
    if (array.length < 2)
        return;
    serialSort(array[0 .. $ / 2]);
    serialSort(array[$ / 2 .. $]);
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
速くなるどころかむしろ実行時間は増えている。
どうやら問題は別のところにあるらしい。
```
Test merge.v4.sort:
    N = 10^^0 avg: 2.87828e-05 msecs (sample: 372201)
    N = 10^^1 avg: 0.119522 msecs (sample: 824)
    N = 10^^2 avg: 0.15737 msecs (sample: 600)
    N = 10^^3 avg: 1.94974 msecs (sample: 49)
    N = 10^^4 avg: 4.96305 msecs (sample: 17)
    N = 10^^5 avg: 32.614 msecs (sample: 3)
    N = 10^^6 avg: 277.655 msecs (sample: 1)
```

#### v5
v3の`serialSort`が内部で`serialSort`ではなく`sort`を呼んでいるというバグを修正した。
結果的にシリアルソートになってはいたが、無駄な再帰と配列の長さチェックが発生していた。

##### [sort/v5.d at 42a8c920931f54231d1fa79a0816346bf372ce0d · kotet/sort](https://github.com/kotet/sort/blob/42a8c920931f54231d1fa79a0816346bf372ce0d/source/merge/v5.d)

```d
/// 前略
void serialSort(T)(T[] array)
{
    if (array.length < 2)
        return;
    serialSort(array[0 .. $ / 2]);
    serialSort(array[$ / 2 .. $]);
    merge(array);
}
/// 後略
```
ちょっと速くなった。
```
Test merge.v5.sort:
    N = 10^^0 avg: 2.80161e-05 msecs (sample: 373704)
    N = 10^^1 avg: 0.00148437 msecs (sample: 40508)
    N = 10^^2 avg: 0.0189592 msecs (sample: 3594)
    N = 10^^3 avg: 0.247173 msecs (sample: 310)
    N = 10^^4 avg: 3.2127 msecs (sample: 25)
    N = 10^^5 avg: 28.4651 msecs (sample: 3)
    N = 10^^6 avg: 236.172 msecs (sample: 1)
```

### [コムソート](https://ja.wikipedia.org/wiki/%E3%82%B3%E3%83%A0%E3%82%BD%E3%83%BC%E3%83%88)

#### v2

改良版アルゴリズム"Comb sort 11"。

##### [sort/v2.d at f3ae0a59444d99ef91f48e54d775cfadd54c382a · kotet/sort](https://github.com/kotet/sort/blob/f3ae0a59444d99ef91f48e54d775cfadd54c382a/source/comb/v2.d)

```d
module comb.v2;

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
            if (gap == 9 || gap == 10)
                gap = 11;
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
あまり変化が無いようだ。
入力の性質によっては速くなったりするんだろうか?
```
Test comb.v2.sort:
    N = 10^^0 avg: 2.67903e-05 msecs (sample: 365209)
    N = 10^^1 avg: 0.000319247 msecs (sample: 75567)
    N = 10^^2 avg: 0.00595804 msecs (sample: 6994)
    N = 10^^3 avg: 0.0932101 msecs (sample: 581)
    N = 10^^4 avg: 1.29673 msecs (sample: 49)
    N = 10^^5 avg: 17.0905 msecs (sample: 4)
    N = 10^^6 avg: 215.109 msecs (sample: 1)
```

### テスト結果全文

前回から再計測したので新しい物以外もすべて載せる。

```
Test bubble.v1.sort:
    N = 10^^0 avg: 5.29931e-05 msecs (sample: 187446)
    N = 10^^1 avg: 0.000469878 msecs (sample: 54081)
    N = 10^^2 avg: 0.0246636 msecs (sample: 3006)
    N = 10^^3 avg: 1.93576 msecs (sample: 50)
    N = 10^^4 avg: 253.616 msecs (sample: 1)
Test comb.v1.sort:
    N = 10^^0 avg: 2.83461e-05 msecs (sample: 345246)
    N = 10^^1 avg: 0.00033584 msecs (sample: 72120)
    N = 10^^2 avg: 0.00584063 msecs (sample: 7137)
    N = 10^^3 avg: 0.0960004 msecs (sample: 571)
    N = 10^^4 avg: 1.40355 msecs (sample: 46)
    N = 10^^5 avg: 17.2058 msecs (sample: 4)
    N = 10^^6 avg: 213.241 msecs (sample: 1)
Test comb.v2.sort:
    N = 10^^0 avg: 2.67903e-05 msecs (sample: 365209)
    N = 10^^1 avg: 0.000319247 msecs (sample: 75567)
    N = 10^^2 avg: 0.00595804 msecs (sample: 6994)
    N = 10^^3 avg: 0.0932101 msecs (sample: 581)
    N = 10^^4 avg: 1.29673 msecs (sample: 49)
    N = 10^^5 avg: 17.0905 msecs (sample: 4)
    N = 10^^6 avg: 215.109 msecs (sample: 1)
Test heap.v1.sort:
    N = 10^^0 avg: 3.79266e-05 msecs (sample: 353480)
    N = 10^^1 avg: 0.000509833 msecs (sample: 66684)
    N = 10^^2 avg: 0.0111968 msecs (sample: 5159)
    N = 10^^3 avg: 0.169005 msecs (sample: 403)
    N = 10^^4 avg: 2.23825 msecs (sample: 34)
    N = 10^^5 avg: 28.8483 msecs (sample: 3)
    N = 10^^6 avg: 353.321 msecs (sample: 1)
Test heap.v2.sort:
    N = 10^^0 avg: 3.79672e-05 msecs (sample: 351500)
    N = 10^^1 avg: 0.000521347 msecs (sample: 65592)
    N = 10^^2 avg: 0.0110731 msecs (sample: 5186)
    N = 10^^3 avg: 0.166295 msecs (sample: 407)
    N = 10^^4 avg: 3.76569 msecs (sample: 20)
    N = 10^^5 avg: 34.9103 msecs (sample: 3)
    N = 10^^6 avg: 350.389 msecs (sample: 1)
Test insertion.v1.sort:
    N = 10^^0 avg: 2.52021e-05 msecs (sample: 361305)
    N = 10^^1 avg: 0.000356714 msecs (sample: 73572)
    N = 10^^2 avg: 0.0109691 msecs (sample: 5237)
    N = 10^^3 avg: 0.604773 msecs (sample: 147)
    N = 10^^4 avg: 53.3391 msecs (sample: 2)
    N = 10^^5 avg: 5295.32 msecs (sample: 1)
Test merge.v1.sort:
    N = 10^^0 avg: 0.000139909 msecs (sample: 263457)
    N = 10^^1 avg: 0.00515314 msecs (sample: 16317)
    N = 10^^2 avg: 0.0690787 msecs (sample: 1235)
    N = 10^^3 avg: 0.918572 msecs (sample: 101)
    N = 10^^4 avg: 10.6631 msecs (sample: 9)
    N = 10^^5 avg: 119.999 msecs (sample: 1)
Test merge.v2.sort:
    N = 10^^0 avg: 2.52686e-05 msecs (sample: 367750)
    N = 10^^1 avg: 0.00140687 msecs (sample: 41870)
    N = 10^^2 avg: 0.0198551 msecs (sample: 3611)
    N = 10^^3 avg: 0.246737 msecs (sample: 310)
    N = 10^^4 avg: 2.98116 msecs (sample: 27)
    N = 10^^5 avg: 34.7099 msecs (sample: 3)
    N = 10^^6 avg: 410.145 msecs (sample: 1)
Test merge.v3.sort:
    N = 10^^0 avg: 2.93532e-05 msecs (sample: 347662)
    N = 10^^1 avg: 0.00159352 msecs (sample: 37780)
    N = 10^^2 avg: 0.022345 msecs (sample: 3286)
    N = 10^^3 avg: 0.270993 msecs (sample: 287)
    N = 10^^4 avg: 2.99265 msecs (sample: 27)
    N = 10^^5 avg: 26.6875 msecs (sample: 3)
    N = 10^^6 avg: 244.773 msecs (sample: 1)
Test merge.v4.sort:
    N = 10^^0 avg: 2.87828e-05 msecs (sample: 372201)
    N = 10^^1 avg: 0.119522 msecs (sample: 824)
    N = 10^^2 avg: 0.15737 msecs (sample: 600)
    N = 10^^3 avg: 1.94974 msecs (sample: 49)
    N = 10^^4 avg: 4.96305 msecs (sample: 17)
    N = 10^^5 avg: 32.614 msecs (sample: 3)
    N = 10^^6 avg: 277.655 msecs (sample: 1)
Test merge.v5.sort:
    N = 10^^0 avg: 2.80161e-05 msecs (sample: 373704)
    N = 10^^1 avg: 0.00148437 msecs (sample: 40508)
    N = 10^^2 avg: 0.0189592 msecs (sample: 3594)
    N = 10^^3 avg: 0.247173 msecs (sample: 310)
    N = 10^^4 avg: 3.2127 msecs (sample: 25)
    N = 10^^5 avg: 28.4651 msecs (sample: 3)
    N = 10^^6 avg: 236.172 msecs (sample: 1)
Test selection.v1.sort:
    N = 10^^0 avg: 3.51754e-05 msecs (sample: 361900)
    N = 10^^1 avg: 0.000402748 msecs (sample: 69040)
    N = 10^^2 avg: 0.0151206 msecs (sample: 4323)
    N = 10^^3 avg: 1.08129 msecs (sample: 87)
    N = 10^^4 avg: 104.767 msecs (sample: 1)
Test stooge.v1.sort:
    N = 10^^0 avg: 2.59603e-05 msecs (sample: 372583)
    N = 10^^1 avg: 0.0047156 msecs (sample: 17523)
    N = 10^^2 avg: 3.36548 msecs (sample: 30)
    N = 10^^3 avg: 790.58 msecs (sample: 1)
Test std.algorithm.sorting.sort:
    N = 10^^0 avg: 4.18741e-05 msecs (sample: 332640)
    N = 10^^1 avg: 0.000464241 msecs (sample: 67533)
    N = 10^^2 avg: 0.0161509 msecs (sample: 3978)
    N = 10^^3 avg: 0.177627 msecs (sample: 390)
    N = 10^^4 avg: 2.08512 msecs (sample: 35)
    N = 10^^5 avg: 24.1715 msecs (sample: 4)
    N = 10^^6 avg: 272.243 msecs (sample: 1)
```