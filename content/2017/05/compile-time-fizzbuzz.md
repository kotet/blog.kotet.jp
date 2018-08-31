---
date: 2017-05-13
title: "コンパイル時fizzbuzzと謎のaliasSeqOf"
tags:
- dlang
- tech
---

[D言語のfizzbuzz - kubo39's blog](http://kubo39.hatenablog.com/entry/2017/05/13/D%E8%A8%80%E8%AA%9E%E3%81%AEfizzbuzz)
を読んで、コンパイル時fizzbuzzはforeachを使えば短く書けるのでは?と思い実際に書いてみることにした。

### 自分の力で書いてみる

```d
int test(alias n)()
{
    foreach (i; 0 .. n)
    {
        static if (i % 3)
            pragma(msg, i);
    }
    return 0;
}

enum foo = test!15;
```

まず上のようにforeach内でstaticなあれこれはできない。

```console
$ dmd -c fizzbuzz.d
fizzbuzz.d(5): Error: variable i cannot be read at compile time
fizzbuzz.d(11): Error: CTFE failed because of previous errors in test
```

以下のように計算の過程でforeachを使うのは大丈夫。

```d
auto test(alias n)()
{
    int[] result;
    foreach (i; 0 .. n)
    {
        if (i % 3)
            result ~= i;
    }
    return result;
}

enum foo = test!15;
pragma(msg, foo);
```

```console
$ dmd -c fizzbuzz.d
[1, 2, 4, 5, 7, 8, 10, 11, 13, 14]
```

つまりこうすれば繰り返しを手で書かずに済む。
ただし出力は1つずつ行わなければいけない、みたいなレギュレーションがあったらダメ。

```d
string fizzbuzz(alias n)()
{
    import std.algorithm : map;
    import std.conv : to;
    import std.range : array, iota, join;

    return iota(1, n + 1)
    .map!(a => (!(a % 15)) ? "fizzbuzz" : (!(a % 5)) ? "buzz" : (!(a % 3)) ? "fizz" : a.to!string)
    .join("\n")
    .array
    .to!string;
}

pragma(msg, fizzbuzz!15);

```

```console
$ dmd -c fizzbuzz.d
1
2
fizz
4
buzz
fizz
7
8
fizz
buzz
11
fizz
13
14
fizzbuzz
```

### `aliasSeqOf`を使ったバージョン

[lsを間違えて（中略）コンパイル時にD言語くんが通り過ぎるコマンド - Qiita](http://qiita.com/dragoon2014/items/2217ab9578c875ecdf69)

```d
int fizzbuzz(alias n)()
{
    import std.meta : aliasSeqOf;
    import std.algorithm : map;
    import std.conv : to;
    import std.range : array, iota, join;

    foreach (i; aliasSeqOf!(iota(1, n + 1)))
    {
        static if (!(i % 15))
            pragma(msg, "fizzbuzz");
        else static if (!(i % 3))
            pragma(msg, "fizz");
        else static if (!(i % 5))
            pragma(msg, "buzz");
        else
            pragma(msg, i);
    }
    return 0;
}

enum foo = fizzbuzz!15;
```

```console
$ dmd -c fizzbuzz.d
1
2
fizz
4
buzz
fizz
7
8
fizz
buzz
11
fizz
13
14
fizzbuzz
```

以下のコードを`$ dmd -c fizzbuzz.d -vcg-ast`すると

```d
void main()
{
    import std.meta : aliasSeqOf;
    import std.range : iota;
    import std.random : uniform;
    import std.stdio : writeln;

    int n = uniform(1, 6);
    foreach (i; aliasSeqOf!(iota(1, 6)))
        if (n == i)
            writeln(i ^^ 2);
}
```

ifに展開されていた。
`aliasSeqOf`はレンジを"alias sequence"に変換するもの……だそうだがちょっと何が起きているのか理解できていない。
`aliasSeqOf!(iota(1, 6))`はいったいforeachに何を渡したことになるんだろう?
`aliasSeqOf`を使わずに手書きで同じ現象を起こすにはどうしたら良いんだろう?
今後の課題にしようと思う。

```d
import object;
void main()
{
	import std.meta : aliasSeqOf;
	import std.range : iota;
	import std.random : uniform;
	import std.stdio : writeln;
	int n = uniform(1, 6);
	unrolled {
		{
			enum int i = 1;
			if (n == 1)
				writeln(1);
		}
		{
			enum int i = 2;
			if (n == 2)
				writeln(4);
		}
		{
			enum int i = 3;
			if (n == 3)
				writeln(9);
		}
		{
			enum int i = 4;
			if (n == 4)
				writeln(16);
		}
		{
			enum int i = 5;
			if (n == 5)
				writeln(25);
		}
	}
	return 0;
}
// 以下略
```