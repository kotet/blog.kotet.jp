---
date: 2017-11-04
title: "DMD 2.077.0 Released【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "D FoundationはDMD 2.077.0を発表しました。 このDプログラミング言語のリファレンスコンパイラの最新のリリースはdlang.orgのダウンロードページから利用できます。"
---

この記事は、
[DMD 2.077.0 Released – The D Blog](https://dlang.org/blog/2017/11/03/dmd-2-077-0-released/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
内容が理解できる程度のざっくりした翻訳であり誤字や誤訳などが多いので、気になったら
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---
<!-- # DMD 2.077.0 Released -->

<!-- The D Foundation is happy to announce DMD 2.077.0\. This latest release of the reference compiler for the D programming language is available from the [dlang.org Downloads page](https://dlang.org/download.html). Among the usual slate of [bug and regression fixes](https://dlang.org/changelog/2.077.0.html), this release brings a couple of particulary beneficial enhancements that will have an immediate impact on some existing projects. -->

D FoundationはDMD 2.077.0を発表しました。
このDプログラミング言語のリファレンスコンパイラの最新のリリースは[dlang.orgのダウンロードページ](https://dlang.org/download.html)から利用できます。
このリリースは、通常の[バグとリグレッションの修正](https://dlang.org/changelog/2.077.0.html)の中で、既存のプロジェクトに即座に影響のある特に有益な拡張がもたらされます。

<!-- ### Cutting symbol bloat -->

### シンボルの肥大化のカット

<!-- Thanks to Rainer Schütze, the compiler now produces significantly smaller mangled names in situations where they had begun to get out of control, particularly in the case of IFTI (Implicit Function Template Instantiation) where Voldemort types are involved. That may call for a bit of a detour here. -->

Rainer Schützeにより、名前が制御を離れた時、特にヴォルデモート型に関わるIFTI（暗黙の関数テンプレートインスタンス化）の時に、コンパイラはかなり小さくマングルされた名前を提供するようになりました。
ちょっと説明が必要かもしれません。

<!-- #### The types that shall not be named -->

#### 命名されない型

<!-- [Voldemort types](https://wiki.dlang.org/Voldemort_types) are perhaps one of D’s more interesting features. They look like this: -->

[ヴォルデモート型](https://wiki.dlang.org/Voldemort_types)はおそらくDの中でも面白い機能です。
このようなものです:

<!-- ```d
auto getHeWhoShallNotBeNamed() 
{
    struct NoName 
    {
        void castSpell() 
        {
            import std.stdio : writeln;
            writeln("Crucio!");
        }           
    }
    return NoName();
}

void main() 
{
    auto voldemort = getHeWhoShallNotBeNamed();
    voldemort.castSpell();
}
``` -->

```d
auto getHeWhoShallNotBeNamed() 
{
    struct NoName 
    {
        void castSpell() 
        {
            import std.stdio : writeln;
            writeln("クルーシオ!");
        }           
    }
    return NoName();
}

void main() 
{
    auto voldemort = getHeWhoShallNotBeNamed();
    voldemort.castSpell();
}
```

<!-- Here we have an [auto function](https://dlang.org/spec/function.html#auto-functions), a function for which the return type is inferred, returning an instance of a type declared inside the function. It’s possible to access public members on the instance even though its type can never be named outside of the function where it was declared. Coupled with type inference in variable declarations, it’s possible to store the returned instance and reuse it. This serves as an extra level of encapsulation where it’s desired. -->

[auto function](https://dlang.org/spec/function.html#auto-functions)という返値の型が推論される関数があり、それが関数の中で宣言された型のインスタンスを返しています。
宣言された関数の外で型が名づけられないのにも関わらず、インスタンスのパブリックメンバにアクセスが可能です。
変数の宣言の型推論と合わせて、返されたインスタンスの保持と再利用が可能です。
これは、高いレベルのカプセル化として機能します。

<!-- In D, for any given API, as far as the world outside of a module is concerned, _module private_ is the lowest level of encapsulation. -->

Dにおいて、任意のAPIについて、モジュールの外の世界に関して**モジュールプライベート**は最も低いレベルのカプセル化です。

<!-- ```d
module foobar;

private struct Foo
{
    int x;
}

struct Bar 
{
    private int y;
    int z;
}
``` -->

```d
module foobar;

private struct Foo
{
    int x;
}

struct Bar 
{
    private int y;
    int z;
}
```

<!-- Here, the type `Foo` is module private. `Bar` is shown here for completeness, as those new to D are often surprised to learn that private members of an aggregate type are also module private (D’s equivalent of the C++ `friend` relationship). There is no keyword that indicates a lower level of encapsulation. -->

ここで、型`Foo`はモジュールプライベートです。
Dの新人はしばしばaggregate typeのプライベートメンバもまたモジュールプライベートであるということを知って驚くので（C++の`friend`と等価です）、`Bar`は完全性のために表記してあります。
ここに低いレベルのカプセル化を示すキーワードはありません。

<!-- Sometimes you just may not want `Foo` to be visible to the entire module. While it’s true that anyone making a breaking change to Foo’s interface also has access to the parts of the module that break (which is the rationale behind module-private members), there are times when you may not want the entire module to have access to `Foo` at all. Voldemort types fill that role of hiding details not just from the world, but from the rest of the module. -->

`Foo`を見えないようにしたくなる時があるかもしれません。
Fooのインターフェースに破壊的変更を加える人はそのモジュールの一部にもアクセスできますが（これはモジュールプライベートメンバの背後にある根拠です）、モジュール全体が`Foo`にアクセスしてほしくない時があります。
ヴォルデモート型は、モジュールの外の世界だけでなくモジュールの中でも詳細を隠蔽する役割を果たします。

<!-- #### The evil side of Voldemort types -->

#### ヴォルデモート型の悪い面

<!-- One unforeseen consequence of Voldemort types that was [first reported](https://issues.dlang.org/show_bug.cgi?id=15831) in mid–2016 was that, when used in templated functions, they caused a serious explosion in the size of the mangled function names (in some cases up to 1 MB!), making for some massive object files. There was a good bit of forum discussion on how to trim them down, with a number of ideas tossed around. Ultimately, Rainer Schütze took it on. His persistence has resulted in shorter mangled names all around, but the wins are particularly impressive when it comes to IFTI and Voldemort types. (Rainer is also the maintainer of [Visual D](http://rainers.github.io/visuald/visuald/StartPage.html), the D programming language plugin for Visual Studio) -->

テンプレート化された関数を使う時に発生する、マングルされた関数名のサイズの深刻な爆発（場合によっては1MBを超えます！）により、オブジェクトファイルが肥大化するというヴォルデモート型による意外な影響が2016年なかばに[報告されました](https://issues.dlang.org/show_bug.cgi?id=15831) 。
この問題を解決するため、フォーラムのディスカッションで様々な意見が提案されました。
最終的に、Rainer Schützeが引き受けました。
彼の努力によりマングルされた名前は全体的に短くなり、これは特にIFTIとヴォルデモート型にいい影響をもたらします（Rainerは[Visual D](http://rainers.github.io/visuald/visuald/StartPage.html)という、Dプログラミング言語のVisual Studioのプラグインのメンテナーでもあります）。

<!-- D’s name-mangling scheme is detailed in the [ABI documentation](https://dlang.org/spec/abi.html#name_mangling). The description of the new enhancement is in the section titled [‘Back references’](https://dlang.org/spec/abi.html#back_ref). -->

Dの名前修飾スキームは[ABI documentation](https://dlang.org/spec/abi.html#name_mangling)で詳細に説明されています。
新しい拡張の説明は[‘Back references’](https://dlang.org/spec/abi.html#back_ref)というタイトルのセクションにのっています。

<!-- ### Improved vectorization -->

### ベクトル化の改善

<!-- D has long supported array operations such as element-wise addtion, multiplication, etc. For example: -->

Dは昔から要素ごとの加算、乗算などの配列操作をサポートしています。
たとえば:

<!-- ```d
int[] arr1 = [0, 1, 2];
int[] arr2 = [3, 4, 5];
int[3] arr3 = arr1[] + arr2[];
assert(arr3 == [3, 5, 7]);
``` -->

```d
int[] arr1 = [0, 1, 2];
int[] arr2 = [3, 4, 5];
int[3] arr3 = arr1[] + arr2[];
assert(arr3 == [3, 5, 7]);
```

<!-- In some cases, such operations could be vectorized. The reason it was _some_ cases and not _all_ cases is because dedicated assembly routines were used to achieve the vectorization and they weren’t implemented for every case. -->

いくつかのケースで、このような操作はベクトル化されます。
**いくつかの**ケースであって**すべての**ケースでは無いのは、ベクトル化のためには専用のアセンブリルーチンが使われており、すべてのケースに専用のルーチンが実装されているわけではなかったからです。

<!-- With 2.077.0, that’s no longer true. Vectorization is now templated so that all array operations benefit. Any codebase out there using array operations that were not previously vectorized can expect a sizable performance increase for those operations thanks to the increased throughput (though whether an application benefits overall is of course context-dependent). How the benefit is received depends on the compiler being used. From the changelog: -->

2.077.0において、これはもはや正しくありません。
ベクトル化はすべての配列操作のためにテンプレート化されました。
これまでベクトル化されていなかった配列操作を使ったコードベースは、スループットの向上により大幅な速度の改善が期待できるかもしれません(もちろんケースによります)。
恩恵を受けられる度合いは使うコンパイラによります。
チェンジログ曰く:

<!-- > For GDC/LDC the implementation relies on auto-vectorization, for DMD the implementation performs the vectorization itself. Support for vector operations with DMD is determined statically (-mcpu=native, -mcpu=avx2) to avoid binary bloat and the small test overhead. DMD enables SSE2 for 64-bit targets by default. -->

> GDC/LDCの実装は自動ベクトル化に依存しており、DMDの実装は自分でベクトル化をおこないます。
> DMDのベクトル操作のサポートはバイナリの肥大化とテストのオーバーヘッドを避けるため静的に（-mcpu=native, -mcpu=avx2）決定されます。
> DMDは64ビットターゲットにおいてデフォルトでSSE2を有効にしています。

<!-- _Note that the changelog initially showed `-march` instead of `-mcpu` in the quoted lines, and the updated version had not yet been posted when this announcement was published._ -->

チェンジログは初め`-mcpu`ではなく`-march`と書かれていて、このアナウンスメントの公開時点で更新版はまだ公開されていないことに注意してください。

<!-- DMD’s implementation is implemented in terms of [`core.simd`](https://dlang.org/spec/simd.html#core_simd), which is also [part of DRuntime’s public API](https://dlang.org/phobos/core_simd.html). -->

DMDの実装は[DRuntimeのパブリックAPIの一部](https://dlang.org/phobos/core_simd.html)でもある
[`core.simd`](https://dlang.org/spec/simd.html#core_simd)で実装されています。

<!-- The changelog also notes that there’s a potential for division performed on float arrays in existing code to see a performance decrease in exchange for an increase in precision. -->

チェンジログは既存のコードの浮動小数点数の配列の除算において精度と引き換えにパフォーマンスが低下する可能性があるということにも触れています。

<!-- > The implementation no longer weakens floating point divisions (e.g. `ary[] / scalar`) to multiplication (`ary[] * (1.0 / scalar)`) as that may reduce precision. To preserve the higher performance of float multiplication when loss of precision is acceptable, use either `-ffast-math` with GDC/LDC or manually rewrite your code to multiply by (`1.0 / scalar`) for DMD. -->

> 精度の低下を引き起こす可能性があるため、実装は浮動小数点数の除算（たとえば `ary[] / scalar`）の乗算（`ary[] * (1.0 / scalar)`）への強度低減を行わなくなりました。
> 精度の低下が許容できる場面で浮動小数点数の高いパフォーマンスを維持するには、GDC/LDCで`-ffast-math`を使うか、DMDではコードを乗算（`1.0 / scalar`）に書き換えてください。

<!-- ### Other assorted treats -->

### その他いろいろ

<!-- Just the other day, someone asked in the forums if DMD supports [reproducible builds](https://reproducible-builds.org/). As of 2.077.0, the answer is affirmative. DMD now ensures that compilation is deterministic such that given the same source code and the same compiler version, the binaries produced will be identical. If this is important to you, be sure not to use any of the non-determistic lexer tokens (`__DATE__`, `__TIME__`, and `__TIMESTAMP__`) in your code. -->

この間、誰かがフォーラムでDMDは[reproducible builds](https://reproducible-builds.org/)をサポートしないのかと聞いていました。
2.077.0では、答えは肯定になります。
DMDのコンパイルは決定論的に、同じソースコードと同じコンパイラバージョンでは、同じバイナリが出力されるようになりました。
これが重要な場合は、コードに非決定論的lexerトークン（`__DATE__`、`__TIME__`、`__TIMESTAMP__`）を含めないでください。

<!-- DMD’s `-betterC` command line option gets some more love in this release. When it’s enabled, DRuntime is not available. Library authors can now use the [predefined version](https://dlang.org/spec/version.html#predefined-versions) `D_BetterC` to determine when that is the case so that, where it’s feasible, they can more conveniently support applications with and without the runtime. Also, the option’s behavior [is now documented](https://dlang.org/spec/betterc.html), so it’s no longer necessary to go to the forums or parse through search results to figure out what is and isn’t actually supported in BetterC mode. -->

このリリースでDMDの`-betterC`コマンドラインオプションはより愛されるようになりました。
これを有効にすると、DRuntimeは使えなくなります。
ライブラリの作者は[定義済みバージョン識別子](https://dlang.org/spec/version.html#predefined-versions)
`D_BetterC`を使うことができるようになったので、ランタイムのある時と無い時を判断し便利にアプリケーションをサポートできます。
`-betterC`オプションの振る舞いは[文書化されたので](https://dlang.org/spec/betterc.html)、もはやBetterCモードで何がサポートされ、何がサポートされないか調べるためにフォーラムに行ったり検索結果をパースする必要はありません。

<!-- The entire changelog is, as always, [available at dlang.org](https://dlang.org/changelog/2.077.0.html). -->

チェンジログ全体は、いつもどおり[dlang.orgで見ることができます](https://dlang.org/changelog/2.077.0.html)。