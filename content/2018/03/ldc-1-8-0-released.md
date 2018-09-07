---
date: 2018-03-10
aliases:
- /2018/03/10/ldc-1-8-0-released.html
title: "LDC 1.8.0 Released【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: Co-maintainerのDavid NadlingerがDConf 2013のトークで話したように、 LDC、LLVMバックエンドを使ったD言語コンパイラはここ十数年活発に開発されてきました。 GCCバックエンドを使いGCCへ追加された GDCと合わせてDの2大プロダクションコンパイラだと考えられています。
---

この記事は、
[DCompute: Running D on the GPU – The D Blog](https://dlang.org/blog/2017/10/30/d-compute-running-d-on-the-gpu/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
何か気になるところがあれば
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

<!-- ![](https://i1.wp.com/dlang.org/blog/wp-content/uploads/2017/07/ldc.png?resize=160%2C160)LDC, the D compiler using [the LLVM backend](https://llvm.org), has been actively developed for going on a dozen years, as laid out by co-maintainer David Nadlinger in [his DConf 2013 talk](http://youtube.com/watch?v=ntdKZWSiJdY). It is considered one of two production compilers for D, along with [GDC](https://www.gdcproject.org), which uses the gcc backend and [has been accepted for inclusion into the gcc tree](https://www.phoronix.com/scan.php?page=news_item&px=GCC-D-Language-Approved). -->

<img src="/assets/2018/03/ldc.png" align="left" alt="ldc">

Co-maintainerのDavid Nadlingerが[DConf 2013のトーク](http://youtube.com/watch?v=ntdKZWSiJdY)で話したように、
LDC、[LLVMバックエンド](https://llvm.org)を使ったD言語コンパイラはここ十数年活発に開発されてきました。
GCCバックエンドを使い[GCCへ追加された](https://www.phoronix.com/scan.php?page=news_item&px=GCC-D-Language-Approved)
[GDC](https://www.gdcproject.org)と合わせてDの2大プロダクションコンパイラだと考えられています。

<!-- The LDC developers are proud to announce the release of version 1.8.0, following [a short year and a half from the 1.0 release](https://dlang.org/blog/2016/06/20/making-of-ldc-1-0/). This version integrates version 2.078.3 of the D front-end (see the [DMD 2.078.0 changelog](https://dlang.org/changelog/2.078.0.html) for the important front-end changes), which is itself written in D, making LDC one of the most prominent mixed D/C++ codebases. You can download LDC 1.8.0 and [read about the major changes and bug fixes](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0) for this release at GitHub. -->

[1.0のリリースからはや1年と半年](https://dlang.org/blog/2016/06/20/making-of-ldc-1-0/)、LDCデベロッパーはバージョン1.8.0のリリースをアナウンスします。
このバージョンはDのフロントエンドのバージョン2.078.3を組み込んでおり(主なフロントエンドの変更については[DMD 2.078.0のチェンジログ](https://dlang.org/changelog/2.078.0.html)を見てください)。
フロントエンドはDそれ自身で書かれており、LDCはD/C++のミックスされたコードベースの中でも特に著名なものの一つです。
GitHubからLDC 1.8.0のダウンロードとこのリリースの[主要な変更とバグフィックスについて読む](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0)ことができます。

<!-- ### More platforms -->

### より多くのプラットフォーム

<!-- Kai Nacke, the other LDC co-maintainer, [talked at DConf 2016 about taking D everywhere](https://dconf.org/2016/talks/nacke.html), to every CPU architecture that LLVM supports and as many OS platforms as we can. LDC is a cross-compiler: the same program can compile code for different platforms, in contrast to [DMD](https://dlang.org/download) and [GDC](https://gdcproject.org/downloads), where a different DMD/GDC binary is needed for each platform. Towards that end, this release continues the existing Android cross-compilation support, which was introduced with LDC 1.4. A native LDC compiler _to both build and run D apps on your Android phone_ is also available for [the Termux Android app](https://termux.com/). See the wiki page for [instructions on how to use](https://wiki.dlang.org/Build_D_for_Android) one of the desktop compilers or the native compiler to compile D for Android. -->

もう一人のLDCのCo-maintainerであるKai Nackeはあらゆるところで、LLVMのサポートするあらゆるCPUアーキテクチャで、できるだけ多くのOSプラットフォームで動くDについて[話しました](https://dconf.org/2016/talks/nacke.html)。
LDCはクロスコンパイラです。
同じプログラムで異なるプラットフォームに向けてコードをコンパイルできます。
対して[DMD](https://dlang.org/download)や[GDC](https://gdcproject.org/downloads)は各プラットフォーム向けに異なるバイナリが必要です。
この目標に向けて、このリリースはLDC 1.4で導入されたAndroidクロスコンパイルのサポートを継続しています。
**AndroidフォンでDのアプリケーションをビルド、実行するための**ネイティブLDCコンパイラが[Termux Android app](https://termux.com/)でも利用できます。
Android向けにDをコンパイルするためのデスクトップコンパイラやネイティブコンパイラの[使い方のインストラクション](https://wiki.dlang.org/Build_D_for_Android)のWikiページを見てください。

<!-- The LDC team has also been putting out LDC builds for ARM boards, such as the Raspberry Pi 3. [Download the armhf build](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0) if you want to try it out. Finally, some developers have expressed interest in using D for microservices, which usually means running in an Alpine container. This release also comes with an Alpine build of LDC, using the just-merged Musl port by @yshui. This port is brand new. Please try it out and let us know how well it works. -->

LDCチームはLDCでRaspberry Pi 3のようなARMボード向けのビルドができるように取り組んでもいます。
試してみたい人は[armhfビルドをダウンロードしてください](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0)。
そして最後に、いくらかのデベロッパーはDをマイクロサービスで使う、つまり通常の意味ではAlpineコンテナで実行することに興味を示しています。
このリリースも、@yshuiによるMuslポートをマージしたLDCのAlpineビルドができます。
このポートはできたばかりです。
ぜひ試してみて改善点を教えてください。

<!-- ### Linking options – shared default libraries -->

### リンクオプション – 共有デフォルトライブラリ

<!-- LDC now makes it easier to link with the shared version of the default libraries (DRuntime and the standard library, called Phobos) through the `-link-defaultlib-shared` compiler flag. The change was paired with a rework of linking-related options. See the new help output: -->

デフォルトライブラリ(DRuntimeとPhobosと呼ばれる標準ライブラリ)の共有ライブラリバージョンのリンクがLDCでは`-link-defaultlib-shared`コンパイラフラグによって簡単になります。
この変更はリンク関連のオプションの作り直しと密接に関わっています。
新しいヘルプの出力を見てください:

<!-- Linking options: -->

リンクオプション(訳注: 説明文は訳されており、実際の出力とは異なる):

<!-- ```
Linking options:

-L= - Pass to the linker
-Xcc= - Pass to GCC/Clang for linking
-defaultlib=<lib1,lib2,…> - Default libraries to link with (overrides previous)
-disable-linker-strip-dead - Do not try to remove unused symbols during linking
-link-defaultlib-debug - Link with debug versions of default libraries
-link-defaultlib-shared - Link with shared versions of default libraries
-linker=<lld-link|lld|gold|bfd|…> - Linker to use
-mscrtlib=<libcmt[d]|msvcrt[d]> - MS C runtime library to link with
-static
``` -->

```
Linking options:

-L= - リンカに渡すオプション
-Xcc= - リンクのためにGCC/Clangに渡すオプション
-defaultlib=<lib1,lib2,…> - リンクするデフォルトライブラリ(以前の値を上書きする)
-disable-linker-strip-dead - リンクの際不要なシンボルの削除を試みない
-link-defaultlib-debug - デフォルトライブラリのデバッグバージョンをリンク
-link-defaultlib-shared - デフォルトライブラリを共有ライブラリとしてリンク
-linker=<lld-link|lld|gold|bfd|…> - 使うリンカ
-mscrtlib=<libcmt[d]|msvcrt[d]> - リンクするMS C runtime library
-static
```

<!-- #### Other new options -->

#### その他新しいオプション

<!-- *   `-plugin=...` for compiling with LLVM-IR pass plugins, such as the [AFLfuzz LLVM-mode plugin](https://github.com/mirrorer/afl/blob/master/llvm_mode/afl-llvm-pass.so.cc)
*   `-fprofile-{generate,use}` for Profile-Guided Optimization (PGO) based on the LLVM IR code (instead of PGO based on the D abstract syntax tree)
*   `-fxray-{instrument,instruction-threshold}` for generating code for [XRay instrumentation](https://llvm.org/docs/XRay.html)
*   `-profile` (LDMD2) and `-fdmd-trace-functions` (LDC2) to support DMD-style profiling of programs -->

 - [AFLfuzz LLVM-mode plugin](https://github.com/mirrorer/afl/blob/master/llvm_mode/afl-llvm-pass.so.cc)のようなLLVM-IR pass pluginをコンパイルする`-plugin=...`
 - [XRay instrumentation](https://llvm.org/docs/XRay.html)用のコードを生成する`-fxray-{instrument,instruction-threshold}`
 - プログラムのDMDスタイルプロファイリングをサポートする`-profile` (LDMD2)と`-fdmd-trace-functions` (LDC2)

<!-- ### Vanilla compiler-rt libraries -->

### 通常のcompiler-rtライブラリ

<!-- LDC uses LLVM’s [compiler-rt runtime library](https://compiler-rt.llvm.org/) for [Profile-Guided Optimization (PGO)](https://en.wikipedia.org/wiki/Profile-guided_optimization), [Address Sanitizer](https://github.com/google/sanitizers/wiki/AddressSanitizer), and [fuzzing](http://johanengelen.github.io/ldc/2018/01/14/Fuzzing-with-LDC.html). When PGO was first added to LDC 1.1.0, the required portion of compiler-rt was copied to LDC’s source repository. This made it easy to ship the correct version of the library with LDC, and make changes for LDC specifically. However, a copy was needed for each LLVM version that LDC supports (compiler-rt is compatible with only one LLVM version): the source of LDC 1.7.0 has 6 (!) copies of compiler-rt’s profile library. -->

LDCはLLVMの[compiler-rt runtime library](https://compiler-rt.llvm.org/)を[プロファイルに基づく最適化(PGO)](https://en.wikipedia.org/wiki/Profile-guided_optimization)、
[アドレスサニタイザー](https://github.com/google/sanitizers/wiki/AddressSanitizer)、
[ファジング](http://johanengelen.github.io/ldc/2018/01/14/Fuzzing-with-LDC.html)のために使います。
PGOがLDC 1.1.0で初めて追加されたとき、compiler-rtの一部がLDCのソースリポジトリにコピーされました。
これによりLDCと対応した正しいバージョンでの公開と、LDCに合わせた変更が簡単にできるようになりました。
しかし、コピーはLDCのサポートするすべてのLLVMのバージョンに対して必要になります(compiler-rtはLLVMのバージョンと1対1で対応した互換性しか持ちません)。
LDC 1.7.0のソースはcompiler-rtのprofile libraryのコピーを6つ(!)持っていました。

<!-- For the introduction of ASan and libFuzzer in the official LDC binary packages, a different mechanism was used: when building LDC, we check whether the compiler-rt libraries are available in LLVM’s installation and, if so, copy them into LDC’s lib/ directory. To use the same mechanism for the PGO runtime library, we had to remove our additions to that library. Although the added functionality is rarely used, we didn’t want to just drop it. Instead, the functionality was turned into template-only code, such that it does not need to be compiled into the library (if the templated functionality is called by the user, the template’s code will be generated in the caller’s object file). -->

公式LDCバイナリパッケージへのASanとlibFuzzerの導入によって、異なる仕組みが使われるようになりました。
LDCをビルドするときに、インストール済みのLLVMがらcompiler-rtが利用できないかチェックし、利用できる場合はLDCの lib/ ディレクトリへコピーします。
同じ仕組みをPGOランタイムライブラリにも使うことで、ライブラリを削除することができました。
追加機能はまれに必要になりますが、それを切り捨てたくはありません。
かわりに、機能はすべてテンプレートコードのみで実現され、ライブラリに組み込んでコンパイルする必要をなくしました(テンプレート機能がユーザーから呼ばれた場合、テンプレートコードは呼び出し元のオブジェクトファイルに生成されます)。

<!-- With this change, LDC no longer needs its own copy of compiler-rt’s profile library and all copies were removed from LDC’s source repository. LDC 1.8.0 ships with vanilla compiler-rt libraries. LDC’s users shouldn’t notice any difference, but for the LDC team it means less maintenance burden. -->

この変更によって、LDCはcompiler-rtのprofile libraryをコピーする必要がなくなり、LDCのソースリポジトリからはすべてのコピーが削除されました。
LDC 1.8.0は通常と変わらないcompiler-rtライブラリとともに公開されています。
LDCユーザーはこの変更について何も気にすることはありませんが、LDCチームにとってはメンテナンスの負荷が下がります。

<!-- ### Onward -->

### 今後

<!-- A compiler developer’s work is never done. With this release out the door, [we march onward toward 1.9](https://github.com/ldc-developers/ldc/pull/2587). Until then, start optimizing your D programs by downloading the pre-compiled LDC 1.8.0 binaries for Linux, Mac, Windows, Alpine, ARM, and Android, or [build the compiler from source](https://wiki.dlang.org/Building_LDC_from_source) from [our GitHub repository](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0). -->

コンパイラの開発者の仕事は終わりません。
このリリースを出したあとは、[我々は1.9に向かって進んでいきます](https://github.com/ldc-developers/ldc/pull/2587)。
それまでは、Linux、Mac、Windows、Alpine、ARM、Android向けのLDC 1.8.0のコンパイル済みバイナリをダウンロードするか、[GitHubリポジトリ](https://github.com/ldc-developers/ldc/releases/tag/v1.8.0)から[コンパイラをビルドして](https://wiki.dlang.org/Building_LDC_from_source)あなたのDプログラムを最適化してください。

<!-- _Thanks to LDC contributors Johan Engelen and Joakim for coauthoring this post._ -->

LDCコントリビューターのJohan Engelenとこの記事の共著者であるJoakimに感謝します。