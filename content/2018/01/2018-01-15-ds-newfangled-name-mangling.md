---
date: 2018-01-15
title: "Dの新しい名前修飾【抄訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "D言語の短期的な設計目標の一つにCとのインターフェース能力があります。 その目標のために、Cの標準ライブラリへのアクセスを可能にし、CやC++コンパイラが使うのと同じオブジェクトファイルフォーマットとシステムリンカを使うABI互換を提供しています。"
---

この記事は
[D’s Newfangled Name Mangling – The D Blog](https://dlang.org/blog/2017/12/20/ds-newfangled-name-mangling/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
自分の能力が微妙に届かず誤字や誤訳などが多いと思うので、気になったら
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})
を投げつけてくれると喜ぶ。

---

<!-- _Rainer Schuetze is the creator and maintainer of [Visual D](http://rainers.github.io/visuald/visuald/StartPage.html), the D plugin for Visual Studio. Recently, he implemented a new name mangling algorithm for the D frontend, which was released in [DMD 2.077.0](https://dlang.org/changelog/2.077.0.html). In this post, he explains why it was needed and what it does._ -->

Rainer SchuetzeはVisual StudioのD言語プラグイン、[Visual D](http://rainers.github.io/visuald/visuald/StartPage.html)の作者でありメンテナーです。
最近、彼は[DMD 2.077.0](https://dlang.org/changelog/2.077.0.html)でリリースされたDの新しい名前修飾アルゴリズムを実装しました。
この投稿では、何故それが必要で、どのように行われるのかを説明します。

---

<!-- ### What is symbol name mangling? -->

### シンボル名修飾とは何か？

<!-- ![](https://i2.wp.com/dlang.org/blog/wp-content/uploads/2016/08/d6.png?resize=200%2C200) -->

<!-- D embraces the separate compilation model that compiles D source code to object files and uses a linker to bind the object files to an executable binary file. This allows the reuse of precompiled object files and libraries, speeding up the build process. As the linker is usually one that’s also used for other languages with the same compilation model, e.g. C/C++ or Fortran, mixing object files from different languages is straightforward. -->

Dはソースコードをオブジェクトファイルにコンパイルし、リンカを使いオブジェクトファイルを実行可能バイナリファイルにまとめるという分割コンパイルモデルを採用しています。
これによって以前にコンパイルされたオブジェクトファイルやライブラリを再利用し、ビルドプロセスの高速化ができます。
C/C++やFortranのような同じコンパイルモデルを持つ言語でも同じリンカが使われるため、異なる言語のオブジェクトファイルを直接組み合わせられます。

<!-- In an object file, a symbol name is assigned to each function or global variable, both when it is defined and when it is used via a call or access. The linker uses these names to connect references to definitions of the same name with only very bare knowledge about the symbol. For example, the symbol for this C function declaration, -->

オブジェクトファイルのなかでは呼び出したりアクセスしたりするために定義された各関数とグローバル変数にシンボル名が割り当てられています。
リンカはそのシンボル名を利用する事で、シンボルに関する知識を持たずに同名の定義の参照をつなぎ合わせます。
たとえば、このCの関数宣言のシンボルは、

<!-- ```d
extern(C) const(char)* find(int ch, const(char)* str);
``` -->

```d
extern(C) const(char)* find(int ch, const(char)* str);
```

<!-- does not tell the linker anything about function arguments or return type, as the C language uses the plain function name `find` as the symbol name (some platforms prepend a `_` to the symbol). If you later change the order of the arguments to -->

Cがシンボル名として普通の名前 `find` を使うため（プラットフォームによってはシンボルの最初に`_`が付きます）、関数の引数や返値の型について何もリンカに伝えません。
後で引数の順番をこのとおり変えたとしても、

<!-- ```d
extern(C) const(char)* find(const(char)* str, int ch);
``` -->

```d
extern(C) const(char)* find(const(char)* str, int ch);
```

<!-- but fail to update and recompile all source files that use the new declarartion, the linker will happily bind the resulting object files. In that case, the program is likely to crash, since a character passed to the function will be interpreted as a string pointer and vice versa. -->

更新と新しい宣言を使うすべてのソースファイルの再コンパイルは行われず、リンカはそのオブジェクトファイルを幸運なことにもくっつけてしまいます。
この場合、関数に渡されたキャラクタが文字列ポインタとして解釈され、逆も同じように解釈されてしまうため、たぶんプログラムはクラッシュします。

<!-- D and C++ avoid this problem by adding more information to the symbol name, i.e. they encode into a symbol name the scope in which the symbol is defined, the function argument types, and the return type. Even if the linker does not interpret this information, linking fails with an _undefined symbol error_ if the definitions used to build the object files don’t match. For example, the D function declaration -->

DやC++はこの問題を回避するためシンボル名に情報を追加します。
つまり、シンボルが定義されたスコープ、関数の引数や返り値の型をシンボル名にエンコードします。
リンカは相変わらずこの情報を解釈しませんが、オブジェクトファイルのビルドに使われる宣言が一致しない場合、リンクは未定義シンボルエラーで失敗します。
たとえば以下のDの関数宣言は

<!-- ```d
module test;

extern(D) const(char)* find(int ch, const(char)* str);
``` -->

```d
module test;

extern(D) const(char)* find(int ch, const(char)* str);
```

<!-- has a symbol name `_D4test4findFiPxaZPxa`, where `_D` is a prefix to identify the symbol as being generated from a D source symbol, `4test4find` encodes the “fully qualified name” `find` in module `test`, and `FiPxaZPxa` describes the function type with an integer argument (designated by `i`) and the C-style string pointer type `Pxa` by just concatenating the encodings for argument types. `Z` terminates the function argument list and is followed by the encoding for the return type, again `Pxa` for a C-style string pointer. In contrast, -->

`_D4test4findFiPxaZPxa`というシンボル名になります。
`_D`はDのソースのシンボルから生成されたシンボルを識別するプレフィックス、`4test4find`は`test`モジュールの`find`が「完全修飾名」にエンコードされたもの、`FiPxaZPxa`は整数引数（`i`と呼ばれます）とCスタイルの文字列ポインタ型`Pxa`を単に繋げた引数の型のエンコーディングです。
`Z`で関数の引数リストを終わらせて、返り値の型が後に続き、それはCスタイル文字列ポインタの`Pxa`です。
一方、

<!-- ```d
extern(D) const(char)* find(const(char)* str, int ch);
``` -->

```d
extern(D) const(char)* find(const(char)* str, int ch);
```

<!-- is encoded as `_D4test4findFPxaiZPxa`, making it a different symbol with the argument types reversed. The encoding ensures a normalized representation of types and scopes while also providing shorter symbols than minimal source code. This encoding is called “name mangling”. -->

は引数の型が逆になっているところが異なる `_D4test4findFPxaiZPxa`にエンコードされます。
エンコーディングは型とスコープの表現をノーマライズし、最小限のソースコードよりも短いシンボルを提供します。
このエンコーディングが「名前修飾」と呼ばれます。

<!-- _Ed: Note that `extern(C)` and `extern(D)` are [linkage attributes](https://dlang.org/spec/attribute.html#linkage). When a function is declared in D without an explicit linkage attribute, `extern(D)` is the default._ -->

_資料: `extern(C)`や`extern(D)`は[リンケージ属性](https://dlang.org/spec/attribute.html#linkage)です。
Dにおいて関数が明示的なリンケージ属性なしで宣言される時、`extern(D)`がデフォルトになります。_

<!-- In D, some function attributes are also mangled into the symbol name, e.g. `@safe`, `nothrow`, `pure` and `@nogc`. In theory, mangling could also cover parameter names, [user defined attributes](https://dlang.org/spec/attribute.html#UserDefinedAttribute), or even [contracts](https://dlang.org/spec/contracts.html), but that is currently considered excessive. -->

Dでは`@safe`、`nothrow`、`pure`、`@nogc`のような関数の属性のいくつかはシンボル名へと修飾されます。
理屈の上ではパラメータ名、[ユーザ定義属性](https://dlang.org/spec/attribute.html#UserDefinedAttribute)、[契約](https://dlang.org/spec/contracts.html)を修飾に含めることもできますが、いまのところそれは過剰だと考えられています。

<!-- Please note that even though name mangling can detect some mismatches in the binary interface of functions (i.e. how arguments are passed in registers or on the stack), it won’t catch every error; for example, structs, classes and other user defined types are mangled by name only, so that a change to their definition will still pass unnoticed by the linker. -->

名前修飾が関数のバイナリインタフェース（引数がレジスタやスタックにどのように渡されるかなど）の不一致を検知したとしても、エラーはキャッチされないことに注意してください。
たとえば構造体、クラス、その他ユーザ定義型はその名前のみが修飾され、その定義の変更をリンカは検知しません。

<!-- The mangled name of a symbol is also available during compilation using the `.mangleof` property. This used to be exploited to provide type reflection of the symbol at compile time. This should no longer be necessary due to the introduction of new [`__traits`](https://dlang.org/spec/traits.html) that make this information accessible faster and more convenient, for example, -->

シンボルの修飾名は`.mangleof`プロパティからコンパイル時に利用することもできます。
これはコンパイル時にシンボルの型リフレクションをするために活用されていました。
これは情報により速く、便利にアクセスできる新しい[`__traits`](https://dlang.org/spec/traits.html)の導入により不要になりました。
たとえば、

<!-- ```d
__traits(getLinkage,symbol);
``` -->

```d
__traits(getLinkage,symbol);
```

<!-- or -->

または

<!-- ```d
__traits(getFunctionAttributes, symbol);
``` -->

```d
__traits(getFunctionAttributes, symbol);
```

<!-- Thus, usage of `.mangleof` is not recommended except for debugging purposes. -->

従って、`.mangleof` の使用はデバッグ用途を除き推奨されません。

<!-- When reversing the mangling process in the “demangler”, all the encoded information is kept to make it available to the user, but that does not always yield correct D syntax. The first definition above demangles as -->

"demangler（逆修飾器）"で修飾プロセスを逆回しして、エンコードされたすべての情報をユーザが利用できる形にしたとしても、それは必ずしも正しいDのシンタックスになりません。
上で取り上げた最初の宣言は以下のように逆修飾されます。

<!-- ```d
const(char)* test.find(int, const(char)*)
``` -->

```d
const(char)* test.find(int, const(char)*)
```

<!-- i.e. the module name `test` is added to the function name. -->

モジュール名`test`が関数名に足されています。

<!-- ### Template symbols -->

### テンプレートシンボル

<!-- The two definitions of `find` shown above can coexist in D and C++, so name mangling is not only a way to detect errors at link time but also a necessity to represent overloads. It should at least contain enough information to distinguish different overloads of the same scoped identifier. -->

上の2つの`find`の定義はDとC++両方に存在できるもののため、名前修飾以外にもリンク時にエラーを検出する方法がありますが、オーバーロードを表現する必要もあります。
そのため少なくとも同じスコープの識別子の異なるオーバーロードを識別するために必要な情報を含む必要があります。

<!-- This becomes even more obvious when considering templates that usually instantiate different functions or variable definitions for each argument type. In D, the template instantiation information is added to the qualified name of a symbol. -->

これは通常引数の型ごとに異なる関数や変数の定義をインスタンス化するテンプレートのことを考えてみても明らかなことです。
Dでは、テンプレートのインスタンス化の情報はシンボルの修飾名に追加されます。

<!-- Consider expression templates, a common example of meta programming used for delayed evaluation of expressions: -->

式テンプレートは、式の遅延評価を使うメタプログラミングの一般的な例です:

<!-- 
```d
module expr;

struct Mul(X,Y)

{

    X x;

    Y y;

}

struct Add(X,Y)

{

    X x;

    Y y;

}

auto mul(X,Y)(X x, Y y) { return Mul!(X,Y)(x, y); }

auto add(X,Y)(X x, Y y) { return Add!(X,Y)(x, y); }

``` -->

```d
module expr;

struct Mul(X,Y)

{

    X x;

    Y y;

}

struct Add(X,Y)

{

    X x;

    Y y;

}

auto mul(X,Y)(X x, Y y) { return Mul!(X,Y)(x, y); }

auto add(X,Y)(X x, Y y) { return Add!(X,Y)(x, y); }

```

<!-- A function template is lowered by the compiler to [an eponymous template](https://dlang.org/spec/template.html#implicit_template_properties): -->

関数テンプレートはコンパイラによって[冠名テンプレート](https://dlang.org/spec/template.html#implicit_template_properties)に書き下されます:

<!-- 
```d
template mul(X, Y)

{

    auto mul(X x, Y y) { return Mul!(X,Y)(x, y); }

}
``` -->

```d
template mul(X, Y)

{

    auto mul(X x, Y y) { return Mul!(X,Y)(x, y); }

}
```

<!-- The template name is part of the qualified function name, `expr.mul!(X,Y).mul`, and the auto return type is inferred to be `Mul!(X,Y)`. This causes the symbol to reference the types `X` and `Y` three times. The demangled mangled name of an instantiation with types `double` and `float` of this template is -->

テンプレート名は修飾関数名`expr.mul!(X,Y).mul`の一部となり、auto返値型は推論され`Mul!(X,Y)`になります。
これによりシンボルは型`X`と`Y`を3回参照します。
このテンプレートを型`double`と`float`でインスタンス化したものの修飾名を逆修飾するとこのようになります。

<!-- ```d
expr.Mul!(double,float) expr.mul!(double,float).mul(double,float)
``` -->

```d
expr.Mul!(double,float) expr.mul!(double,float).mul(double,float)
```

<!-- The mangling process of DMD before version 2.077 walks the abstract syntax tree of the declaration and emits the mangled representation of the types whenever it is hit. Now consider stacking operations, e.g. -->

バージョン2.077以前のDMDの修飾プロセスは宣言の抽象構文木をたどり、遭遇したすべての型の修飾表現を出力します。
以下のような積み重ね操作を考えてみましょう。

<!-- 
```d
auto square(X)(X x) { return mul(x, x); }

auto len = square("var");

pragma(msg, len.square.mangleof);

// S4expr66__T3MulTS4expr16__T3MulTAyaTAyaZ3MulTS4expr16__T3MulTAyaTAyaZ3MulZ3Mul

pragma(msg, typeof(len).mangleof.length);

pragma(msg, len.square.mangleof.length);

pragma(msg, len.square.square.mangleof.length);

pragma(msg, len.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.square.square.mangleof.length);
``` -->

```d
auto square(X)(X x) { return mul(x, x); }

auto len = square("var");

pragma(msg, len.square.mangleof);

// S4expr66__T3MulTS4expr16__T3MulTAyaTAyaZ3MulTS4expr16__T3MulTAyaTAyaZ3MulZ3Mul

pragma(msg, typeof(len).mangleof.length);

pragma(msg, len.square.mangleof.length);

pragma(msg, len.square.square.mangleof.length);

pragma(msg, len.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.square.mangleof.length);

pragma(msg, len.square.square.square.square.square.square.mangleof.length);
```

<!-- With DMD 2.076 or earlier, this displays `28u, 78u, 179u, 381u, 785u, 1594u, 3212u`, showing exponential growth of the mangled symbol name length even though the expression in the source code just grows linearly. This happens because types like `Mul!(Mul!(string, string), Mul!(string, string))` are combined and the mangling repeats their full representation every time they are referenced. -->

DMD 2.076以前では、これは`28u, 78u, 179u, 381u, 785u, 1594u, 3212u`という、ソースコード内の式が線形にしか増えていないのにもかかわらず加速的に増える修飾シンボル名の長さを出力します。
これは`Mul!(Mul!(string, string), Mul!(string, string))`のような型が組み合わさり、それが参照されるたびに完全な表現を繰り返し修飾するために起こる現象です。

<!-- Create a chain of 12 calls to `square` above and the symbol length increases to 207,114. Even worse, the resulting object file for COFF/64-bit is larger than 15 MB and the time to compile increases from 0.1 seconds to about 1 minute. Most of that time is spent generating code for functions only used at compile time. -->

上の`square`の呼び出しを12個繋げたものを作るとシンボルの長さは207,114まで増加します。
さらに悪いことに、生成されるCOFF/64-bitのオブジェクトファイルは15MBを超えて大きくなりコンパイル時間は0.1秒から1分ほどに増加します。
この時間のほとんどがコンパイル時にのみ使われるコードの生成に費やされます。

<!-- [Voldemort types](http://www.digitalmars.com/articles/b79.html) returned from template functions can be similar, as they carry the function signature including the template arguments as [part of the type name](https://issues.dlang.org/show_bug.cgi?id=15831). These can also show a dramatic increase in build times without generating as much code as in the example. -->

テンプレート関数から返される[ヴォルデモート型](http://www.digitalmars.com/articles/b79.html)は、[型名の一部に](https://issues.dlang.org/show_bug.cgi?id=15831)テンプレート引数を含めた関数シグネチャをもつため似たような状態になる事があります。
これも例よりも少ないコードで劇的なビルド時間の増加を見せます。

<!-- ### Symbol compression to the rescue -->

### シンボル圧縮による解決

<!-- In early 2016, a couple of attempts were made to shorten these long symbols: -->

2016年の初期に、これらの長いシンボルを短くするいくつかの試みがなされました。

<!-- *   cut off symbol names if they exceed a given threshold, but append a checksum of the full symbol instead. This was already done with an MD5 hash when emitting symbols for the DigitalMars C compiler tool chain as the OMF object file format does not allow symbols longer than 255 characters. The downside to this is that these symbols can no longer be demangled, so that symbols in linker messages cannot be translated back into human digestible names. -->

 - ある閾値を超えた時にシンボル名を切り詰め、代わりに完全なシンボルのチェックサムを追加する。
これは既に255文字以上のシンボルを受け付けないOMFオブジェクトファイルフォーマットのDigitalMars Cコンパイラツールチェインのためにシンボルを出力する際にMD5ハッシュを用いて行われています。
これの欠点はシンボルが逆修飾できなくなってしまい、リンカメッセージのシンボルが人間に理解できる名前に変換できなくなる事です。

<!-- *   apply binary compression to the symbol name. Standard techniques use part of the full symbol name as a dictionary to encode repetitions within the name. This is usually done by encoding a position-length pair using characters outside the normal identifier set. Again, this is already in use when DMD tries to fit symbols into the OMF limit of 255 characters (before applying the MD5 hash trick), but it also has shown some disadvantages: when using characters above the ASCII range, this interferes with UTF8 encoded characters that are also allowed as symbol characters in the D language. It can also break linker output as the console might misinterpret it as a locale-specific character encoding. Avoiding this by applying a binary to ASCII conversion like base64 to the symbols would obfuscate the actual symbol name even more. -->

 - シンボル名にバイナリ圧縮を適用する。
完全なシンボル名の一部を辞書として、名前のなかの繰り返しをエンコードするスタンダードなやりかたです。
これは通常の識別子セットに無い文字を使って位置と長さのペアをエンコードすることにより通常行われます。
さらに、これは既にDMDがシンボルをOMFの225文字制限に合わせようとする際に（MD5ハッシュを適用する前に）使われていますが、これにもディスアドバンテージがあります。
ASCIIの範囲を超えた文字を使うとき、これはD言語のシンボル文字列として許容されるUTF8でエンコードされた文字と干渉します。
また、コンソールがロケール特有のの文字エンコーディングと間違えてしまうことによってリンカの出力を壊してしまう可能性があります。
これを回避するためにシンボルにbase64のようなバイナリからASCIIへの変換をかけてしまうと実際のシンボル名がますますわかりづらくなります。

<!-- *   extend [the mangling grammar](https://dlang.org/spec/abi.html#name_mangling) by allowing references to entities already encoded. This is similar to binary compression, but does not need to encode match length as the entities have terminators embedded into the grammar. The most prominent entities are types. This is the road C++ has taken, as it is also affected by the issues described here. In C++, name mangling is not standardised by the language, but by the compiler or the platform. GNU g++ uses [Itanium C++ ABI mangling](https://itanium-cxx-abi.github.io/cxx-abi/abi.html#mangling), which does a pretty good job with C++ code similar to the example above or in the [Voldemort issue](https://issues.dlang.org/show_bug.cgi?id=15831). Even though Microsoft’s Visual C++ can encode recurring types as well, it still generates very long names because it limits the encoding to the first 10 types of an argument list. -->

 -  [修飾構文](https://dlang.org/spec/abi.html#name_mangling)を拡張して既にエンコードされたエンティティへの参照をできるようにする。
バイナリ圧縮と似ていますが、エンティティに構文組み込みの終端子があるので長さのエンコードが不要です。
最も重要なエンティティは型です。
これはここで説明する問題に影響するためC++が選んだ道です。
C++は名前修飾を標準化しておらず、コンパイラやプラットフォームが決めています。
GNU g++は[Itanium C++ ABI mangling](https://itanium-cxx-abi.github.io/cxx-abi/abi.html#mangling)を使っており、これはC++における上の例や[ヴォルデモート問題](https://issues.dlang.org/show_bug.cgi?id=15831)のようなコードに対してうまく動作します。
MicrosoftのVisual C++も繰り返し出現する型をエンコードできますが、引数リストの最初の10個の型までにエンコーディングを制限しているため非常に長い名前を生成します。

<!-- The first attempts at applying the latter scheme to the mangling of D symbols showed disappointing results. As it turned out, these implementations missed a subtle detail of the [mangler in the DMD front end](https://github.com/dlang/dmd/blob/master/src/dmd/dmangle.d) at that time; it reused cached representations of mangled type names to combine them to more complex types. This fails to find repetitions of the types from which a cached type name was built. -->

Dのシンボルの修飾に後者の案を適用した上での最初の試みは残念な結果に終わりました。
結局、当時のそれらの実装は[DMDフロントエンドの修飾器](https://github.com/dlang/dmd/blob/master/src/dmd/dmangle.d)の、キャッシュした修飾型名の表現を組み合わせてより複雑な型を作るために再利用しているという小さな特徴を見逃していました。
これによりキャッシュされた型名から繰り返しを探す事ができないでいました。

<!-- This is where I stepped in to create a proof-of-concept version of the mangling [without these omissions](https://github.com/dlang/dmd/pull/5855). Early results [were promising](https://issues.dlang.org/show_bug.cgi?id=15831#c7), so I looked for more opportunities to reduce symbol length: -->

この時私は[それらの抜け](https://github.com/dlang/dmd/pull/5855)を廃した修飾の実証バージョンを作り始めました。
初期の結果は[期待できるもので](https://issues.dlang.org/show_bug.cgi?id=15831#c7)、私はシンボルの長さをさらに削減できないか探求しました:

<!-- *   with fully qualified names always containing the package and module names of a symbol, identifiers tend to appear often in a mangled name. -->

 - 完全修飾名は常にパッケージやモジュールの名前を含み、識別子は修飾名に繰り返し現れる傾向があります。

<!-- *   qualified names are likely to come from the same module or package, so it would be nice to encode them as a single entity. -->

 - 修飾名は同じモジュールまたはパッケージから来ることが多いので、1エンティティにエンコードするといい結果をもたらします。

<!-- The unit tests of [the Phobos runtime library](https://dlang.org/phobos/index.html) are benchmark candidates, as they contain a lot of symbols for template-heavy code. At the given time there were 127,172 symbols found in the map file of the Windows build. These were the results of the different manglings: -->

[Phobosランタイムライブラリ](https://dlang.org/phobos/index.html)のユニットテストはテンプレートをヘビーに使うコードのシンボルをたくさん含むため、それをユニットテスト候補としました。
Windowsのビルドのマップファイルでは、計測時点で127,172のシンボルが見つかりました。
これが異なる修飾法での結果です:

<!-- | back references | max length | average length |
|-----------------------------------|------------|----------------|
| none | 416133 | 369 |
| types | 2095 | 157 |
| types+identifiers | 1263 | 128 |
| types+identifiers+qualified names | 1114 | 117 | -->

| 後方参照 | 最大長 | 平均長 |
|-----------------------------------|------------|----------------|
| 何もなし | 416133 | 369 |
| 型 | 2095 | 157 |
| 型+識別子 | 1263 | 128 |
| 型+識別子+修飾名 | 1114 | 117 |

<!-- (This has been measured with the implementation at the time, which is not exactly the same as the final mangling; it used special characters for the different back reference types, but this turned out not to be a good idea. The D mangling is supposed to be the same on all platforms, but these characters will have a special meaning to the linker on one of them.) -->

（これは現時点の実装で計測したもので、最終的な修飾法と一緒にはならないかもしれません。
後方参照型に特殊文字を使いましたが、これはいい考えではありませんでした。
Dの修飾はすべてのプラットフォームで同じであると仮定していましたが、いくつかのプラットフォームでその文字は特殊な意味を持っていました。）

<!-- It’s rather simple in DMD to determine the identity of identifiers and types, as the latter are merged according to their mangling anyway. Qualified names and their associated symbols turned out to introduce a number of complications, though. Namely, `mangleFunc` in `core.demangle` allows building a mangled name of a function from a fully qualified name given as a `string` function argument and a type specified as a template argument. Implementing this for run-time usage requires copying the full mangling machinery and introspection capabilities of the compiler, which is unrealistic. Considering the limited benefit shown by the above Phobos statistics, the idea of encoding qualified names was dropped. -->

DMDにおいて識別子と型の区別は、後者が修飾に従ってマージされるためかなり簡単です。
それでも修飾名とそれに関連したシンボルはさまざまな問題を生み出しました。
関数引数の`string`として与えられた完全修飾名と、テンプレート引数で指定された型から関数の修飾名を構築する`core.demangle`の`mangleFunc`です。
これを実行時用に実装するには完全な修飾機構とイントロスペクション機能のコピーが必要で、それは現実的ではありません。
上のPhobosの統計が示す限られた利益を考えた結果、修飾名のエンコードのアイデアは却下されました。

<!-- Here are some details about the new mangling: -->

新しい修飾法についてまとめると:

<!-- *   Back references are now encoded by the character `Q`, followed by the relative position of the original appearance of the same identifier or type. These positions are encoded with respect to base 26, with the last digit encoded by a lowercase letter and the other digits encoded by an uppercase letter. That way, most back references are 2 or 3 characters long, 4 in extreme cases. Using a different encoding for the last digit allows determining the end of a number without looking at the next character. This helps to avoid ambiguities. (The Itanium C++ ABI mangling uses base 36 encoding by combining numbers and letters, but need a termination character `_`.) -->

 - 後方参照は文字列`Q`でエンコードされ、同じ識別子や型の元の出現箇所の相対位置が続きます。
これらの位置は最後の桁を小文字、それ以外の桁を大文字でエンコードするbase 26を参考にエンコードされます。
そうすることで、ほとんどの後方参照は2、3文字になり、4文字になることは稀です。
最後の桁だけ異なる形式にすることで次の文字を見ずに数値の終わりを識別できます。
これによって曖昧さがなくなります。
（Itanium C++ ABI修飾では、数字と文字を組み合わせて終端文字`_`を使うbase 36を使います。）

<!-- *   Counting encodable entities as in the C++ mangling would result in slightly shorter mangled names, but needs the mangler to keep a dynamic list of respective positions. The current demangler is designed not to allocate as long as the supplied output buffer is large enough. -->

 - C++の修飾をエンコード可能なエンティティとして数えると修飾名が少し短くなりますが、修飾器がそれぞれの位置の動的リストを持ち続けなければならなくなります。
現在の逆修飾器は十分な大きさの出力バッファをアロケートするようにはできていません。

<!-- *   Relative positions are chosen instead of absolute positions to allow prepending the `_D` prefix without having to re-encode the symbol. Some platforms also prepend an additional underscore, for which the relative positions are agnostic. -->

 - シンボルの再エンコードなしに`_D`プレフィックスを追加するために絶対位置ではなく相対位置が選ばれました。
プラットフォームによってはアンダースコアが多かったりしますが、相対位置なら関係ありません。

<!-- *   The mangling grammar sometimes allows types and identifiers at the same position, so a demangler needs to distinguish between the two even if given by a back reference. That’s why a lookup to the referenced position is necessary to continue demangling; an identifier always starts with a number, while a type always starts with a letter. -->

 - 修飾構文は型と識別子が同じ場所にあるのを許容するため、逆修飾器はそれが後方参照であっても2つを区別する必要があります。
そのため参照位置のルックアップが逆修飾の際に必要となります。
識別子は常に数値から始まり、型は常に文字から始まります。

<!-- *   Using `Q` for back references grabs the last free letter used to encode types, but there is at least one type defined in the mangling grammar that is not supposed to appear in a mangling anyway (namely `TypeIdent`), so it can be resurrected if the necessity appears. -->

 *   Using `Q` for back references grabs the last free letter used to encode types, but there is at least one type defined in the mangling grammar that is not supposed to appear in a mangling anyway (namely `TypeIdent`), so it can be resurrected if the necessity appears. [^1]

[^1]: ここ意味が取れなかった

<!-- For example, the expression template type shown above now mangles as -->

たとえば、上の式テンプレート型は以下のように修飾されます。

<!-- ```d
pragma(msg, len.square.mangleof);
// S4expr__T3MulTSQo__TQlTAyaTQeZQvTQtZQBb
//                ^^   ^^     ^^ ^^ ^^ ^^^ decode to:
//                |    |      |  |  |  |
//                |    |      |  |  |  +- 3Mul
//                |    |      |  |  +---- S4expr__T3MulTAyaTAyaZ3Mul
//                |    |      |  +------- 3Mul
//                |    |      +---------- Aya
//                |    +----------------- 3Mul
//                +---------------------- 4expr
``` -->

```d
pragma(msg, len.square.mangleof);
// S4expr__T3MulTSQo__TQlTAyaTQeZQvTQtZQBb
//                ^^   ^^     ^^ ^^ ^^ ^^^ decode to:
//                |    |      |  |  |  |
//                |    |      |  |  |  +- 3Mul
//                |    |      |  |  +---- S4expr__T3MulTAyaTAyaZ3Mul
//                |    |      |  +------- 3Mul
//                |    |      +---------- Aya
//                |    +----------------- 3Mul
//                +---------------------- 4expr
```

<!-- with a length of 39 instead of 78 without back references. The resulting sizes are 23, 39, 57, 76, 95, 114, 133 showing linear growth. The chain of 12 calls to `square` shrinks from 207,114 characters to 247, i.e. by a factor of more than 800. -->

長さは後方参照を使わない時の78から39になっています。
結果の長さは23, 39, 57, 76, 95, 114, 133と線形に増えます。
`square`の呼び出しの12連鎖は207,114文字から247、つまり800分の1以下にまで小さくなります。

<!-- Implementing `mangleFunc` mentioned above for the mangling with back referencing identifiers still is not obvious; while the fully qualified name is not supposed to contain any types (e.g. as a struct template argument) identifiers in the mangled name can appear again in the function type. This was solved by extending the demangler to use [“Design by Introspection” (DbI)](https://dconf.org/2017/talks/alexandrescu.pdf) (as coined by Andrei Alexandrescu): -->

上で言及していた後方参照を使った修飾の`mangleFunc`の実装はどうなったのでしょうか。
完全修飾名は型（たとえば構造体テンプレートの引数として）を含んでいないはずですが、修飾名の識別子は関数型に再び現れることがあります。
これは逆修飾器を[“Design by Introspection” (DbI)](https://dconf.org/2017/talks/alexandrescu.pdf)（Andrei Alexandrescuの作ったものです）を使って拡張することで解決されました。

<!-- *   make the `Demangle` struct a template that parameterizes on a struct that supplies a couple of hooks
    ```d
    struct NoHooks {}  // supports: static bool parseLName(ref Demangle); ...
    private struct Demangle(Hooks = NoHooks)
    {
    Hooks hooks;
        // ...
        void parseLName()
        {
            static if(__traits(hasMember, Hooks, "parseLName"))
                if (hooks.parseLName(this))
                    return;
                // normal decode...
        }
    }
    ``` -->

 - `Demangle`構造体という、フックを提供する構造体をパラメータ化するテンプレートを作る。
```d
    struct NoHooks {}  // supports: static bool parseLName(ref Demangle); ...
    private struct Demangle(Hooks = NoHooks)
    {
    Hooks hooks;
        // ...
        void parseLName()
        {
            static if(__traits(hasMember, Hooks, "parseLName"))
                if (hooks.parseLName(this))
                    return;
                // 普通のデコード...
        }
    }
 ```
    
<!-- *   create a hook that replaces a reoccurring identifier with the appropriate back reference
    ```d
    struct RemangleHooks
    {
        char[] result;
        size_t[const(char)[]] idpos;
        // ...
        bool parseLName(ref Demangler!RemangleHooks d)
        {
            // flush input so far to result[]
            if (d.front == 'Q')
            {
                // re-encode back reference...
            }
            else if (auto ppos = currentIdentifier in idpos)
            {
                // encode back reference to identifier at *ppos
            }
            else
            {
                idpos[currentIdentifier] = currentPos;
            }
            return true;
        }
    }
    ``` -->

 - 頻出する識別子を適切な後方参照に置き換えるフックを作る。
```d
    struct RemangleHooks
    {
        char[] result;
        size_t[const(char)[]] idpos;
        // ...
        bool parseLName(ref Demangler!RemangleHooks d)
        {
            // これまでのresult[]をフラッシュする
            if (d.front == 'Q')
            {
                // 後方参照を再エンコード...
            }
            else if (auto ppos = currentIdentifier in idpos)
            {
                // 後方参照を識別子 *ppos にエンコード
            }
            else
            {
                idpos[currentIdentifier] = currentPos;
            }
            return true;
        }
    }
 ```
    
<!-- *   combine the qualified name and the type as before (`core.demangle` is still capable of decoding it) and run it through the hooked demangler
    ```d
    char[] mangleFunc(FuncType)(const(char)[] qualifiedName)
    {
        const(char)mangledQualifiedName = encodeLNames(qualifiedName);
        const(char)mangled = mangledQualifiedName ~ FuncType.mangleof;
        auto d = Demangle!RemangleHooks(mangled, null);
        d.mute = true; // no demangled output
        d.parseMangledName();
        return d.hooks.result;
    }
    ``` -->
  
 - 修飾名と先の型（`core.demangle`にはデコードする能力があります）を組み合わせて、フックされた逆修飾器を実行します
```d
    char[] mangleFunc(FuncType)(const(char)[] qualifiedName)
    {
        const(char)mangledQualifiedName = encodeLNames(qualifiedName);
        const(char)mangled = mangledQualifiedName ~ FuncType.mangleof;
        auto d = Demangle!RemangleHooks(mangled, null);
        d.mute = true; // 逆修飾は出力されません
        d.parseMangledName();
        return d.hooks.result;
    }
 ```

<!-- ### Is the new mangling sound? -->

### 新しい修飾法は健全か？

<!-- The back references encoded into the mangling extend the existing mangling. Unfortunately, the latter had ambiguities reported to [the D issue tracking system](https://issues.dlang.org/), with more of these likely yet to be uncovered. The demangler in `core.demangle` rejected about 3% of the unmodified symbols from the Phobos unit tests, while 15% were demangled only partially. -->

後方参照は既存の修飾法を拡張した修飾法でエンコードされます。
残念ながら、既存のものは曖昧さが[Dのイシュートラッキングシステム](https://issues.dlang.org/)に報告されており、まだ見つかっていない問題もあるでしょう。
`core.demangle`の逆修飾器はPhobosのユニットテストの未修正のシンボルのうち3%ほどを受け付けず、15%ほどが部分的にしか逆修飾されませんでした。

<!-- It’s tough to verify the soundness of an addition to an already complex and fragile definition, as a change to the mangling would need an update to the tooling (demangler, debuggers). Anyway, it was a good opportunity to get rid of these, too. -->

修飾法の変更はツール（逆修飾器、デバッガ）の更新を必要とするので、既に複雑で脆弱な定義への追加の健全性を検証するのは大変です。
とにかく、それらを取り除くいい機会でした。

<!-- So scrutiny of the existing definition was required. To do this mechanically, the mangling specification from the web site was converted into a grammar digestible by [the bison parser generator](https://www.gnu.org/software/bison/). Bison can create LALR(1) parser tables, which basically means that, while scanning a mangled symbol, looking at a character and its successor is enough to determine whether the character adds to a previous entity or starts a new one. When conflicts are reported when processing a grammar, they might be resolvable with a larger context, but they can also hint at actual problems or undesirable complexity. Adding pseudo-tokens representing handcrafted parser control flow can avoid these conflicts. -->

既存の定義の再調査が必要でした。
機械的に調査を行うために、ウェブサイトから得られる修飾の仕様を[bisonパーサジェネレーター](https://www.gnu.org/software/bison/)が解釈できる文法に変換しました。
BisonはLALR(1)パーサテーブル、基本的には修飾されたシンボルをスキャンしつつ、文字とそのサクセサを見るだけで文字が前のエンティティのものか新しいエンティティの最初かを決定できるものを作ることができます。
文法の処理中に競合が報告された時は、より大きなコンテキストで解決できることもありますが、本当の問題や望ましくない複雑さのヒントになります。
手動パーサ制御フローを表す疑似トークンを追加することで競合を回避できます。

<!-- [This gist](https://gist.githubusercontent.com/rainers/6cdf73b48837defb9f88/raw/3db6a3c8e72222ccd6b22e8ae01c601bd585e9d8/dwebsite4.bison) shows a grammar for the D mangling scheme without the back references. It still has a couple of conflicts when run through Bison, one of which was determined to be an actual [ambiguity in the definition](https://github.com/dlang/dmd/pull/6702). Adding back references to the grammar [doesn’t add any conflicts](https://gist.githubusercontent.com/rainers/6cdf73b48837defb9f88/raw/3db6a3c8e72222ccd6b22e8ae01c601bd585e9d8/backref6.bison). -->

[このgist](https://gist.githubusercontent.com/rainers/6cdf73b48837defb9f88/raw/3db6a3c8e72222ccd6b22e8ae01c601bd585e9d8/dwebsite4.bison)は後方参照のないDの修飾スキームの文法です。
これはまだBisonで走らせるといくつか競合がありますが、そのうちの1つが本当の[定義の曖昧さ](https://github.com/dlang/dmd/pull/6702)です。
後方参照を文法に追加しても[競合は発生しませんでした](https://gist.githubusercontent.com/rainers/6cdf73b48837defb9f88/raw/3db6a3c8e72222ccd6b22e8ae01c601bd585e9d8/backref6.bison)。

<!-- In addition, [`core.demangle`](https://github.com/dlang/druntime/blob/master/src/core/demangle.d) was fixed to work for all symbols but those exposing the known ambiguities. -->

加えて、[`core.demangle`](https://github.com/dlang/druntime/blob/master/src/core/demangle.d)は曖昧さのあるものを除くすべてのシンボルで動作するよう修正されました。

<!-- ### Aftermath -->

### 影響

<!-- Some of the implementations in `std.traits` used the mangling of a symbol to introspect compile-time properties, for example, to determine the linkage. This was done using a simplified demangler. With the introduction of back references, these  didn’t work any more except for simple symbol names. Using a solution as for `core.mangleFunc` is feasible, but can slow down compilation considerably as the demangling needs to be executed via CTFE. Fortunately, new `__traits` have been added which cover all information that can be found in the mangling. -->

`std.traits`の実装のうちいくつかはリンケージの決定などのコンパイル時プロパティのintrospectのためにシンボルの修飾を利用していました。
これはシンプルになった逆修飾器を使って行われました。
後方参照の導入により、これらはシンプルなシンボル名を除き何もする必要がなくなりました。
`core.mangleFunc`を使った方法はうまくいきそうに見えますが、CTFEで逆修飾を実行する必要があるためコンパイルを顕著に遅くします。
幸運にも、修飾で得られるすべての情報をカバーする新しい`__traits`が追加されました。

<!-- While most users will not notice any changes to their programs other than smaller object and executable file sizes, the new mangling can be a breaking change to external tools like the linker or a debugger. These will continue to work, but until they are updated, be prepared to eventually see the new mangled names for a little while instead of the demangled ones. -->

ほとんどのユーザはオブジェクトファイルや実行ファイルのサイズが小さくなること以外の変化に気付くことはないでしょうが、新しい修飾法はリンカやデバッガなどの外部ツールにとっての破壊的変更になるかもしれません。
これらは動作はしますが、アップデートされるまでは逆修飾されたものの代わりに新しい修飾名を見ることになると思うので心の準備をしておいてください。

<!-- Thanks to Mike Parker, Walter Bright and Steven Schveighoffer for review. -->

レビューをしてくれたMike Parker、Walter Bright、Steven Schveighofferに感謝します。