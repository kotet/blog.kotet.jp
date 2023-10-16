---
date: 2017-04-22
aliases:
- /2017/04/22/mandelbrot-dlib.html
- /2017/04/21/mandelbrot-dlib.html
title: "dlibでマンデルブロ集合を描く"
tags:
- dlang
- tech
image: /assets/2017/04/22/mandel.png
excerpt: "前回に続いて、マンデルブロ集合の画像をD言語で描くことができた。 pngの取り扱いはdlibを使った。"
---

![描いたマンデルブロ集合](/assets/2017/04/22/mandel.png)

[前回に続いて、](/2017/04/12/mandelbrot-command-line-interface.html)マンデルブロ集合の画像をD言語で描くことができた。
pngの取り扱いはdlibを使った。

## dlib != Dlib

[gecko0307/dlib: Math, XML, I/O streams, image and audio processing for D](https://github.com/gecko0307/dlib)

C++のほうに同名のライブラリがあるのだが、それとは特に関係ないらしい。READMEに書かれている正式名っぽい名前の1文字目が小文字なので、それで見分けられるかもしれない。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="en" dir="ltr"><a href="https://twitter.com/kotetttt">@kotetttt</a> C++&#39;s dlib and D&#39;s dlib are two different libraries. They are not related to each other.</p>&mdash; 64 терабайта RAM (@incredibletoy) <a href="https://twitter.com/incredibletoy/status/838935735361286146">2017年3月7日</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

### 実際のコード

[kotet/mandelbrot-dlib: Draw Mandelbrot set using dlib](https://github.com/kotet/mandelbrot-dlib)

```d
import dlib.image : SuperImage;
import std.complex : Complex;

void main(string[] args)
{
	import std.getopt : defaultGetoptPrinter, getopt, GetOptException,
		GetoptResult;
	import dlib.image : savePNG;

	real center_x = -0.7;
	real center_y = 0.0;
	real height = 2.5;
	real width = 2.5;
	uint row = 2048;
	uint column = 2048;
	size_t judge_iter = 100;
	string output_file = "mandel.png";

	GetoptResult helpinfo;
	try
	{
		helpinfo = getopt(args, "center-x", &center_x, "center-y", &center_y,
				"height", &height, "width", &width, "row", &row, "column", &column,
				"judge-iter", &judge_iter, "output-file|o", &output_file);
	}
	catch (Exception e)
	{
		import std.stdio : writeln;

		writeln("Error: ", e.msg, "\nexit");
		return;
	}

	if (helpinfo.helpWanted)
		defaultGetoptPrinter("test", helpinfo.options);

	draw(center_x, center_y, height, width, row, column, judge_iter).savePNG(output_file);
}

SuperImage draw(real center_x, real center_y, real height, real width, uint row,
		uint column, size_t judge_iter)
{
	import dlib.image : image, hsv;
	import std.range : iota;

	auto img = image(row, column);
	foreach (x; 0 .. row)
		foreach (y; 0 .. column)
		{
			Complex!real c;
			c.re = center_x - (width / 2) + (width * (cast(real) x / row));
			c.im = center_y + (height / 2) - (height * (cast(real) y / column));
			auto result = judge(c, judge_iter);
			img[x, y] = (result == 0) ? hsv(0, 0, 0) : hsv(cast(float)(result * 10) % 256, 0.8, 1.0);
		}

	return img;
}

/**
	A function that determines whether a sequence diverges.
	Returns: 0 (if Sequence diverges) or Speed to diverge
*/
size_t judge(Complex!real c, size_t judge_iter)
{
	import std.complex : complex, abs;

	auto z = complex!real(0, 0);

	foreach (i; 0 .. judge_iter)
	{
		z = z * z + c;
		if (2.0 < z.abs)
			return i + 1;
	}
	return 0;
}
```

これを実行してできたのが上の画像である。

### 並列化

さすがにAAの時とは計算量が違い時間がかかるので、なにか高速化できないか試してみる。
とりあえず雑に`parallel`をつける。

```d
SuperImage draw(real center_x, real center_y, real height, real width, uint row,
		uint column, size_t judge_iter)
{
	import dlib.image : hsv, image;
	import std.parallelism : parallel;
	import std.range : iota;

	auto img = image(row, column);
	foreach (x; iota(row).parallel)
		foreach (y; 0 .. column)
		{
			Complex!real c;
			c.re = center_x - (width / 2) + (width * (cast(real) x / row));
			c.im = center_y + (height / 2) - (height * (cast(real) y / column));
			auto result = judge(c, judge_iter);
			img[x, y] = (result == 0) ? hsv(0, 0, 0) : hsv(cast(float)(result * 10) % 256, 0.8, 1.0);
		}

	return img;
}
```

3回時間を計ってみる。

|   | before  | after  |
|:-:|:-------:|:------:|
| 1 | 10.067s | 2.314s |
| 2 | 10.066s | 2.372s |
| 3 | 10.118s | 2.326s |

速くなってしまった……
絶対何かしらエラーが出ると思っていたのだが、普通に動いてしかも4、5倍高速化できてしまった。
どういうことなのかはよくわからないが、並列処理について知識を持たない自分が雑に書いても並列化の恩恵を得られるというのは素晴らしいことだと思う。
