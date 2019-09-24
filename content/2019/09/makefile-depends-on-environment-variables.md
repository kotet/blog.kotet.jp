---
title: "環境変数が設定されると再コンパイルするmakefile"
date: 2019-09-24
tags:
- cpplang
- tech
---

最近は主にRoboDragonsにフォーマッタを導入したりコンパイル時チェックを増やしたりしています。
[RoboDragons](https://robodragons.github.io/)
は何年も日本1位を維持しているのに他学部の人間にはほぼ認知されていないかわいそうなロボサッカーチームです。

そのなかでひとつ便利そうな知識を得たので書いておこうと思います。

### 環境変数を元にコンパイルされるターゲット

たとえば以下のようなC++コードがあるとしましょう。

```cpp
#include <iostream>

#if defined(NUMBER)
constexpr int number = NUMBER;
#else
constexpr int number = 42;
#endif

int main(int argc, char const *argv[])
{
    std::cout << number << std::endl;
    return 0;
}
```

これを以下のように`-D`オプションをつけてコンパイルすると、指定したとおりの数字が出力されます。

```
g++ hello.cpp -o hello -DNUMBER=7
```

```console
$ ./hello 
7
```

これをmakefileに書くと、コンパイルの自動化ができます。

```makefile
hello: hello.cpp
	g++ $< -o $@ -DNUMBER=7

.PHONY: clean

clean:
	rm -f hello
```

```console
$ make
g++ hello.cpp -o hello -DNUMBER=7
```

さて、ここで渡す数値を環境変数で指定したくなりました。
まあ以下のように書けばいいでしょう。

```makefile
hello: NUMBER?=7 # デフォルト値
hello: hello.cpp
	g++ $< -o $@ -DNUMBER=$(NUMBER)
```

```console
$ NUMBER=33 make
g++ hello.cpp -o hello -DNUMBER=33
$ ./hello 
33
```

しかしここで問題が発生します。環境変数を変更してみましょう。

```console
$ NUMBER=4 make
make: 'hello' is up to date.
```

そう、環境変数が書き換わってもmakeは再コンパイルをしてくれないのです。
この問題のちょっとマシな解決策を見つけました。

[makefile - How do I force a target to be rebuilt if a variable is set? - Stack Overflow](https://stackoverflow.com/questions/26145267/how-do-i-force-a-target-to-be-rebuilt-if-a-variable-is-set)

この記事ではその手法を解説します。

### up to dateにならないターゲット

`make clean`などは何度実行しても同じコマンドが実行されます。

```console
$ make clean
rm -f hello
$ make clean
rm -f hello
$ make clean
rm -f hello
```

何度実行してもup to dateにならないのです。
この「何度実行してもup to dateにならない」という性質だけを取り出すとこんな感じのターゲットになります。

```makefile
.PHONY: do_nothing_and_never_up_to_date
do_nothing_and_never_up_to_date:
    @:
```

`:` はなにもしないコマンドです。なにもしないのでなにもしません。

このターゲットを依存に入れるとどんなときも必ずコンパイルされるようになります。

```makefile
hello: hello.cpp do_nothing_and_never_up_to_date
	g++ $< -o $@ -DNUMBER=$(NUMBER)
```

```console
$ NUMBER=33 make
g++ hello.cpp -o hello -DNUMBER=33
$ make
g++ hello.cpp -o hello -DNUMBER=7
$ make
g++ hello.cpp -o hello -DNUMBER=7
```

### patsubst

`patsubst`という組み込み関数があります。
これは文字列中の特定のパターンを特定の文字列に置き換える関数です。

以下のように書くと`NUMBER`中のすべてが`test`に置き換わった文字列が返ります。

```makefile
$(patsubst %,test,$(NUMBER))
```

`123`は`test`に、`1 2 3`は`test test test`になります。
空文字列を渡すと空文字列が返ります。

### 組み合わせる

上2つを組み合わせてできたmakefileがこちらになります。

```makefile
hello: NUMBER?=7
hello: hello.cpp $(patsubst %,depends_on,$(NUMBER))
	g++ $< -o $@ -DNUMBER=$(NUMBER)

.PHONY: clean depends_on

depends_on:
    @:

clean:
	rm -f hello
```

変数`NUMBER`が設定されていないときは通常動作、設定されているときは`depends_on`ターゲットが依存に入るため毎回リビルドされます。

```console
$ make
g++ hello.cpp -o hello -DNUMBER=7
$ make
make: 'hello' is up to date.
$ NUMBER=1 make
g++ hello.cpp -o hello -DNUMBER=1
$ NUMBER=1 make
g++ hello.cpp -o hello -DNUMBER=1
```

