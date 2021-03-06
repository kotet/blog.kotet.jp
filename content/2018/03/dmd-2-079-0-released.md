---
date: 2018-03-05
aliases:
- /2018/03/05/dmd-2-079-0-released.html
title: "DMD 2.079.0 Released【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "D言語財団はDプログラミング言語のリファレンスコンパイラ、DMDのバージョン2.079.0をアナウンスします。 "
---

この記事は、
[DMD 2.079.0 Released – The D Blog](https://dlang.org/blog/2018/03/03/dmd-2-079-0-released/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

<!-- The D Language Foundation is happy to announce version 2.079.0 of DMD, the reference compiler for the D programming language. This latest version [is available for download](https://dlang.org/download.html) in multiple packages. [The changelog](https://dlang.org/changelog/2.079.0.html) details the changes and bugfixes that were the product of [78 contributors](https://dlang.org/changelog/2.079.0.html#contributors) for this release. -->

D言語財団はDプログラミング言語のリファレンスコンパイラ、DMDのバージョン2.079.0をアナウンスします。
この最新版は複数のパッケージで[ダウンロードできます](https://dlang.org/download.html)。
[チェンジログ](https://dlang.org/changelog/2.079.0.html)でこのリリースの[78人のコントリビュータによる](https://dlang.org/changelog/2.079.0.html#contributors)
変更とバグフィックスを見ることができます。

<!-- It’s not always easy to choose which enhancements or changes from a release to highlight on the blog. What’s important to some will elicit a shrug from others. This time, there’s so much to choose from that my head is spinning. But two in particular stand out as having the potential to result in a significant impact on the D programming experience, especially for those who are new to the language. -->

リリースの中のどの改善をこのブログで取り上げるか選ぶ作業はいつだって簡単ではありません。
誰かにとって重要なことが他の誰かにとっては関心のないことだったりします。
今回、特にどれを選ぶか悩みました。
しかし、Dプログラミング言語の、特に初心者のエクスペリエンスに大きな影響をもたらすポテンシャルを持つ、特に目立つ2つを紹介します。

<!-- ### No Visual Studio required -->

### Visual Studioが不要に

<!-- Although it has only [a small entry](https://dlang.org/changelog/2.079.0.html#lld_mingw) in the changelog, this is a very big deal for programming in D on Windows: the Microsoft toolchain is no longer required to link 64-bit executables. The [previous release](https://dlang.org/blog/2018/01/04/dmd-2-078-0-has-been-released/) made things easier by eliminating the need to configure the compiler; it now searches for a Visual Studio or Microsoft Build Tools installation when either `-m32mscoff` or `-m64` are passed on the command line. This release goes much further. -->

チェンジログでは[小さな1エントリ](https://dlang.org/changelog/2.079.0.html#lld_mingw)でしかありませんが、これはWindowsにおけるDでのプログラミングにとって大きな変更です。
64ビット実行ファイルをリンクするのにもはやMicrosoftツールチェインは必要ありません。
[前回のリリース](/2018/01/dmd-2-078-0-has-been-released)[^1]
ではコンパイラの設定を不要にすることで作業が簡単になりました。
コマンドラインに`-m32mscoff`または`-m64`が渡された場合、Visual StudioやMicrosoft Build Toolsがインストールされていないか検索します。
このリリースではそこからさらに改善されました。

[^1]: 原文:[https://dlang.org/blog/2018/01/dmd-2-078-0-has-been-released/](https://dlang.org/blog/2018/01/dmd-2-078-0-has-been-released/)

<!-- DMD on Windows now ships with a set of platform libraries built from the MinGW definitions and a wrapper library for the VC 2010 C runtime (the changelog only mentions the installer, but this is all bundled in the zip package as well). When given the `-m32mscoff` or `-m64` flags, if the compiler fails to find a Windows SDK installation (which comes installed with newer versions of Visual Studio – with older versions it must be installed separately), it will fallback on these libraries. Moreover, the compiler now ships with `lld`, the LLVM linker. If it fails to find the MS linker, this will be used instead (note, however, that the use of this linker is currently considered experimental). -->

WindowsのDMDはVC 2010 C ランタイムのラッパライブラリであるMinGWからビルドされたプラットフォームライブラリとセットで配布されるようになりました
(チェンジログはインストーラについてしか言及していませんが、zipパッケージにもバンドルされています)。
`-m32mscoff`や`-m64`フラグが与えられ、コンパイラがWindows SDKのインストール
(最新版のVisual Studioでは一緒にインストールされます。古いバージョンでは別にインストールが必要です)
を検出できなかったとき、これらのライブラリにフォールバックします。
更に、コンパイラは`lld`、LLVMのリンカも合わせて公開されます。
MSのリンカが見つからなければ、かわりにこれが使われます(ただし、現在はこのリンカの使用は実験的なものです)。

<!-- So the 64-bit and 32-bit COFF output is now an out-of-the-box experience on Windows, as it has always been with the OMF output (`-m32`, which is the default). This should make things a whole lot easier for those coming to D without a C or C++ background on Windows, for some of whom the need to install and configure Visual Studio has been a source of pain. -->

というわけで、64ビットと32ビット COFFの出力はOMFの出力(`-m32`、デフォルトです)を持つためWindowsにおいて「箱から出してすぐ使える」ようになりました。
これによってWindowsにおいて、めんどくさいVisual Studioのインストールと設定が必要なCやC++のバックグラウンド無しでDを始めるのが簡単になりました。

<!-- ### Automatically compiled imports -->

### 自動コンパイルされるインポート

<!-- Another trigger for some new D users, particularly those coming from a mostly Java background, has been the way imports are handled. Consider the venerable ‘Hello World’ example: -->

Dの初心者、特にJavaをバックグラウンドに持つ人におけるもう一つの変化が、インポートの扱い方です。
由緒正しい‘Hello World’を例に考えてみましょう:

```d
import std.stdio;

void main() {
    writeln("Hello, World!");
}
```

<!-- Someone coming to D for the first time from a language that automatically compiles imported modules could be forgiven for assuming that’s what’s happening here. Of course, that’s not the case. The `std.stdio` module is part of [Phobos, the D standard library](https://dlang.org/phobos/index.html), which ships with the compiler as a precompiled library. When compiling an executable or shared library, the compiler passes it on to the linker along any generated object files. -->

インポートしたモジュールが自動的にコンパイルされる言語から初めてDに来た人は、ここで起きていることを前提として受け入れます。
もちろん、それは間違っています。
`std.stdio`モジュールは[Phobos、Dの標準ライブラリ](https://dlang.org/phobos/index.html)の一部であり、プリコンパイルされたライブラリとしてコンパイラと一緒に配布されるものです。
実行ファイルや共有ライブラリをコンパイルするとき、コンパイラはそれをリンカに生成されたオブジェクトファイルとともに渡します。

<!-- The surprise comes when that same newcomer attempts to compile multiple files, such as: -->

新人が驚くのは以下のように複数のファイルをコンパイルしようとしたときです:

```d
// hellolib.d
module hellolib;
import std.stdio;

void sayHello() {
    writeln("Hello!");
}

// hello.d
import hellolib;

void main() {
    sayHello();
}
```


<!-- The common mistake is to do this, which results in a linker error about the missing `sayHello` symbol: -->

一般的な間違いとして以下のようなことが行われ、結果としてリンカは`sayHello`シンボルの不足をエラーとして報告します:

```
dmd hello.d
```

<!-- D compilers have never considered imported modules for compilation. Only source files passed on the command line are actually compiled. So the proper way to compile the above is like so: -->

Dコンパイラはインポートされたモジュールについて考えません。
コマンドラインで渡されたソースファイルのみがコンパイルされます。
つまり上のものを正しくコンパイルするにはこのようにします:

```
dmd hello.d hellolib.d
```

<!-- The `import` statement informs the compiler which symbols are visible and accessible in the current compilation unit, not which source files should be compiled. In other words, during compilation, the compiler doesn’t care whether imported modules have already been compiled or are intended to be compiled. The user must explicitly pass either all source modules intended for compilation on the command line, or their precompiled object or library files for linking. -->

`import`文がコンパイラに伝えるのはシンボルが現在のコンパイルユニットから見えてアクセスできるということであり、ソースファイルをコンパイルしなければならないということは伝えません。
言い換えると、コンパイル中、コンパイラはインポートされたモジュールがすでにコンパイルされたものか、コンパイルしてほしいものなのかについて関知しないということです。
ユーザーは明示的にコンパイルしてほしいソースモジュールか、プリコンパイルされたオブジェクトまたはライブラリファイルを渡さなければなりません。

<!-- It’s not that adding support for compiling imported modules is impossible. It’s that doing so comes with some configuration issues that are unavoidable thanks to the link step. For example, you don’t want to compile imported modules from `libFoo` when you’re already linking with the `libFoo` static library. This is getting into the realm of build tools, and so the philosophy has been to leave it up to build tools to handle. -->

インポートされたモジュールのコンパイルのサポートは不可能ではありません。
それはリンクの段階の存在によって回避不能な問題を引き起こします。
たとえば、`libFoo`静的ライブラリをリンクするため、`libFoo`からインポートしたモジュールをコンパイルしたくないという場合です。
それはビルドツールの領域であり、それはビルドツールに任せるというのが哲学です。

<!-- DMD 2.079.0 [changes the game](https://dlang.org/changelog/2.079.0.html#includeimports). Now, the above example can be compiled and linked like so: -->

DMD 2.079.0は[流れを一変させます](https://dlang.org/changelog/2.079.0.html#includeimports)。
上の例は以下のようにコンパイル・リンクできます:

```
dmd -i hello.d
```

<!-- The `-i` switch tells the compiler to treat imported modules as if they were passed on the command line. It can be limited to specific modules or packages by passing a module or package name, and the same can be excluded by preceding the name with a dash, e.g.: -->

`-i`スイッチはインポートされたモジュールをコマンドラインに渡されたかのように扱うようコンパイラに指示します。
これはモジュールまたはパッケージ名を渡すことで指定のモジュールやパッケージに制限でき、同様にダッシュを先頭につけることで除外できます:


```
dmd -i=foo -i=-foo.bar main.d
```

<!-- Here, any imported module whose fully-qualified name starts `foo` will be compiled, unless the name starts with `foo.bar`. By default, `-i` means to compile all imported modules except for those from Phobos and DRuntime, i.e.: -->

この場合、完全修飾名が`foo`で始まるモジュールが、`foo.bar`で始まるものを除きコンパイルされます。
デフォルトでは、`-i`はインポートされたモジュールのうちPhobosとDRuntime以外すべてをコンパイルします。
つまり:

```
-i=-core -i=-std -i=-etc -i=-object
```

<!-- While this is no substitute for a full on build tool, it makes quick tests and programs with no complex configuration requirements much easier to compile. -->

ビルドツールを完全に置き換えるものではありませんが、クイックテストや複雑な設定の必要ないプログラムが簡単にコンパイルできるようになります。

<!-- ### The #dbugfix Campaign -->

### #dbugfix キャンペーン

<!-- On a related note, last month I announced the [**#dbugfix** Campaign](https://dlang.org/blog/2018/02/03/the-dbugfix-campaign/). The short of it is, if there’s a [D Bugzilla issue](https://issues.dlang.org/) you’d really like to see fixed, tweet the issue number along with **#dbugfix**, or, if you don’t have a Twitter account or you’d like to have a discussion about the issue, make a post in [the General forum](https://forum.dlang.org/group/general) with the issue number and **#dbugfix** in the title. The core team will commit to fixing at least two of those issues for a subsequent compiler release. -->

関連事項として、先月私は[**#dbugfix** キャンペーン](https://dlang.org/blog/2018/02/03/the-dbugfix-campaign/)をアナウンスしました。
簡単に言うと、修正してほしい[D Bugzilla issue](https://issues.dlang.org/)があるなら、issue番号を**#dbugfix**をつけてツイートするか、
Twitterアカウントを持っていない、またはissueについて議論したい場合は[総合フォーラム](https://forum.dlang.org/group/general)にissue番号と**#dbugfix**をタイトルに入れて投稿する、というものです。
コアチームはその後のコンパイラのリリースで、それらのissueのうち少なくとも2つを修正するためにコミットします。

<!-- Normally, I’ll collect the data for the two months between major compiler releases. For the initial batch, we’re going three months to give people time to get used to it. I anticipated it would be slow to catch on, and it seems I was right. There were a few issues tweeted and posted in the days after the announcement, but then it went quiet. So far, this is what we have: -->

通常、私はメジャーコンパイラリリースの2ヶ月前からデータを集めます。
最初は3ヶ月なれる期間を用意していました。
私はそれは流行るのにはおそすぎると予想しており、どうやら正しかったようです。
アナウンスの数日後少しissueがツイート・投稿され、その後静かになりました。
これまでのところ受け取っているものです:

*   [Issue #1983](https://issues.dlang.org/show_bug.cgi?id=1983)
*   [Issue #2043](https://issues.dlang.org/show_bug.cgi?id=2043)
*   [Issue #5227](https://issues.dlang.org/show_bug.cgi?id=5227)
*   [Issue #16189](https://issues.dlang.org/show_bug.cgi?id=16189)
*   [Issue #17957](https://issues.dlang.org/show_bug.cgi?id=17957)
*   [Issue #18068](https://issues.dlang.org/show_bug.cgi?id=18068)
*   [Issue #18147](https://issues.dlang.org/show_bug.cgi?id=18147)
*   [Issue #18353](https://issues.dlang.org/show_bug.cgi?id=18353)

<!-- DMD 2.080.0 is scheduled for release just as [DConf 2018](http://dconf.org/2018/index.html) kicks off. The cutoff date for consideration during this run will be the day the 2.080.0 beta is announced. That will give our bugfixers time to consider which bugs to work on. I’ll include the tally and the issues they select in the DMD release announcement, then they will work to get the fixes implemented and the PRs merged in a subsequent release (hopefully 2.081.0). When 2.080.0 is released, I’ll start collecting **#dbugfix** issues for the next cycle. -->

DMD 2.080.0は[DConf 2018](http://dconf.org/2018/index.html)が始まるころに予定されています。
考慮する締切日は2.080.0ベータがアナウンスされる頃です。
これによってバグ修正者がどれに取り掛かるか考える時間ができます。
私は集計と選ばれたissueをDMDのリリースのアナウンスメントに含め、バグ修正者は修正の実装に取り掛かり以降のリリース(できれば2.081.0)でPRをマージします。
2.080.0がリリースされると、**#dbugfix** issueをまた次のサイクルのために収集します。

<!-- So if there’s an issue you want fixed that isn’t on that list above, put it out there with **#dbugfix**! Also, don’t be shy about retweeting **#dbugfix** issues or **+1**’ing them in the forums. This will add weight to the consideration of which ones to fix. And remember, include an issue number, otherwise it isn’t going to count! -->

上のリストにないけれど修正してほしいissueがあれば、**#dbugfix**に投稿してください!
また、**#dbugfix**issueをリツイートしたり、フォーラムで**+1**するのもいいでしょう。
それらは考慮されます。
そして、issue番号を含めるのも忘れないでください。
でないとカウントされません!