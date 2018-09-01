---
date: 2017-05-08
aliases:
- /2017/05/08/vcg-ast.html
title: "処理後の結果を見られるdmdのスイッチ -vcg-ast"
tags:
- dlang
- tech
---

[Dconf 2017で出てきた](http://dconf.org/2017/talks/koch.html)コマンドラインスイッチ`-vcg-ast`について書き残しておく。
これはgccでいう`-E`オプションのようなもので、これはいろいろな"semantic steps" [^1]
がすべて終了したあとのASTを読めるかたちに書きだすオプションである。

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/crHnumzsLUs?rel=0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

`-vcg-ast`が使われた動画。
使用箇所付近(25:00)から再生が始まる。

### 使ってみる

#### `app.d`

```d
void main()
{
	import std.stdio : writeln;

	static immutable table = () {
		import std.range : iota, array;
		import std.algorithm : map;
		import std.math : sqrt;

		return 10.iota.map!((real n) => n.sqrt()).array;
	}();
	alias T = table;
	mixin("writeln(T);");
}
```

ここで`$ dmd app.d -vcg-ast`すると、`app.d.cg`というファイルが生成される。
中を見たら7912行もあった。

#### `app.d.cg`

```d
import object;
void main()
{
	import std.stdio : writeln;
	static immutable immutable(real[]) table = [0.00000L, 1.00000L, 1.41421L, 1.73205L, 2.00000L, 2.23607L, 2.44949L, 2.64575L, 2.82843L, 3.00000L];
	alias T = static immutable immutable(real[]) table = [0.00000L, 1.00000L, 1.41421L, 1.73205L, 2.00000L, 2.23607L, 2.44949L, 2.64575L, 2.82843L, 3.00000L];
	;
	writeln(table);
	return 0;
}
CommonType!(int, int)
alias CommonType = int;
CommonType!int
alias CommonType = int;
isFloatingPoint!int
enum bool isFloatingPoint = false;
Unqual!int
alias Unqual = int;
// 以下略
```

関数リテラルはCTFEの結果である配列になり、文字列mixinは普通のコードになり、さらにaliasも展開されている。
やたら行数が大きいのは自動的にimportされた`object`のせいだろう。
コードがコンパイラによってどのように展開されるかを知ることができてためになるし、なんだか見てて楽しい。

### dubで使う

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">とりあえずdub使ってる人は、dub.jsonの場合、<br>&quot;configuration&quot;: [<br> { &quot;name&quot;: &quot;ast&quot;, &quot;dflag&quot;: [&quot;-vcg-ast&quot;] }<br>]<br>と書き足すなどしてビルドすると一発の模様です。</p>&mdash; lempiji@思秋期 (@lempiji) <a href="https://twitter.com/lempiji/status/860459096897576960">2017年5月5日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

#### `dub.json`

```json
{
	"name": "test",
	"authors": [
		"kotet"
	],
	"description": "A minimal D application.",
	"copyright": "Copyright © 2017, kotet",
	"license": "proprietary",
	"dependencies": {
		"progress": "*"
	},
	"targetType": "executable",
	"configurations": [
		{
			"name": "default"
		},
		{
			"name": "ast",
			"dflags": [
				"-vcg-ast"
			]
		}
	]
}
```

#### `source/app.d`

```d
void main()
{
	import std.stdio : writeln;
	import std.range : iota;
	import progress.bar : Bar;

	auto b = new Bar();
	foreach (n; b.iter(10.iota))
	{
	}
	mixin("writeln(b);");
}
```

`$ dub build -c ast`すると.d.cgファイルが出力される。

#### `source/app.d.cg`

```d
import object;
void main()
{
	import std.stdio : writeln;
	import std.range : iota;
	import progress.bar : Bar;
	Bar b = new Bar;
	{
		Generator!int __r3001 = b.iter(iota(10));
		for (; !__r3001.empty(); __r3001.popFront())
		{
			int n = __r3001.front();
		}
	}
	writeln(b);
	return 0;
}
// 以下略
```

`foreach`が`for`に展開されている。
たのしい。

### 関連リンク

- [-vcg-ast dmd command line switch - D Programming Language Discussion Forum](http://forum.dlang.org/thread/oendp1$ct4$1@digitalmars.com)
- [DConf 2017 - YouTube](https://www.youtube.com/playlist?list=PL3jwVPmk_PRxo23yyoc0Ip_cP3-rCm7eB)

[^1]: [vcg-ast by UplinkCoder · Pull Request #6556 · dlang/dmd](https://github.com/dlang/dmd/pull/6556)