---
title: "AliasSeqで引数をこねくりまわす"
date: 2018-12-17
tags:
- dlang
- tech
---

D言語には`AliasSeq`というものがある。
これを使うと引数をまるで変数のように取り扱うことができる。
あまり何度も使うものではないが、知っているとちょっと便利だった。
[D言語 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/dlang)
17日目のこの記事ではそんな`AliasSeq`について書く。

### AliasSeq

`AliasSeq`はこんな感じのシンプルなテンプレートである。

```d
template AliasSeq(TList...)
{
    alias AliasSeq = TList;
}
```

[phobos/meta.d at fc96b0a99d5869ef10f503490c1f41be36d276e5 · dlang/phobos](https://github.com/dlang/phobos/blob/fc96b0a99d5869ef10f503490c1f41be36d276e5/std/meta.d#L86)

ドキュメントにはこう書かれている。

> Creates a sequence of zero or more aliases. This is most commonly used as template parameters or arguments.
> In previous versions of Phobos, this was known as **TypeTuple**.

> ゼロ以上のエイリアスのシーケンスを作ります。これは主にテンプレートパラメータや引数に使われます。
> 以前のバージョンのPhobosでは、これは**TypeTuple**として知られていました。

まあつまり型タプルである（なんの説明にもなっていない）。
タプルの形でエイリアスをたくさん作ることができて、
スライスを取ったりインデックスでアクセスしたりできる。

```d
alias Numbers = AliasSeq!(1, 2, 3, 4);
static assert (Numbers[1] == 2);
alias SubNumbers = Numbers[1 .. $];
static assert (SubNumbers[0] == 2);
```

ただのエイリアスなので、変数を入れて`AliasSeq`経由で値を変更したりできる。

```d
import std.stdio;
import std.meta;

void main()
{
    long x;
    alias A = AliasSeq!("hello","world",x);
    A[2] = 42;
	writeln(x); // 42
}
```

[run.dlang.io/is/DTiExK](https://run.dlang.io/is/DTiExK)

### 引数

`AliasSeq`は関数に渡すことができる。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a*b;
}

void main()
{
    alias A = AliasSeq!(4,5);
	writeln(mul(A)); // 20
}
```

[run.dlang.io/is/ygydUV](https://run.dlang.io/is/ygydUV)

上のコードは以下と同義である。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a*b;
}

void main()
{
    alias A0 = 4;
    alias A1 = 5:
	writeln(mul(A)); // 20
}
```

こんなこともできる。
この場合`4`と`5`は実行時に与えられる値にもできる。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a*b;
}

void main()
{
    alias A = AliasSeq!(long,long);
    A param;
    param[0] = 4;
    param[1] = 5;
	writeln(mul(param)); // 20
}
```

[run.dlang.io/is/PkPWfw](https://run.dlang.io/is/PkPWfw)

もちろん可変長引数の関数も大丈夫。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a*b;
}

void main()
{
    alias A = AliasSeq!("hello",' ',"world");
	writeln(A); // hello world
}
```

[run.dlang.io/is/YIbt31](https://run.dlang.io/is/YIbt31)

普通の関数の引数列を1つのタプルとして扱うことができるようになるわけだ。

### aliasSeqOf

`aliasSeqOf`はinput rangeから`AliasSeq`を生成するテンプレートだ。
たとえばこんなことができる。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a*b;
}

void main()
{
    enum ary = [4,5];
    alias A = aliasSeqOf!ary;
	writeln(mul(A)); // 20
}
```

[run.dlang.io/is/KzuB1P](https://run.dlang.io/is/KzuB1P)

まあこの例だと全く嬉しくないが……。

### 使用例1：foreachの展開

ここから具体的な使い方を紹介する。

```d
import std.stdio;
import std.meta;

void main()
{
    alias A = AliasSeq!(1,2,3);
    foreach (x; A)
    {
        writeln(x);
    }

    long[] ary = [1,2,3];
    foreach(x; ary)
    {
        writeln(x);
    }
}
```

[run.dlang.io/is/rb0wp1](https://run.dlang.io/is/rb0wp1)

上に挙げたコード中の2つの`foreach`は同じものを出力する。
つまり、1、2、3と順番に`writeln`を実行する。
しかし内部的な動作は異なってくる。
`-vcg-ast`オプションを付けてコンパイルし、出力を見てみる。

```d
import object;
import std.stdio;
import std.meta;
void main()
{
	alias A = TList;
	/*unrolled*/ {
		{
			enum int x = 1;
			writeln(1);
		}
		{
			enum int x = 2;
			writeln(2);
		}
		{
			enum int x = 3;
			writeln(3);
		}
	}
	long[] ary = [1L, 2L, 3L];
	{
		long[] __r43 = ary[];
		ulong __key44 = 0LU;
		for (; __key44 < __r43.length; __key44 += 1LU)
		{
			long x = __r43[__key44];
			writeln(x);
		}
	}
	return 0;
}
// 後略
```

`AliasSeq`を渡したほうの`foreach`は3つの`writeln`になっている。
`AliasSeq`に関しては特別な言語組み込み機能があり、`foreach`をコンパイル時に展開してくれるのだ。
ずるい。

型などの普通`foreach`では扱えない要素まで使えるようになる。

```d
alias A = AliasSeq!(byte, int, long);
foreach (type; A)
{
    pragma(msg, type);
}
```

現在は`static foreach`が存在するため、基本はそちらを使ったほうが読みやすいし適切だろう。
`static foreach`で型などは扱えなかったはずなので、そういうときには`AliasSeq`が役に立つだろう。

```d
enum ary = [1, 2, 3];
static foreach (x; ary)
{
    writeln(x);
}
```

上のコードはこんな感じに展開される。

```d
enum int[] ary = [1, 2, 3];
writeln(1);
writeln(2);
writeln(3);
```

### 使用例2：stringをcharの引数列に

こっちは実際に使ったもの。
[自作Cコンパイラ](https://github.com/kotet/d9cc)に以下のようなコードがある。

```d
if (s[i].among!(aliasSeqOf!"+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

順を追って説明していく。
上のコードをできるだけベーシックなものに書き直すとこんな感じになる。

```d
if (s[i] == '+' || s[i] == '-' || s[i] == '*' || /* 中略 */ || s[i] == '&')
{
    /* ... */
}
```

比較を何度も書かなくてはいけないので非常に煩わしい。
そこで`among`という関数を使うと以下のようになる。
ここの詳細は[過去の記事](/2017/12/std-algorithm-comparison-among/)に書いてある。

```d
if (s[i].among!('+', '-', '*', /* 中略 */, '&'))
{
    /* ... */
}
```

冗長な比較や論理演算がなくなってかなり短く書けるようになった。
しかし今度は大量の文字をひとつづつクオートで囲むのがめんどくさくなってくる。
それにまだちょっと読みにくい。
こんな感じに書きたい。

```d
if (s[i].among!("+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

しかしこの1行のために配列を受け付ける`among`を自作するのも癪だ。
そんな時役に立つのが`AliasSeq`である。
`aliasSeqOf`で文字列、つまり`char`の配列を`AliasSeq`にすると、やりたかったことがだいたい実現できる。
そうしてできたのが最初のコードである。

```d
if (s[i].among!(aliasSeqOf!"+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

### 別に無くてもなんとかなる

`AliasSeq`テンプレートを頭の片隅に入れておくと、
知らない時は不可能だと思っていたことができるようになり、ちょっとコードの冗長性を下げたりできる。
しかし、まあ、別に知らなくてもなんとかなる。

実際自分はD言語の標準ライブラリの関数やテンプレートをほとんど知らないし、
おそらくものすごい数の車輪を再発明している。
それでも致命的に何かができないということは今のところないので、そういうことだ。
`among`くらい自分で書け。

でも、TODO：うまいことまとめる