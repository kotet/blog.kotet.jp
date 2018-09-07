---
date: 2017-12-10
aliases:
- /2017/12/10/interfacing-d-with-c-getting-started.html
title: "DとCのインターフェース:入門編【翻訳】"
tags:
- dlang
- tech
- translation
- d_and_c
- d_blog
excerpt: "D言語の短期的な設計目標の一つにCとのインターフェース能力があります。 その目標のために、Cの標準ライブラリへのアクセスを可能にし、CやC++コンパイラが使うのと同じオブジェクトファイルフォーマットとシステムリンカを使うABI互換を提供しています。"
---

この記事は[D言語 Advent Calendar 2017](https://qiita.com/advent-calendar/2017/dlang) 10日目の記事であり、
[Interfacing D with C: Getting Started – The D Blog](https://dlang.org/blog/2017/12/05/interfacing-d-with-c-getting-started/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
内容が理解できる程度のざっくりした翻訳であり誤字や誤訳などが多いので、気になったら
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

<!-- One of the early design goals behind the D programming language was the ability to [interface with C](https://dlang.org/spec/interfaceToC.html). To that end, it provides ABI compatibility, allows access to the C standard library, and makes use of the same object file formats and system linkers that C and C++ compilers use. Most built-in D types, even structs, are directly compatible with their C counterparts and can be passed freely to C functions, provided the functions have been declared in D with the appropriate [linkage attribute](https://dlang.org/spec/attribute.html#linkage). In many cases, one can copy a chunk of C code, paste it into a D module, and compile it with minimal adjustment. Conversely, appropriately declared D functions can be called from C. -->

D言語の短期的な設計目標の一つに[Cとのインターフェース](https://dlang.org/spec/interfaceToC.html)能力があります。
その目標のために、Cの標準ライブラリへのアクセスを可能にし、CやC++コンパイラが使うのと同じオブジェクトファイルフォーマットとシステムリンカを使うABI互換を提供しています。
ほとんどのDの組み込み型、構造体までもがCとの直接の互換をもち、適切な[リンケージアトリビュート](https://dlang.org/spec/attribute.html#linkage)とともにD内で宣言されたCの関数に自由に渡すことができます。
大抵の場合、Cのコードをコピーし、それをDのモジュールにペーストして、最低限の修正をすればコンパイルできます。
反対に、適切に宣言されたDの関数はCから呼び出すことができます。

<!-- That’s not to say that D carries with it all of C’s warts. It includes features intended to eliminate, or more easily avoid, some of the errors that are all too easy to make in C. For example, bounds checking of arrays is enabled by default, and a safe subset of the language provides compile-time enforcement of memory safety. D also changes or avoids some things that C got wrong, such as what Walter Bright sees as [C’s biggest mistake](http://www.drdobbs.com/architecture-and-design/cs-biggest-mistake/228701625): conflating pointers with arrays. It’s in these differences of implementation that surprises lurk for the uninformed. -->

これはDがCの欠点までそのまま持っているというわけではありません。
DにはCでよく発生するエラーをなくす、あるいは簡単に回避するための機能があります。
たとえば、配列の境界チェックはデフォルトで有効であり、言語のsafeサブセットはメモリ安全をコンパイル時に強制します。
また、DはWalter Brightが[Cの最大の失敗](http://www.drdobbs.com/architecture-and-design/cs-biggest-mistake/228701625)と考えるCの悪いところを変更または回避しています。
ポインタと配列の混同です。
ここには知識のない人が驚かされる実装の違いが潜んでいます。

<!-- This post is the first in a series exploring the interaction of D and C in an effort to inform the uninformed. I’ve previously written about the basics of this topic in [an article at GameDev.net](https://www.gamedev.net/articles/programming/general-and-gameplay-programming/binding-d-to-c-r3122/), and in my book, ‘[Learning D](http://amzn.to/1IlQkZX)’, where the entirety of Chapter 9 covers it in depth. -->

これは知識のない人に伝えるためにCとDのインタラクションを探求するシリーズ最初の投稿です。
以前私はこのトピックの基本的な部分に関して[GameDev.netで記事を](https://www.gamedev.net/articles/programming/general-and-gameplay-programming/binding-d-to-c-r3122/)書いており、また詳細については私の本‘[Learning D](http://amzn.to/1IlQkZX)’のチャプター9全体で触れています。

<!-- This blog series will focus on those aforementioned corner cases so that it’s not necessary to buy the book or to employ trial and error in order to learn them. As such, I’ll leave the basics to the GameDev.net article and recommend that anyone interfacing D with C (or C++) give it a read along with [the official documentation](https://dlang.org/spec/interfaceToC.html). -->

このブログシリーズでは前述のコーナーケースに焦点を当てていくので、それを学ぶために本を買ったり試行錯誤したりする必要はありません。
したがって、DとC（またはC++）とのインターフェーシングをする人は私がGameDev.netの記事に残した基礎と[公式ドキュメント](https://dlang.org/spec/interfaceToC.html)を一緒に読むことをお勧めします。

<!-- The C and D code that I provide to highlight certain behavior is intended to be compiled and linked by the reader. The code demonstrates both error and success conditions. Recognizing and understanding compiler errors is just as important as knowing how to fix them, and seeing them in action can help toward that end. That implies some prerequisite knowledge of compiling and linking C and D source files. Happily, that’s the focus of the next section of this post. -->

ある振る舞いをハイライトするために私が提供するCやDのコードは読者によってコンパイルし、リンクされることを意図しています。
コードは失敗や成功を実演します。
コンパイラのエラーを知り、理解することはそれを直す事と同じくらい重要であり、実際にそれらを見ることは直すという目標のために役立ちます。
それはCとDのソースファイルのコンパイルとリンクの必須知識を伴います。
幸いなことに、それはこの投稿の次のセクションで見ていくものです。

<!-- For the C code, we’ll be using the Digital Mars C/C++ and Microsoft C/C++ compilers on Windows, and GCC and Clang elsewhere. On the D side, we’ll be working exclusively with the D reference compiler, DMD. Windows users unfamiliar with setting up DMD to work with the Microsoft tools will be well served by the post on this blog titled, ‘[DMD, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c/)’. -->

Cのコードには、WindowsではDigital Mars C/C++コンパイラとMicrosoft C/C++コンパイラを、それ以外ではGCCとClangを使います。
Dの方は、もっぱらDのリファレンスコンパイラ、DMDを使います。
Microsoftのツールを使ったDMDのセットアップに慣れていないWindowsユーザーは、こちらの‘[DMD, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c/)’という記事が役に立ちます。

<!-- We’ll finish the post with a look at one of the corner cases, one that is likely to rear its head early on in any exploration of interfacing D with C, particularly when creating bindings to existing C libraries. -->

この投稿ではコーナーケースのひとつ、DとCのインターフェースを始めてすぐ、特に既存のCのライブラリのバインディングを作るときに現れるようなものを取り扱います。

<!-- ### Compiling and linking -->

### コンパイルとリンク

<!-- The articles in this series will present example C source code that is intended to be saved and compiled into object files for linking with D programs. The command lines for generating the object files look pretty much the same on every platform, with a couple of caveats. We’ll look first at Windows, then lump all the other supported systems together in a single section. -->

この記事では、Dのプログラムとリンクされるために保存されオブジェクトファイルへとコンパイルされることを意図したCのソースコードの例を示します。
オブジェクトファイルを生成するコマンドラインは、どのプラットフォームでも同じような複数の手順からなります。
まずはWindowsのやり方を見て、その後他のシステムは１つのセクションにまとめようと思います。

<!-- In the next two sections, we’ll be working with the following C and D source files. Save them in the same directory (for convenience) and make sure to keep the names distinct. If both files have the same name in the same directory, then the object files created by the C compiler and DMD will also have the same name, causing the latter to overwrite the former. There are compiler switches to get around this, but for a tutorial we’re better off keeping the command lines simple. -->

次の2セクションでは、以下のCとDのソースファイルを使います。
これらを同じディレクトリに（便宜上です）そのままの名前で保存してください。
2つのファイルが同じディレクトリ内で同じ名前である場合、CコンパイラやDMDで作られるオブジェクトファイルも同じ名前になり、古いオブジェクトファイルが新しいオブジェクトファイルで上書きされてしまいます。
これを避けるためのコンパイラスイッチもありますが、チュートリアルのためコマンドラインはシンプルにしておきましょう。

<!-- **chello.c** -->

**chello.c**

<!-- ```c
#include <stdio.h>
void say_hello(void) 
{
    puts("Hello from C!");
}
``` -->

```c
#include <stdio.h>
void say_hello(void) 
{
    puts("Hello from C!");
}
```

<!-- **hello.d** -->

**hello.d**

<!-- ```d
extern(C) void say_hello();
void main() 
{
    say_hello();
}
``` -->

```d
extern(C) void say_hello();
void main() 
{
    say_hello();
}
```

<!-- The `extern(C)` bit in the declaration of the C function in the D code is [a linkage attribute](https://dlang.org/spec/attribute.html#linkage). That’s covered by the other material I referenced above, but it’s a potential gotcha we’ll look at later in this series. -->

Dのコード内にあるCの関数の宣言の`extern(C)`という部分は[リンケージ属性](https://dlang.org/spec/attribute.html#linkage)です。
これは上記以外のものにも関わってきますが、その潜在的なハマりどころはこのシリーズの別の機会に見ていきます。

<!-- #### Windows -->

#### Windows

<!-- The offical DMD packages for Windows, [available at dlang.org](https://dlang.org/download.html) as a zip archive and an installer, are the only released versions of DMD that do not require any additional tooling to be installed as a prerequisite to compile D files. These packages ship with everything they need to compile 32-bit executables in the OMF format (again, I refer you to ‘[DMD, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c/)’ for the details). -->

Zipアーカイブとインストーラとして[dlang.orgで入手できる](https://dlang.org/download.html)公式DMDパッケージは、Dのファイルをコンパイルする前提として他のツールをインストールする必要のないDMDのリリースバージョンです。
これらのパッケージはOMFフォーマットで32ビット実行ファイルをコンパイルするために必要な全てが含まれた状態で公開されています（詳細は‘[DMD, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c/)’ で触れています）。

<!-- When linking any foreign object files with a D program, it’s important that the object file format and architecture match the D compiler output. The former is an issue primarily on Windows, while attention must be paid to the latter on all platforms. -->

外部のオブジェクトファイルとDのプログラムをリンクする時、そのオブジェクトファイルフォーマットとアーキテクチャがDコンパイラの出力と一致していることが重要です。
前者は主にWindowsの問題ですが、後者についてはすべてのプラットフォームで注意する必要があります。

<!-- Compiling C source to a format compatible with vanilla DMD on Windows requires [the Digital Mars C/C++ compiler](http://digitalmars.com/download/freecompiler.html). It’s a free download and ships with some of the same tools as DMD. It outputs object files in the OMF format. With both it and DMD installed and on the system path, the above source files can be compiled, linked, and executed like so: -->

CのソースをWindowsのヴァニラDMD互換のフォーマットでコンパイルするには[the Digital Mars C/C++ compiler](http://digitalmars.com/download/freecompiler.html)が必要です。
DMDと同じようなツール群とともに公開されており、自由にダウンロードすることができます。
これはOMFフォーマットのオブジェクトファイルを出力します。
これとDMDの両方をインストール、システムパスに配置すれば、上記のソースファイルはこのようにコンパイル、リンク、実行ができます:

<!-- ```
dmc -c chello.c
dmd hello.d chello.obj
hello
``` -->

```
dmc -c chello.c
dmd hello.d chello.obj
hello
```

<!-- The `-c` option tells DMC to forego linking, causing it to only compile the C source and write out the object file `chello.obj`. -->

`-c`オプションはDMCにリンクをさせないようにするもので、その結果Cのソースはコンパイルのみが行われオブジェクトファイル`chello.obj`が出力されます。

<!-- To get 64-bit output on Windows, DMC is not an option. In that case, DMD requires the Microsoft build tools on Windows. Once the MS build tools are installed and set up, open the preconfigured x64 Native Tools Command Prompt from the Start menu and execute the following commands (again, see ‘[D, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c)’ on this blog for information on how to get the Microsoft build tools and open the preconfigured command prompt, which may have a slightly different name depending on the version of Visual Studio or the MS Build Tools installed): -->

Windowsで64ビットの出力を得るときには、DMCは使いません。
この場合、DMDはWindowsのMicrosoft build toolsを要求します。
MS build toolsをインストールしたら、設定済みx64ネイティブツールコマンドプロンプトを開き、以下のコマンドを実行します（Microsoft build toolsの入手と設定済コマンドプロンプトの開き方についてはこのブログの‘[D, Windows, and C](https://dlang.org/blog/2017/10/25/dmd-windows-and-c)’を見てください。依存するVisual StudioやMS build toolsのバージョンがちょっと違うかもしれません）:

<!-- ```
cl /c chello.c
dmd -m64 hello.d chello.obj
hello
``` -->

```
cl /c chello.c
dmd -m64 hello.d chello.obj
hello
```

<!-- Again, the `/c` option tells the compiler not to link. To produce 32-bit output with the MS compiler, open a preconfigured x86 Native Tools Command Prompt and execute these commands: -->

`/c`オプションはやはりコンパイラにリンクをさせないためのものです。
MSコンパイラで32ビットの出力を生成するためには、設定済x86ネイティブツールコマンドプロンプトを開きこれらのコマンドを実行してください:

<!-- ```
cl /c hello.c
dmd -m32mscoff hello.c chello.obj
hello
``` -->

```
cl /c hello.c
dmd -m32mscoff hello.c chello.obj
hello
```

<!-- DMD recognizes the `-m32` switch on Windows, but that tells it to produce 32-bit OMF output (the default), which is not compatible with Microsoft’s linker, so we must use `-m32mscoff` here instead. -->

WindowsにおいてDMDは`-m32`スイッチを認識しますが、それは（デフォルトでは）Microsoftのリンカと互換性のない32ビットOMFの出力を生成するので、かわりに`-m32mscoff`を使う必要があります。

<!-- #### Other platforms -->

#### その他のプラットフォーム

<!-- On the other platforms D supports, the system C compiler is likely going to be GCC or Clang, one of which you will already have installed if you have a functioning `dmd` command. On Mac OS, `clang` can be installed via `XCode` in the App Store. Most Linux and BSD systems have a GCC package available, such as via the often recommended command line, `apt-get install build-essential`, on Debian and Debian-based systems. Please see the documentation for your system for details. -->

Dをサポートしている他のプラットフォームでは、GCCやClangのようなシステムCコンパイラは`dmd`が動作するなら既にインストールされています。
Mac OSでは、App Storeの`XCode`で`clang`がインストールできます。
ほとんどのLinuxやBSDでは、例えばDebianやDebianベースのシステムにおいて推奨されるコマンドライン`apt-get install build-essential`のようにGCCパッケージが利用できます。
詳しくはあなたのシステムのドキュメントを見てください。

<!-- On these systems, the environment variable `CC` is often set to the system compiler command. Feel free to substitue either `gcc` or `clang` for `CC` in the lines below as appropriate for your system. -->

これらのシステムでは、たいてい環境変数`CC`にシステムコンパイラのコマンドがセットされています。
あなたのシステムに合わせて以下の`CC`は`gcc`か`clang`のどちらかに置き換えてください。

<!-- ```
CC -c chello.c
dmd hello.d chello.o
./hello
``` -->

```
CC -c chello.c
dmd hello.d chello.o
./hello
```

<!-- This will produce either 32-bit or 64-bit output, depending on your system configuration. If you are on a 64-bit system and have 32-bit developer tools installed, you can pass `-m32` to both `CC` and `dmd` to generate 32-bit binaries. -->

これはあなたのシステムの設定に合わせて32ビットまたは64ビットの出力を生成します。
あなたが64ビットのシステムに32ビットのデベロッパーツールをインストールしている場合、`-m32`を`CC`と`dmd`の両方に渡すことで32ビットバイナリを生成できます。

<!-- ### The `long` way -->

### `long`な道のり

<!-- Now that we’re configured to compile and link C and D source in the same binary, let’s take a look at a rather common gotcha. To fully appreciate this one, it helps to compile it on both Windows and another platform. -->

CとDのソースを同じバイナリにコンパイルしリンクできるようになったので、さらに一般的な落とし穴を見ていきましょう。
これを正しく理解することは、Windowsとその他のプラットフォーム両方で役に立ちます。

<!-- One of the features of D is that all of the integral types have a fixed size. A `short` is always 2 bytes and an `int` is always 4\. This never changes, no matter the underlying system architecture. This is quite different from C, where the spec only imposes relative requirements on the size of each integral type and leaves the specifics to the implementation. Even so, there are wide areas of agreement across modern compilers such that on every platform D currently supports the sizes for almost all the integral types match those in D. The exceptions are `long` and `ulong`. -->

Dの特徴の1つとして、すべての整数型のサイズは固定されています。
`short`は常に2バイトであり、`int`は4バイトです。
これはシステムのアーキテクチャにかかわらず決して変わりません。
これは仕様が各整数型のサイズを相対的にしか指定せず、実装に任せているCとは異なります。
それでもモダンなコンパイラの間では幅広い合意があり、現在Dがサポートするすべてのプラットフォームにおけるほとんどの整数型のサイズはDのそれと一致します。
例外は`long`と`ulong`です。

<!-- In D, `long` and `ulong` are always 8 bytes. This lines up with most 64-bit systems under the `version(Posix)` umbrella, where `long` and `unsigned long` are also 8 bytes. However, they are 4 bytes on 32-bit architectures. Moreover, they’re _always_ 4 bytes on Windows, even on a 64-bit architecture. -->

Dにおいて、`long`と`ulong`は常に8バイトです。
`version(Posix)`傘下にあるほとんどの64ビットシステムでは足並みが揃っており、`long`と`unsigned long`も8バイトです。
しかし32ビットアーキテクチャにおいては4バイトです。
さらに、Windowsにおいては64ビットアーキテクチャであっても**常に**4バイトです。

<!-- Most C code these days will account for these differences either by using the preprocessor to define custom integral types or by making use of the C99 `stdint.h` where types such as `int32_t` and `int64_t` are unambiguously defined. Yet, it’s still possible to encounter C libraries using `long` in the wild. -->

今日のほとんどのCコードはこれらの違いを考慮しプリプロセッサを使うことによってカスタム整数型を定義するか、誤解の余地なく定義される`int32_t`や`int64_t`のような型のあるC99 `stdint.h`を使うようにしています。
しかしいまだに`long`をそのまま使っているCライブラリに遭遇することがあります。

<!-- Consider the following C function: -->

以下のようなCの関数を考えてみましょう:

<!-- **maxval.c** -->

**maxval.c**

<!-- ```c
#include <limits.h>
unsigned long max_val(void)
{
    return ULONG_MAX;
}
``` -->

```c
#include <limits.h>
unsigned long max_val(void)
{
    return ULONG_MAX;
}
```

<!-- The naive D implementation looks like this: -->

素朴なDの実装はこのようになります:

<!-- **showmax1.d** -->

**showmax1.d**

<!-- ```d
extern(C) ulong max_val();
void main()
{
    import std.stdio : writeln;
    writeln(max_val());
}
``` -->

```d
extern(C) ulong max_val();
void main()
{
    import std.stdio : writeln;
    writeln(max_val());
}
```

<!-- What this does depends on the C compiler and architecture. For example, on Windows with `dmc` I get `7316910580432895`, with x86 `cl` I get `59663353508790271`, and `4294967295` with x64 `cl`. The last one is actually the correct value, even though the size of the `unsigned long` on the C side is still 4 bytes as it is in the other two scenarios. I assume this is because the x64 ABI stores return values in the 8-byte `RAX` register, so it can be read into the 8-byte `ulong` on the D side with no corruption. The important point here is that the two values in the x86 code are garbage because the D side is expecting a 64-bit return value from 32-bit registers, so it’s reading more than it’s being given. -->

結果はCコンパイラとアーキテクチャに依存します。
例えば、Windowsの`dmc`では`7316910580432895`、x86 `cl`では`59663353508790271`、x64 `cl`では`4294967295`になります。
C側の`unsigned long`のサイズは最後のものも他の2つと変わらず4バイトですが、この最後の値が本当の正しい値です。
おそらくx64 ABIが返り値を8バイトの`RAX`レジスタに保存し、それがD側の8バイトである`ulong`として問題なく読めてしまうからだと思います。
ここで重要なポイントは、D側が32ビットのレジスタに64ビットの返り値を期待しており、実際の値より大きな値を呼んでいるため、x86のコードの2つの値は役に立たないと言うことです。

<!-- Thankfully, DRuntime provides a way around this in `core.c.config`, where you’ll find `c_long` and `c_ulong`. Both of these are conditionally configured to match the compile-time C runtime implementation and architecture configuration. With this, all that’s needed is to change the declaration of `max_val` in the D module, like so: -->

幸いにも、DRuntimeは`core.c.config`でこの問題の回避策を提供しており、`c_long`と`c_ulong`があります。
これら2つはCのランタイム実装とアーキテクチャの構成に合うよう、コンパイル時に調整されます。
これにより、Dのモジュール内の`max_val`の宣言をこのように変更する必要があります:

<!-- **showmax2.d** -->

**showmax2.d**

<!-- ```d
import core.stdc.config : c_ulong;
extern(C) c_ulong max_val();

void main()
{
    import std.stdio : writeln;
    writeln(max_val());
}
``` -->

```d
import core.stdc.config : c_ulong;
extern(C) c_ulong max_val();

void main()
{
    import std.stdio : writeln;
    writeln(max_val());
}
```

<!-- Compile and run with this and you’ll find it does the right thing everywhere. On Windows, it’s `4294967295` across the board. -->

コンパイルし実行するとどこであっても正しい結果が得られます。
Windowsにおいては、一律で`4294967295`になります。

<!-- Though less commonly encountered, `core.stdc.config` also declares a portable `c_long_double` type to match any `long double` that might pop up in a C library to which a D module must bind. -->

遭遇することは少ないですが、`core.stdc.config`は`long double`に対応したポータブルな`c_long_double`型も宣言しており、DのモジュールがバインドしなければならないCライブラリに登場するかもしれません。

<!-- ### Looking ahead -->

### この先について

<!-- In this post, we’ve gotten set up to compile and link C and D in the same executable and have looked at the first of several potential problem spots. The next post in this series will focus entirely on getting D arrays and C arrays to cooperate. See you there! -->

この投稿で、CとDをコンパイルし同じ実行ファイルにリンクするためのセットアップをし、最初のつまづきポイントをいくつか見ていきました。
このシリーズの次の投稿ではDの配列とCの配列を協調させることについてフォーカスしていきます。
ではまた!