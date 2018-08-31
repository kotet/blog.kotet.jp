---
date: 2017-03-29
title: "In式のオーバーロード2種"
tags:
- dlang
- tech
---

普通にドキュメントを読めば書いてあることなんだけどなぜか調べるのに手間取ったので、専用の記事を書く。
やりたいこと1つに対応して1つの記事があるというのも人によっては役に立つと思っている。
タイトルで調べたいことの答えが書いてあるとわかるというのは利点だと思う。

以下のコードの実行例 : 
[DPaste - Paste #23990 - pastebin, online compiler and collaboration tool dedicated to D Programming Language](https://dpaste.dzfl.pl/c155ba11e043)

### 方法1 - opBinary

```d
class test1
{
	bool opBinary(string op)(int key)
	{
		static if (op == "in") return true;
	}
	
	bool opBinaryRight(string op)(int key)
	{
		static if (op == "in") return false;
	}
}
```

[ドキュメント](http://dlang.org/spec/operatoroverloading.html#binary)
に書いてある方法。`opBinary`で`test1 in key`、`opBinaryRight`で`key in test1`をオーバーロードできる。
この方法は二項演算子全般をオーバーロードでき、与えられた演算子に応じて処理を変えたり文字列Mixinできたりする。

### 方法2 - opIn (非推奨)

```d
class test2
{
	bool opIn(int key)
	{
		return true;
	}
	
	bool opIn_r(int key)
	{
		return false;
	}
}
```

In式のオーバーロードがしたいだけならこちらのほうがわかりやすいと思う。ドキュメントにないなと思って調べたら
[どうやらD1の書き方らしい](http://digitalmars.com/d/1.0/operatoroverloading.html#Binary)。
将来サポートされる保証はないとのことなので、執筆時点で動くけれど使わないほうが良いのだろう。