---
date: 2018-09-06
title: "DMD 2.082.0 Released【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "D言語財団はDプログラミング言語のリファレンスコンパイラ、DMDのバージョン2.079.0をアナウンスします。 "
---

この記事は、
[DMD 2.082.0 Released – The D Blog](https://dlang.org/blog/2018/09/04/dmd-2-082-0-released/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものだ。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら教えてほしい。

---

<!-- ![](https://i1.wp.com/dlang.org/blog/wp-content/uploads/2016/08/d3.png?resize=160%2C301) -->

<img align="left" alt="D言語くん" src="/img/blog/2018/09/dman.png" >

<!-- DMD 2.082.0 was released over the weekend. There were 28 major changes and 76 closed Bugzilla issues in this release, including some very welcome improvements in the toolchain. [Head over to the download page](https://dlang.org/download.html) to pick up the official package for your platform and [visit the changelog for the details](https://dlang.org/changelog/2.082.0.html). -->

週末、DMD 2.082.0 がリリースされました。
このリリースには歓迎すべきツールチェインの改善を含む28の主要な変更と、
76の Bugzilla issues のクローズが含まれます。
あなたのプラットフォーム向けの公式パッケージを
[ダウンロードページに行って](https://dlang.org/download.html)
選び、[チェンジログで詳細を確認](https://dlang.org/changelog/2.082.0.html)しましょう。

<!-- Tooling improvements
-------------------- -->

### ツールの改善

<!-- While there were several improvements and fixes to the compiler, standard library, and runtime in this release, there were some seemingly innocuous quality\-of\-life changes to the tooling that are sure to be greeted with more enthusiasm. -->

コンパイラ、標準ライブラリ、ランタイムに対するいくつかの改善と修正に加えて、
ツールに対する一見退屈な、熱意を持って迎えられるべきQOLの変更がありました。

<!-- ### DUB gets dubbier -->

#### DUB の改善

<!-- DUB, the build tool and package manager for D that ships with DMD, received a number  of enhancements, including [better dependency resolution](https://dlang.org/changelog/2.082.0.html#recursive_dependecy_resolution), [variable support in the build settings](https://dlang.org/changelog/2.082.0.html#buildSettingsVars), and [improved environment variable expansion](https://dlang.org/changelog/2.082.0.html#env-var-replacement). -->

D のビルドツール兼パッケージマネージャであり、DMD とともに公開される DUB は、
[よりよい依存解決](https://dlang.org/changelog/2.082.0.html#recursive_dependecy_resolution)、
[ビルド設定における変数サポート](https://dlang.org/changelog/2.082.0.html#buildSettingsVars)、
[環境変数展開の改善](https://dlang.org/changelog/2.082.0.html#env-var-replacement)
などの多くの改善をしました。

<!-- Arguably the most welcome change will be the [removal of the regular update check](https://dlang.org/changelog/2.082.0.html#upgrade_check). Previously, DUB would check for dependency updates once a day before starting a project build. If there was no internet connection, or if there were any errors in dependency resolution, the process could hang for some time. With the removal of the daily check, upgrades will only occur when running `dub upgrade` in a project directory. Add to that the brand new `--dry-run` flag to get a list of any upgradable dependencies without executing the upgrades. -->

最も歓迎される変更は間違いなく
[更新チェック](https://dlang.org/changelog/2.082.0.html#upgrade_check)でしょう。
いままで DUB はプロジェクトをビルドする前に、依存のアップデートのチェックを1日1回行っていました。
インターネットに接続していないとき、または依存解決に何らかの問題が発生したときに、
プロセスはしばらくハングすることがありました。
このチェックを削除したことで、アップグレードはプロジェクトディレクトリで
`dub upgrade` したとき以外発生しないようになりました。
新しく追加された `--dry-run` フラグを追加すると、
アップグレード可能な依存を実際にアップグレードすることなく確認できます。

<!-- ### Signed binaries for Windows -->

#### Windows向け署名済みバイナリー

<!-- For quite some time users of DMD on Windows have had the annoyance of seeing [a warning from Windows Smartscreen](https://en.wikipedia.org/wiki/Microsoft_SmartScreen) when running the installer, and the occasional false positive from AntiVirus software when running DMD. -->

Windows における DMD ユーザーはインストーラーを実行した際に
[Windows Smartscreenからの警告](https://en.wikipedia.org/wiki/Microsoft_SmartScreen)
という迷惑を被ることがあります。
また、DMD を実行した際には時々アンチウイルスソフトのフォールス・ポジティブが起こります。

<!-- Now those in the Windows D camp can [do a little victory dance](https://www.youtube.com/watch?v=KL19ZVbcPaw), as all of the binaries in the distribution, including the installer, [are signed with the D Language Foundation’s new code signing certificate](https://dlang.org/changelog/2.082.0.html#signed_windows_binaries). This is one more quality\-of\-life issue that can finally be laid to rest. On a side note, the cost of the certificate was the first expense entered [into our Open Collective page](https://opencollective.com/dlang). -->

インストーラーを含む、配布されるすべてのバイナリが
[D言語財団の新しいコード署名証明書で署名されるようになった](https://dlang.org/changelog/2.082.0.html#signed_windows_binaries)
ため、Windows で D を使っている人々は
[勝利の舞](https://www.youtube.com/watch?v=KL19ZVbcPaw)
を踊るでしょう。
これは忘れ去られ、当たり前になっていくQOLイシューです。
付け加えておくと、[我々の Open Collective](https://opencollective.com/dlang)
からの最初の支出はこの証明書に使われました。

<!-- Compiler and libraries
---------------------- -->

### コンパイラとライブラリ

<!-- Many of the changes and updates in the compiler and library department are unlikely to compel anyone to shout from the rooftops, but a handful are nonetheless notable. -->

コンパイラとライブラリ部で行われた更新や変更の多くは屋根の上で叫ばずにはいられない、
というものではありませんが、しかしいくらか注目に値するものがあります。

<!-- ### The compiler -->

#### コンパイラ

<!-- One such is an expansion of [the User\-Defined Attribute syntax](https://dlang.org/spec/attribute.html#uda). Previously, these were only allowed on declarations. Now, [they can be applied to function parameters](https://dlang.org/changelog/2.082.0.html#uda-function-parameters): -->

ひとつは[ユーザー定義属性構文](https://dlang.org/spec/attribute.html#uda)です。
以前まで、これは宣言部以外で書くことができませんでした。
いまやそれらは[関数パラメータにも適用できます](https://dlang.org/changelog/2.082.0.html#uda-function-parameters)。

<!-- ```d
// Previously, it was illegal to attach a UDA to a function parameter

void example(@(22) string param)

{

    // It's always been legal to attach UDAs to type, variable, and function declarations.

    @(11) string var;

    pragma(msg, \[\_\_traits(getAttributes, var)\] \== \[11\]);

    pragma(msg, \[\_\_traits(getAttributes, param)\] \== \[22\]);

}
``` -->

```d
// 以前は、UDAを関数パラメーターに適用することは違法（illegal）でした

void example(@(22) string param)

{

    // 型、変数、関数宣言にUDAを適用するのは合法（legal）です

    @(11) string var;

    pragma(msg, [__traits(getAttributes, var)] == [11]);

    pragma(msg, [__traits(getAttributes, param)] == [22]);

}
```

<!-- _[Run this example online](https://run.dlang.io/is/Hu4csb)_ -->

*[この例をオンラインで実行する](https://run.dlang.io/is/Hu4csb)*

<!-- The same goes for enum members (it’s not explicitly listed in the highlights at the top of the changelog, [but is mentioned in the bugfix list](https://dlang.org/changelog/2.082.0.html#bugfix-list)): -->

列挙体のメンバーも同じことができます（これはチェンジログ上部のハイライトにはリストされていませんが、
[Bugfix リスト上では言及されています](https://dlang.org/changelog/2.082.0.html#bugfix-list)）:

<!-- ```d
enum Foo {

@(10) one,

@(20) two,

}

void main()

{

pragma(msg, \[\_\_traits(getAttributes, Foo.one)\] \== \[10\]);

pragma(msg, \[\_\_traits(getAttributes, Foo.two)\] \== \[20\]);

}
``` -->

```d
enum Foo {

@(10) one,

@(20) two,

}

void main()

{

pragma(msg, [__traits(getAttributes, Foo.one)] == [10]);

pragma(msg, [__traits(getAttributes, Foo.two)] == [20]);

}
```

<!-- _[Run this example online](https://run.dlang.io/is/B2H73i)_ -->

*[この例をオンラインで実行する](https://run.dlang.io/is/B2H73i)*

<!-- [The DasBetterC subset of D](http://dlang.org/blog/2018/06/11/dasbetterc-converting-make-c-to-d/) is [enhanced in this release with some improvements](https://dlang.org/changelog/2.082.0.html#betterc_cmp_types). It’s now possible to use array literals in initializers. Previously, array literals required the use of `TypeInfo`, which is part of DRuntime and therefore unavailable in `-betterC` mode. Moreover, comparing arrays of structs is now supported and comparing arrays of byte\-sized types should no longer generate any linker errrors. -->

[D の DasBetterC サブセット](http://dlang.org/blog/2018/06/11/dasbetterc-converting-make-c-to-d/)
は
[このリリースのいくつかの改善により強化されています](https://dlang.org/changelog/2.082.0.html#betterc_cmp_types)
。
初期化子に配列リテラルを使うことができるようになりました。
以前まで、配列リテラルは `TypeInfo` を必要としており、
`TypeInfo` は DRuntime の一部であり `-betterC` モードでは使えませんでした。
さらに、構造体の配列の比較がサポートされ、1バイト型の配列の比較もリンカエラーを起こさなくなりました。

<!-- ```d
import core.stdc.stdio;

struct Sint

{

    int x;

    this(int v) { x \= v;}

}

extern(C) void main()

{

    // No more TypeInfo error in this initializer

    Sint\[6\] a1 \= \[Sint(1), Sint(2), Sint(3), Sint(1), Sint(2), Sint(3)\];

    foreach(si; a1) printf("%i\\n", si.x);

    // Arrays/slices of structs can now be compared

    assert(a1\[0..3\] \== a1\[3..$\]);

    // No more linker error when comparing strings, either explicitly

    // or implicitly such as in a switch.

    auto s \= "abc";

    switch(s)

    {

     case "abc":

     puts("Got a match!");

     break;

     default:

     break;

    }

    // And the same goes for any byte\-sized type

    char\[6\] a \= \[1,2,3,1,2,3\];

    assert(a\[0..3\] \>= a\[3..$\]);

    puts("All the asserts passed!");

}
``` -->

```d
import core.stdc.stdio;
struct Sint
{
    int x;
    this(int v) { x = v;}
}

extern(C) void main()
{
    // この初期化子では TypeInfo エラーが起きません
    Sint[6] a1 = [Sint(1), Sint(2), Sint(3), Sint(1), Sint(2), Sint(3)];
    foreach(si; a1) printf("%i\n", si.x);

    // 構造体の配列 / スライスが比較可能になりました
    assert(a1[0..3] == a1[3..$]);

    // 文字列の比較はリンカエラーを起こさなくなりました。
    // 明示的にも、 switch のように暗黙的にも。
    auto s = "abc";
    switch(s)
    {
        case "abc":
            puts("Got a match!");
            break;
        default:
            break;
    }

    // 1バイト型でも同じです
    char[6] a = [1,2,3,1,2,3];
    assert(a[0..3] >= a[3..$]);

    puts("All the asserts passed!");
}
```

<!-- _[Run this example online](https://run.dlang.io/is/FiuBop)_ -->

*[この例をオンラインで実行する](https://run.dlang.io/is/FiuBop)*

<!-- ### DRuntime -->

#### DRuntime

<!-- Another quality\-of\-life fix, this one touching on the debugging experience, is a [new run\-time flag that can be passed to any D program](https://dlang.org/changelog/2.082.0.html#exceptions-opt) compiled against the 2.082 release of the runtime or later, `--DRT-trapException=0`. This allows exception trapping to be disabled from the command line. -->

もうひとつの QOL フィックス、これはデバッグ体験に関わるものです。
2.082 以降のランタイムのリリースに対してコンパイルされた
[D プログラムに新たなランタイムフラグを渡せるようになりました](https://dlang.org/changelog/2.082.0.html#exceptions-opt)。
`--DRT-trapException=0` です。
これでコマンドラインから例外トラッピングを無効にできます。

<!-- Previously, this was supported only via a global variable, `rt_trapExceptions`. To disable exception trapping, this variable had to be set to `false` before DRuntime gained control of execution, which meant implementing your own `extern(C) main` and calling `_d_run_main` to manually initialize DRuntime which, in turn, would run the normal D `main`—all of which is demonstrated in the Tip of the Week from [the August 7, 2016, edition of This Week in D](http://arsdnet.net/this-week-in-d/2016-aug-07.html) (you’ll also find there a nice explanation of why you might want to disable this feature. HINT: running in your debugger). A command\-line flag is sooo much simpler, no? -->

以前まで、これはグローバル変数 `rt_trapExceptions` によってサポートされていました。
例外トラッピングを無効にするには、この変数を DRuntime が実行のコントロールを始める前に
`false` に設定する必要があります。
つまり、`extern(C) main` を自分で実装し、DRuntime の初期化のために `_d_run_main` を呼び、
そして通常の D の `main` が呼ばれるということです。
これは[2016年8月7日のThis Week in D](http://arsdnet.net/this-week-in-d/2016-aug-07.html)
の今週の Tip としてデモンストレートされています。
（なぜ機能を無効化しなければならないかの説明も得られるでしょう。ヒント: デバッガーの実行）
コマンドラインフラグのほうがシンプル、違いますか？

<!-- ### Phobos -->

#### Phobos

<!-- The `std.array` module [has long had an `array` function](https://dlang.org/phobos/std_array.html#array) that can be used to create a dynamic array from any finite range. With this release, [the module gains a `staticArray` function](https://dlang.org/changelog/2.082.0.html#std-array-asStatic) that can do the same for static arrays, though it’s limited to input ranges (which includes other arrays). When the length of a range is not knowable at compile time, it must be passed as a template argument. Otherwise, the range itself can be passed as a template argument. -->

`std.array` モジュールには有限レンジから動的配列を生成する
[`array` 関数があります](https://dlang.org/phobos/std_array.html#array)。
このリリースで [このモジュールに `staticArray` 関数が追加されました](https://dlang.org/changelog/2.082.0.html#std-array-asStatic)。
これで Input range に限り（他の配列を含む）、同じことが静的配列でも可能になります。
レンジの長さがコンパイル時にわからない場合、テンプレート引数としてそれを渡す必要があります。
そうでないなら、レンジそれ自身がテンプレート引数として渡せます。

<!-- ```d
import std.stdio;

void main()

{

    import std.range : iota;

    import std.array : staticArray;

    auto input \= 3.iota;

    auto a \= input.staticArray!2;

    pragma(msg, is(typeof(a) \== int\[2\]));

    writeln(a);

    auto b \= input.staticArray!(long\[4\]);

    pragma(msg, is(typeof(b) \== long\[4\]));

    writeln(b);

}
``` -->

```d
import std.stdio;
void main()
{
    import std.range : iota;
    import std.array : staticArray;

    auto input = 3.iota;
    auto a = input.staticArray!2;
    pragma(msg, is(typeof(a) == int[2]));
    writeln(a);
    auto b = input.staticArray!(long[4]);
    pragma(msg, is(typeof(b) == long[4]));
    writeln(b);
}
```

<!-- _[Run this example online](https://run.dlang.io/is/7dpxJM)_ -->

*[この例をオンラインで実行する](https://run.dlang.io/is/7dpxJM)*

<!-- September pumpkin spice
----------------------- -->

### September pumpkin spice

<!-- [Participation in the #dbugfix campaign](https://dlang.org/blog/2018/02/03/the-dbugfix-campaign/) for this cycle was, like last cycle, rather dismal. Even so, I’ll have an update on that topic later this month in a post of its own. -->

今サイクルの[ #dbugfix キャンペーンの参加状況](https://dlang.org/blog/2018/02/03/the-dbugfix-campaign/)は、
前サイクルと同様に、どちらかというと芳しくありません。
しかし、今月後半にこのトピックに関するアップデートの記事があります。

<!-- Three of eight applicants were selected for [the Symmetry Autumn of Code](https://dlang.org/blog/symmetry-autumn-of-code/), which officially kicked off on September 1. Stay tuned here for a post on that topic as well. -->

志願者のうち8分の3が9月1日に始まった
[the Symmetry Autumn of Code](https://dlang.org/blog/symmetry-autumn-of-code/)
に選ばれました。
これについての記事も楽しみにしていてください。

<!-- The blog has been quiet for a few weeks, but the gears are slowly and squeakily starting to grind again. Other posts lined up for this month include the next long\-overdue [installment in the GC Series](https://dlang.org/blog/the-gc-series/) and the launch of [a new ‘D in Production’ profile](https://dlang.org/blog/d-in-production/). -->

当ブログの更新は何週間か少なくなりますが、歯車はゆっくりと、きしみながら再び回り始めています。
今月は、しばらくぶりの
[GC シリーズの投稿](https://dlang.org/blog/the-gc-series/)と、
新シリーズ
[`D in Production`](https://dlang.org/blog/d-in-production/)
の投稿が予定されています。
