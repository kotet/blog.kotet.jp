---
title: "AliasSeqで引数をこねくりまわす"
date: 2018-12-17
tags:
- dlang
- tech
---

これは [D言語 Advent Calendar 2018](https://qiita.com/advent-calendar/2018/dlang) 17日目の記事です。

D言語には`AliasSeq`という~~超絶キモい~~おもしろいものがあります。
これを使うと引数列をまるで1つのタプルのように取り扱うことができます。
あまり何度も使うものではないですが、知っているとちょっと便利だったので、
ここではそんな`AliasSeq`について書きます。

### AliasSeq

`AliasSeq`について、
[ドキュメント](https://dlang.org/library/std/meta/alias_seq.html)にはこう書かれています。

> Creates a sequence of zero or more aliases. This is most commonly used as template parameters or arguments.
> In previous versions of Phobos, this was known as **TypeTuple**.

> ゼロ以上のエイリアスのシーケンスを作ります。これは主にテンプレートパラメータや引数に使われます。
> 以前のバージョンのPhobosでは、これは**TypeTuple**として知られていました。

`AliasSeq`はこんな感じのシンプルなテンプレートです。
可変長テンプレート引数として現れるタプルを外の世界に引きずり出しています。

```d
template AliasSeq(TList...)
{
    alias AliasSeq = TList;
}
```

[phobos/meta.d at fc96b0a99d5869ef10f503490c1f41be36d276e5 · dlang/phobos](https://github.com/dlang/phobos/blob/fc96b0a99d5869ef10f503490c1f41be36d276e5/std/meta.d#L86)

これを使うことでタプルの形でエイリアスをたくさん作って、
スライスを取ったりインデックスでアクセスしたりできます。

```d
alias Numbers = AliasSeq!(1, 2, 3, 4);
static assert (Numbers[1] == 2);

alias SubNumbers = Numbers[1 .. $];
static assert (SubNumbers[0] == 2);
```

ただのエイリアスであって、変数を入れても普通の代入にはならないので注意。

```d
import std.stdio;
import std.meta;

void main()
{
    long x;
    alias A = AliasSeq!("hello", "world", x);
    A[2] = 42;
	writeln(x); // 42
}
```

[run.dlang.io/is/KtUUcG](https://run.dlang.io/is/KtUUcG)

### 引数として渡す

`AliasSeq`は関数に渡すことができます。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a * b;
}

void main()
{
    alias A = AliasSeq!(4, 5);
	writeln(mul(A)); // 20
}
```

[run.dlang.io/is/j8HXPC](https://run.dlang.io/is/j8HXPC)

[`-vcg-ast`オプション](/2017/05/vcg-ast/)
を付けてコンパイルして出力を見てみると、
上のコードは以下のように展開されています。

```d
import object;
import std.stdio;
import std.meta;
long mul(long a, long b)
{
        return a * b;
}
void main()
{
        alias A = TList;
        writeln(mul(4L, 5L));
        return 0;
}
// 後略
```

数値のかわりに型を入れると、型タプルが作れます。
この場合`4`と`5`は実行時に与えられる値でも大丈夫。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a * b;
}

void main()
{
    alias A = AliasSeq!(long, long);
    A param;
    param[0] = 4;
    param[1] = 5;
	writeln(mul(param)); // 20
}
```

[run.dlang.io/is/pwhmeQ](https://run.dlang.io/is/pwhmeQ)

実行時には普通の変数のようになります。

```d
import object;
import std.stdio;
import std.meta;
long mul(long a, long b)
{
        return a * b;
}
void main()
{
        alias A = (long, long);
        (long, long) param;
        __param_field_0 = 4L;
        __param_field_1 = 5L;
        writeln(mul(__param_field_0, __param_field_1));
        return 0;
}
// 後略
```

もちろん可変長引数の関数でもOK。

```d
import std.stdio;
import std.meta;

void main()
{
    alias A = AliasSeq!("hello", ' ', "world");
	writeln(A); // hello world
}
```

[run.dlang.io/is/f43IWj](https://run.dlang.io/is/f43IWj)

普通の関数の引数列を完全にカプセル化して、
タプルとして汎用的に扱うことができるようになるわけです。

### 引数として宣言する

おもしろいことに、`AliasSeq`は引数の型として使うこともできます。

```d
import std.stdio;
import std.meta;

long mul(AliasSeq!(long, long) args)
{
    return args[0] * args[1];
}

void main()
{
    writeln(mul(4, 5)); // 20
}
```

[run.dlang.io/is/WyL3Wf](https://run.dlang.io/is/WyL3Wf)

これもコンパイル時に普通の引数列に展開されます。

```d
import object;
import std.stdio;
import std.meta;
long mul(long _param_0, long _param_1)
{
        return _param_0 * _param_1;
}
void main()
{
        writeln(mul(4L, 5L));
        return 0;
}
```

### aliasSeqOf

`aliasSeqOf`は
[InputRange](https://qiita.com/umarider/items/e0936c6afdcdf4522cc7#range%E3%81%AE%E4%BB%B2%E9%96%93%E3%81%9F%E3%81%A1)
から`AliasSeq`を生成するテンプレートです。
たとえばこんなことができます。

```d
import std.stdio;
import std.meta;

long mul(long a, long b)
{
	return a * b;
}

void main()
{
    enum ary = [4, 5];
    alias A = aliasSeqOf!ary;
	writeln(mul(A)); // 20
}
```

[run.dlang.io/is/OC9DGT](https://run.dlang.io/is/OC9DGT)

まあこの例だと全く嬉しくないですが……。

### 使用例1：なんでもコンパイル時にforeachしてくれるD言語くん

ここから具体的な使い方を紹介します。

```d
import std.stdio;
import std.meta;

void main()
{
    alias A = AliasSeq!(1, 2, 3);
    foreach (x; A)
    {
        writeln(x);
    }

    long[] ary = [1, 2, 3];
    foreach(x; ary)
    {
        writeln(x);
    }
}
```

[run.dlang.io/is/1cLv29](https://run.dlang.io/is/1cLv29)

上に挙げたコード中の2つの`foreach`は同じものを出力します。
つまり、1、2、3と順番に`writeln`が実行されます。
しかし内部的な動作は異なってきます。

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

`AliasSeq`を渡したほうの`foreach`は3つの`writeln`になっているのがわかります。
`AliasSeq`に関しては特別な言語組み込み機能があり、`foreach`をコンパイル時に展開してくれるのです。

あまり使いどころが思いつきませんが、型などの普通`foreach`では扱えない要素までイテレートできます。
闇の魔術に応用できそうな気もする。

```d
alias A = AliasSeq!(byte, int, long);
foreach (type; A)
{
    pragma(msg, type);
}
```

現在は`static foreach`が存在するため、基本はそちらを使ったほうが読みやすいし適切でしょう。
`static foreach`で型などは扱えなかったはずなので、そういうときには`AliasSeq`が役に立つはずです。

```d
enum ary = [1, 2, 3];
static foreach (x; ary)
{
    writeln(x);
}
```

上のコードはこんな感じに展開されます。

```d
enum int[] ary = [1, 2, 3];
writeln(1);
writeln(2);
writeln(3);
```

### 使用例2：stringをcharの引数列に

こっちは実際に使ったものです。
[自作Cコンパイラ](https://github.com/kotet/d9cc)には以下のようなコードがあります。

```d
if (s[i].among!(aliasSeqOf!"+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

順を追って説明していきましょう。
上のコードをできるだけベーシックなものに書き直すとこんな感じになります。

```d
if (s[i] == '+' || s[i] == '-' || s[i] == '*' || /* 中略 */ || s[i] == '&')
{
    /* ... */
}
```

比較を何度も書かなくてはいけないので非常に煩わしいですね。
そこで`among`という関数を使うと以下のようになります。
内部的には`switch`文を使った効率的な関数がコンパイル時に生成されます。
ここの詳細は[過去の記事](/2017/12/std-algorithm-comparison-among/)に書いてあるので、
気になる人は読んでください。

```d
if (s[i].among!('+', '-', '*', /* 中略 */, '&'))
{
    /* ... */
}
```

冗長な比較や論理演算がなくなってかなり短く書けるようになりました。
しかし今度は大量の文字をひとつづつクオートで囲むのがめんどくさくなってきます。
それにまだちょっと読みにくい。
こんな感じに書きたくなります。

```d
if (s[i].among!("+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

そんな時`AliasSeq`が役に立ちます。
`aliasSeqOf`で文字列、つまり`char`の配列を`AliasSeq`にすると、やりたかったことがだいたい実現できます。
そうしてできたのが最初のコードです。

```d
if (s[i].among!(aliasSeqOf!"+-*/;=(),{}<>[]&"))
{
    /* ... */
}
```

### この間すべてコンパイル時の出来事である

`AliasSeq`テンプレートを頭の片隅に入れておくと、ちょっとコードの冗長性を下げたりできます。
しかもここまでの出来事はすべてコンパイル時に処理されており、実行時に余計なコストはかかりません。

D言語の標準ライブラリにはわりとなんでもあるので、
なにかやりたくなったときにはまずドキュメントを探してみるといいでしょう。