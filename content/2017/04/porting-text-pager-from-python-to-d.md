---
date: 2017-04-23
aliases:
- /2017/04/23/porting-text-pager-from-python-to-d.html
title: "テキストページャをPythonからDに移植する【翻訳】"
tags:
- dlang
- tech
- translation
excerpt: "数週間前、私はこのような記事を書きました: tp, a simple text pager in Python 数日前、私はこのページャをPythonからD 言語として知られるDに移植しようと思いたち、そして実行しました。"
---

この記事は、

[jugad2 - Vasudev Ram on software innovation: Porting the text pager from Python to D (DLang)](https://jugad2.blogspot.jp/2017/04/porting-text-pager-from-python-to-d.html)

を自分用に翻訳したものを
[許可を得て](https://jugad2.blogspot.com/2017/04/porting-text-pager-from-python-to-d.html?showComment=1492862188174#c3380262533412109352)
公開するものである。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

<big>
 $ tp file.txt  
 $ dir /s | tp
</big>

数週間前、私はこのような記事を書きました:

[tp, a simple text pager in Python](https://jugad2.blogspot.in/2017/02/tp-simple-text-pager-in-python.html)

数日前、私はこのページャをPythonから[D](https://dlang.org/)
[言語](https://en.wikipedia.org/wiki/D_(programming_language))として知られるDに移植しようと思いたち、そして実行しました。

DについてのWikipediaの記事にはこうあります:

 > C++のリエンジニアリングとして始まったものですが、Dは他の言語、特にJava、Python、Ruby、C#、やEiffelからもインスピレーションを得て、
 > Cのコア機能をリデザインした独自の言語です。

こちらがtp.dのコードです

```d
/*
File: tp.d
Purpose: A simple text pager.
Version: 0.1
Platform: Windows-only.
May be adaptable for Unix using tty / termios calls.
Only the use of getch() may need to be changed.
Author: Vasudev Ram
Copyright 2017 Vasudev Ram
Web site: https://vasudevram.github.io
Blog: https://jugad2.blogspot.com
Product store: https://gumroad.com/vasudevram
Twitter: https://mobile.twitter.com/vasudevram
*/

import std.stdio;
import std.string;
import std.file;

extern (C) int getch();

void usage(string[] args) {
    stderr.writeln("Usage: ", args[0], " text_file");
    stderr.writeln("or");
    stderr.writeln("command_generating_text | ", args[0]);
}

void pager(File in_fil, int lines_per_page=12, char quit_key='q')
{
    assert (lines_per_page > 1);
    int line_count = 0;
    int c;
    foreach (line; in_fil.byLine()) {
        writeln(line);
        line_count++;
        if ( (line_count % lines_per_page) == 0) {
            stdout.flush();
            c = getch();
            if (c == 'q')
                break;
            else
                line_count = 0;
        }
    }
}

int main(string[] args) {

    int lines_per_page = 20;
    File in_fil;

    try {
        if (args.length > 2) {
            usage(args);
            return 1;
        }
        else {
            if (args.length == 2) {
                in_fil = File(args[1]);
            }
            else {
                in_fil = stdin;
            }
            pager(in_fil, lines_per_page, 'q');
        }
    } catch (FileException fe) {
        stderr.writeln("Caught FileException: msg = ", fe.msg);
    } catch (Exception e) {
        stderr.writeln("Caught Exception: msg = ", e.msg);
    }
    finally {
        in_fil.close();
    }
    return 0;
}
```

これをこのような一般的な方法でコンパイルし:

```console
dmd tp.d
```

tp.exeを生成します。  
これはPythonバージョンと同じように、2つの方法(ファイル呼び出し、または標準入力)いずれかで実行することができます。
これら2つの方法を、

```console
tp tp.d
```

または

```d
type tp.d | tp
```

と**ドッグフーディング(試用)**することができます。

Pythonページャの場合(それ自身を実行するとき)のように、出力はそれ自身のソースプログラムと同じ為、ここには載せません。
これで、tpはless以下(*tp* is less than *less*)と言うことができます :) [^1] [^2]

[^1]: [less is more](https://en.wikipedia.org/wiki/Less_(Unix)#History)のように
[^2]: 2つの意味でLessです: 少ない機能と、短い名前。

このDページャを書いた後、私は簡単にPythonバージョンとの視覚的な比較をし、PythonとDバージョンと、
だいたい同じコードの全体の構造を見るのは興味深いものでした。
ファイルを開き(または標準入力を使い)、そこから各行を読み込み、ファイルを閉じ、キーボードから文字を得る。
すべてが振る舞いにおいてだいたい同じでした。
私の推察ではこれは少なくとも部分的にはPythonとDの両方共がCの遺産を共有しているためです。

実際、Dのコードでも:

```d
foreach (line; in_fil.byLine()) {
```

少し斜め読みすれば、Pythonのコードとして読むことができます

```python
for lin in fil.byLine()
```

必ずしも有効なPythonではないですが、byLineメソッドがfileオブジェクトにあるとすれば、読めないことはないです :)

興味のある方は、最近HNでDについての良いディスカッションがありました。こちらです:

[The reference D compiler is now open source (dlang.org)](https://news.ycombinator.com/item?id=14060846)

スレッドのタイトルにかかわらず、ライセンスの側面よりもD言語の機能についてのものです。

楽しんでください。

---

### 追記

これについてコメント:

> ```python
for lin in fil.byLine()
```
>
>必ずしも有効なPythonではないですが、byLineメソッドがfileオブジェクトにあるとすれば、読めないことはないです :)

もちろん、実際のPythonバージョンはもっとシンプルです:

```python
for lin in in_fil:
```

これは、Dのそれがそうするように、lazyに(つまりオンデマンドに)ファイルの行をイテレーションします
(Pythonのファイルオブジェクトがイテレータプロトコルで実装されているためです)。
言い換えると、メモリ上に一度にすべての行をロードしたりしません。
それぞれ要求があるたびに読み込みます。
だから速く、少ないメモリしか使いません。
Dバージョンにも同じことが言えます。
