---
date: 2018-04-12
aliases:
- /2018/04/12/dlang-environment.html
title: "KotetのD言語作業環境2018年春"
tags:
- dlang
- tech
- log
---

一部に需要があるみたいなので、この機会に自分とD言語をつなぐ作業環境について記録しておく。

### OS

[Arch Linux](https://www.archlinux.org/)である。
据え置きのPCもあるがノートPCのほうが性能がいい上にファンの音がほとんどしないので基本的にそちらを使っている。
一応WindowsとのデュアルブートになっているがWindowsはほとんど使わない。

```console
$ uname -a
Linux kotet-xps 4.14.32-1-lts #1 SMP Sun Apr 1 11:41:45 CEST 2018 x86_64 GNU/Linux
```

### コンパイラ

[Archのパッケージマネージャで落ちてくるもの](https://www.archlinux.org/packages/community/x86_64/dmd/)をそのまま使っている。
以前使っていたディストリビューションではインストールスクリプトを使っていたが、Archは特に何もしなくても最新版が落ちてきて非常に良い。
[dlang パッケージグループ](https://www.archlinux.org/groups/x86_64/dlang/)をインストールすれば一発で(自分が使う分には)完璧なセットが揃う。
今の所速度を気にしたり他のプラットフォームで動かしたりすることはないのでコンパイラはdmdしか使っていない。

```console
$ pacman -Ss dlang
community/dcd 0.9.1-2 (dlang) [installed]
    D Completion Daemon: auto-complete for the D programming language
community/dfmt 0.7.0-1 (dlang) [installed]
    Dfmt is a formatter for D source code
community/dmd 1:2.079.0-1 (dlang dlang-dmd) [installed]
    The D programming language reference compiler
community/dmd-docs 1:2.079.0-1 (dlang dlang-dmd) [installed]
    Documentation and sample code for D programming language
community/dscanner 0.5.1-1 (dlang) [installed]
    Swiss-army knife for D source code
community/dtools 2.079.0-1 (dlang) [installed]
    Ancilliary tools for the D programming language
community/dub 1.8.0-1 (dlang) [installed]
    Developer package manager for D programming language
community/ldc 1:1.8.0-2 (dlang dlang-ldc) [installed]
    A D Compiler based on the LLVM Compiler Infrastructure including D runtime and libphobos2
community/liblphobos 1:1.8.0-2 (dlang dlang-ldc) [installed]
    A D Compiler based on the LLVM Compiler Infrastructure including D runtime and libphobos2
community/libphobos 1:2.079.0-1 (dlang dlang-dmd) [installed]
    The Phobos standard library for D programming language
```

### ライブラリ

[標準ライブラリ](https://dlang.org/phobos/index.html)が充実しすぎていて特に使わない。
なので最近は[パッケージマネージャーであるdub](https://code.dlang.org/)も使っておらず、もっぱら直接dmdを使うかMakefileを書いている。

### 端末

[Tilix](https://gnunn1.github.io/tilix-web/)を使っている。
[D言語製](https://github.com/gnunn1/tilix)というのも選んだ理由の一つだが、なにより便利である。
ただおそらく機能の1割も使えていないし、他のターミナルエミュレータもTilixを入れるためにデフォルトのgnome-terminalを使うくらいしか試していないので、井の中の蛙感がある。

### エディター

[Visual Studio Code](https://code.visualstudio.com/)を使っている。
AURに`code`というパッケージ名で登録されており、`/usr/bin/code-oss`が入る。
`"editor.fontFamily": "'Noto Sans Mono CJK JP'"`以外はほとんどデフォルト設定のままである。
デフォルトでもそれなりに便利というのは重要だと思う。

たしか調査でもD言語erの中のかなりの割合がVSCodeを使っているということだったと思う。

[dlang-vscode.dlang](https://marketplace.visualstudio.com/items?itemName=dlang-vscode.dlang)という拡張機能があり、これを導入すればいろんなツールが使えるようになる。
`ctrl + shift + i`でコードの整形をしてくれるのでこまめに押すといいと思う。

Dに限らずVSCodeは便利で、この記事もVSCodeで書かれている。
基本的にVSCodeがメインで、ちょっとした編集作業にはvimやgeditを使うこともあるといった感じ。
どうも大学はemacsを推しているようなので操作を覚えないといけない。

### 競技プログラミング

D言語で競プロができるところは[AtCoder](http://atcoder.jp/)しか知らない。
dmdのバージョンがちょっと古いので、最新のdmdを使って書いているとローカルでは動くのに提出するとCE、みたいなことが頻発して悲しい気持ちになる。
そこでDockerを使って同じバージョンを使えるようにしている。
これによって新しい環境でもDockerがあればとりあえず

```
sudo docker run --rm -v $PWD:/src -w /src dlanguage/dmd:2.070.1 dmd app.d
```

という感じでコマンド一発でコンパイルだけはできるようになり、比較的素早くコンテストを開始できるようになった。