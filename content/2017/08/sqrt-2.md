---
date: 2017-08-14
aliases:
- /2017/08/14/sqrt-2.html
title: "2の平方根をDだけで1万桁求める"
tags:
- dlang
- tech
excerpt: "かなり前に円周率をたくさん求めたくなって、 せっかくだからD言語だけで書いてみようと思い、 こちらの記事を参考にbigfixedというライブラリを作った。 これはstd.bigintを使って固定小数点計算をするものである。 しかし作っているうちに飽きてしまい……"
---

かなり前に円周率をたくさん求めたくなって、
せっかくだからD言語だけで書いてみようと思い、
[こちら](http://tanakh.jp/posts/pi.html)の記事を参考に[bigfixed](https://github.com/kotet/bigfixed)というライブラリを作った。
これは`std.bigint`を使って固定小数点計算をするものである。
しかし作っているうちに飽きてしまい完成する頃には円周率はどうでも良くなってきた。
とりあえず計算の簡単な平方根を求めてみることにした。

以下がそのコードである。
Single-file packageになっているので`dub run --single --build=release sqrt.d`などとしてやるとこのファイル単体で動く。

#### `sqrt.d`

```d
#!/usr/bin/env dub
/+ dub.sdl:
	name "sqrt"
    dependency "bigfixed" version="*"
+/
void main()
{
    import std.stdio;

    sqrt(2,10_000).writeln();
}

string sqrt(int n, size_t prec)
{
    import bigfixed : BigFixed;
    import std.conv : to;
    import std.math : ceil, log10;

    immutable size_t q = (prec / log10(2.0)).ceil.to!size_t() + 1;
    auto low = BigFixed(0, q);
    auto high = BigFixed(n, q);

    while ((high - low) != high.resolution)
    {
        immutable BigFixed mid = (high + low) >> 1;
        immutable bool isLess = (mid * mid) < n;
        if (isLess)
        {
            low = mid;
        }
        else
        {
            high = mid;
        }
    }
    return low.toDecimalString(prec);
}
```

固定小数点数なので、整数と同じノリで二分法が使える。

#### 出力

```
/// 前略
9255474240448991887071069675242507745201229360810574142653234724064162141033353340551104521261750359028403745459186450472762434207177092979354010214096464502836834180407586081001407216192477179809859681115404464437285689592868319777977869346415984697451339177415379048778808300220583350467465553230285873258351
```

[こちら](http://www.h2.dion.ne.jp/~dra/suu/chi2/heihoukon/2.html)のサイトと値が一致した。
なお、実ははじめ100万桁を計算しようとしたのだが、8時間たっても終了しなかったので断念している。
速度に問題がある……