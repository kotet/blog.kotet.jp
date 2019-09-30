---
title: "DとCのインターフェース：配列 Part 1【翻訳】"
date: 2018-12-15
tags:
- dlang
- tech
- translation
- d_blog
- d_and_c
- advent_calendar
- cpplang
---

これは
[Interfacing D with C: Arrays Part 1 – The D Blog](https://dlang.org/blog/2018/10/17/interfacing-d-with-c-arrays-part-1/)
を
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
翻訳した
[D言語 Advent Calendar 2018 - Qiita](https://qiita.com/advent-calendar/2018/dlang)
15日目の記事です。

誤訳等あれば気軽に
[Pull requestを投げてください](https://github.com/kotet/blog.kotet.jp)。

---

<!-- _This post is [part of an ongoing series](https://dlang.org/blog/the-d-and-c-series/) on some of the potential issues that might appear when interfacing D with C and how to avoid them._ -->

この投稿はDとCとのインターフェーシングにおいて潜む問題と、
その回避法についての[シリーズ](https://dlang.org/blog/the-d-and-c-series/)の記事です
（訳注：[翻訳版はこちら](/tags/d_and_c)）。

<!-- When interacting with C APIs, it’s almost a given that arrays are going to pop up in one way or another (perhaps most often as strings, a subject of a future article in the “D and C” series). Although D arrays are implemented in a manner that is not directly compatible with C, the fundamental building blocks are the same. This makes compatibility between the two relatively painless as long as the differences are not forgotten. This article is the first of a few exploring those differences. -->

CのAPIとのインターフェーシングにおいて特に問題として立ちはだかるのは配列でしょう
（文字列も同列に並ぶものかもしれません。これは”D and C”シリーズの将来の記事の話題となります）。
Dの配列はCと直接の互換を持つような方式で実装されているわけではありませんが、基本的には同じです。
このため、両者の違いを把握している限り互換性に問題は生じません。
この記事ではまずその違いを見ていきましょう。

<!-- When using a C API from D, it’s sometimes necessary to translate existing code from C to D. A new D program can benefit from existing examples of using the C API, and anyone porting a program from C that uses the API would do well to keep the initial port as close to the original as possible. It’s on that basis that we’re starting off with a look at the declaration and initialization syntax in both languages and how to translate between them. Subsequent posts in this series will cover multidimensional arrays, the anatomy of a D array, passing D arrays to and receiving C arrays from C functions, and how the GC fits into the picture. -->

CのAPIをDから使う際は、コードをCからDに翻訳しなければならないことがあります。
新しいDのプログラムはCのAPIの既存の使用例を利用できて、
CのAPIを使うCのプログラムからのDへの移植は既存のCのコードから多くを書き換えることなく可能です。
両者の宣言と初期化構文、その翻訳方法がその根拠です。
このシリーズの後の記事では多次元配列、Dの配列の内部構造、
Cの関数との配列のやり取り、GCがどのように働くかを取り扱います。

<!-- My original concept of covering this topic was much smaller in scope, my intent to brush over the boring details and assume that readers would know enough of the basics of C to derive the why from the what and the how. That was before I gave a D tutorial presentation to a group among whom only one person had any experience with C. I’ve also become more aware that there [are regular users of the D forums](https://forum.dlang.org/) who have never touched a line of C. As such, I’ll be covering a lot more ground than I otherwise would have (hence a two\-part article has morphed into at least three). I urge those for whom much of said ground is old hat not to get complacent in their skimming of the page! A comfortable experience with C is more apt than none at all to obscure some of the pitfalls I describe. -->

このトピックを取り扱う際触れる予定だった範囲は最初非常に狭いものでした。
それは私が読者はCの基礎を十分に理解しており、何がなぜどのようになるかを推測できると仮定しており、
退屈な詳細の説明を取り去ったためでした。
Cの経験者が1人しかいないグループに対してDのチュートリアルプレゼンテーションを行う前の話です。
[Dフォーラムの一般ユーザー](https://forum.dlang.org/)
のなかにCのコードに触れたことのない人がいることにも気づきました。
そのため、私は当初よりも基本的なところからカバーしていくことにしました
（そのため2パートだった記事は3本以上に膨れ上がっています）。
知識が古い人も流し読みして満足しないようにすることをおすすめします！
Cで快適に過ごしてきた経験は、私が説明していく落とし穴を紛らす役には立ちません。

<!-- ### Array declarations -->

### 配列の宣言

<!-- Let’s start with a simple declaration of a one\-dimensional array: -->

1次元配列の単純な宣言から見ていきましょう。

```c
int c0[3];
```

<!-- This declaration allocates enough memory on the stack to hold three `int` values. The values are stored contiguously in memory, one right after the other. `c0` may or may not be initialized, depending on where it’s declared. Global variables and `static` local variables are default initialized to `0`, as the following C program demonstrates. -->

この宣言は`int`の値3つを保持するのに十分なメモリをスタックに確保します。
値はメモリの連続した領域に保存され、それぞれ隣り合っています。
`c0`が初期化されるかはそれが宣言された場所に依存します。
グローバル変数と`static`ローカル変数は、以下のCプログラムで示されるようにデフォルトで`0`に初期化されます。

**definit.c**

<!-- ```c
#include <stdio.h>

// global (can also be declared static)

int c1[3];

void main(int argc, char** argv)

{

    static int c2[3];       // static local

    int c3[3];              // non-static local

    printf("one: %i  %i  %i\n", c1[0], c1[1], c1[2]);

    printf("two: %i  %i  %i\n", c2[0], c2[1], c2[2]);

    printf("three: %i  %i  %i\n", c3[0], c3[1], c3[2]);

}
``` -->

```c
#include <stdio.h>

// グローバル変数（staticとして宣言することもできます）

int c1[3];

void main(int argc, char** argv)

{

    static int c2[3];       // staticローカル変数

    int c3[3];              // 非staticローカル変数

    printf("one: %i  %i  %i\n", c1[0], c1[1], c1[2]);

    printf("two: %i  %i  %i\n", c2[0], c2[1], c2[2]);

    printf("three: %i  %i  %i\n", c3[0], c3[1], c3[2]);

}
```

<!-- For me, this prints: -->

私には、これは以下の出力をしました。

```
one: 0 0 0

two: 0 0 0

three: -1 8 0
```

<!-- The values for `c3` just happened to be lying around at that memory location. Now for the equivalent D declaration: -->

`c3`の値はちょうどそのメモリ位置にあった値です。
さて、これと等価なDの宣言は以下になります。

```d
int[3] d0;
```

<!-- _[Try it online](https://run.dlang.io/is/moXqNt)_ -->

_[オンラインで試す](https://run.dlang.io/is/moXqNt)_

<!-- Here we can already find the first gotcha. -->

ここに最初の注意点があります。

<!-- A general rule of thumb in D is that C code pasted into a D source file should either work as it does in C or fail to compile. For a long while, C array declaration syntax fell into the former category and was a legal alternative to the D syntax. It has since been deprecated and subsequently removed from the language, meaning `int d0[3]` will now cause the compiler to scold you: -->

Dの普遍的な指針として、CのコードをDのソースファイルにコピペしてきた際には、
Cと同じように動作するかコンパイルが失敗するかのどちらかが起きるようになっています。
ながらくCの配列宣言構文は前者にあり、Dの構文中で合法な選択肢でした。
現在は廃止され言語から削除されたために、`int d0[3]`はコンパイラに怒られるようになりました。

```
Error: instead of C-style syntax, use D-style int[3] d0
```

<!-- It may seem an arbitrary restriction, but it really isn’t. At its core, it’s about consistency at a couple of different levels. -->

独断的な制約に思えるかもしれませんが、そうではありません。
本質には、いくつかのレベルにおける一貫性があります。

<!-- One is that [we read declarations in D from right to left](https://dlang.org/spec/declaration.html). In the declaration of `d0`, everything flows from right to left in the same order that we say it: “(d0) is an (array of three) (integers)”. The same is not true of the C\-style declaration. -->

ひとつは、[Dにおいて宣言は右から左に読む](https://dlang.org/spec/declaration.html)ということです。
`d0`の宣言のなかで、すべては右から左に読むと、我々が普段言うのと同じ順番に流れます。
"(d0) is an (array of three) (integers)" というように。
Cスタイルの宣言はそうなっていません。

<!-- Another is that the type of `d0` is actually `int[3]`. Consider the following pointer declarations: -->

もうひとつは`d0`の型が`int[3]`だということです。
以下のようなポインタの宣言を考えてみましょう。

```d
int* p0, p1;
```

<!-- The type of both `p0` and `p1` is `int*` (in C, only `p0` would be a pointer; `p1` would simply be an `int`). It’s the same as all type declarations in D—type on the left, symbol on the right. Now consider this: -->

`p0`も`p1`もその型は`int*`です（Cでは、`p0`だけがポインタになります。`p1`はただの`int`です）。
これはDにおけるあらゆる型宣言で同じです。
型は左、シンボルは右。
このようなコードを考えてみます。

```d
int d1[3], d2[3];

int[3] d4, d5;
```

<!-- Having two different syntaxes for array declarations, with one that splits the type like an infinitive, sets the stage for the production of inconsistent and potentially confusing code. By making the C\-style syntax illegal, consistency is enforced. Code readability is a key component of maintainability. -->

型を不定詞のように分割し、配列宣言に2つの構文を用意することは、
一貫性のなさと混乱を生みかねない状況を生み出します。
Cスタイルの構文を違法にすることで、一貫性が強制されます。
コードの可読性は保守性の重要な要因です。

<!-- Another difference between `d0` and `c0` is that the elements of `d0` will be default initialized no matter where or how it’s declared. Module scope, local scope, static local… it doesn’t matter. Unless the compiler is told otherwise, variables in D are always default initialized to the predefined value specified by [the `init` property of each type](https://dlang.org/spec/property.html#init). Array elements are initialized to the `init` property of the element type. As it happens, `int.init == 0`. Translate **definit.c** to D and see it for yourself (open up [run.dlang.io and give it a go](https://run.dlang.io/)). -->

`d0`と`c0`のもうひとつの相違点は、
`d0`の要素はそれがどこでどのように宣言されたかにかかわらずデフォルトで初期化されるということです。
モジュールスコープ、ローカルスコープ、`static`ローカル……関係ありません。
とくべつコンパイラに指示がなされない限り、Dの変数は常にデフォルトで
[各型の`init`プロパティ](https://dlang.org/spec/property.html#init)
で指定された値に初期化されます。
配列の要素は要素の型の`init`プロパティに初期化されます。
偶然にも、`int.init == 0`です。
**definit.c**をDに翻訳してみましょう（そして[run.dlang.io を開き、試してみましょう](https://run.dlang.io/)）。

<!-- When translating C to D, this default initialization business is a subtle gotcha. Consider this innocently contrived C snippet: -->

CからDへの翻訳をする際、このデフォルト初期化関連の物事で少し混乱することがあります。
以下のようなちょっと作為的なコードを考えてみます。

<!-- ```d
// static variables are default initialized to 0 in C

static float vertex[3];

some_func_that_expects_inited_vert(vertex);
``` -->

```c
// Cではstaticな変数はデフォルトで0に初期化されます

static float vertex[3];

some_func_that_expects_inited_vert(vertex);
```

<!-- A direct translation straight to D will not produce the expected result, as `float.init == float.nan`, not `0.0f`! -->

`float.init == float.nan`であり`0.0f`ではないため、
Dへ直訳してしまうと期待したような結果は得られません！

<!-- When translating between the two languages, always be aware of which C variables are not explicitly initialized, which are expected to be initialized, and [the default initialization value for each of the basic types](https://dlang.org/spec/type.html#basic-data-types) in D. Failure to account for the subtleties may well lead to debugging sessions of the hair\-pulling variety. -->

ふたつの言語間で翻訳をする際には、
明示的に初期化されていないCの変数が初期化されることを期待されていないか、
そしてDの
[各型のデフォルト初期値](https://dlang.org/spec/type.html#basic-data-types)
に気をつけなければなりません。
ここを忘れるとデバッグで禿げ上がることになります。

<!-- Default initialization can easily be disabled in D with `= void` in the declaration. This is particularly useful for arrays that are going to be loaded with values before they’re read, or that contain elements with an `init` value that isn’t very useful as anything other than a marker of uninitialized variables. -->

Dにおいてデフォルトの初期化は宣言に`= void`をつけることで簡単に無効化できます。
これは変数が読まれる前にかならず値がロードされるとき、
もしくは`init`の値が入っていると未初期化よりも都合が悪いときに活用できます。

```d
float[16] matrix = void;

setIdentity(matrix);
```

<!-- On a side note, the purpose of default initialization is not to provide a convenient default value, but to make uninitialized variables stand out (a fact you may come to appreciate in a future debugging session). A common mistake is to assume that types like `float` and `char`, with their “not a number” (`float.nan`) and invalid UTF–8 (`0xFF`) initializers, are the oddball outliers. Not so. Those values are great markers of uninitialized memory because they aren’t useful for much else. It’s the integer types (and `bool`) that break the pattern. For these types, the entire range of values has potential meaning, so there’s no single value that universally shouts “Hey! I’m uninitialized!”. As such, integer and `bool` variables are often left with their default initializer since `0` and `false` are frequently the values one would pick for explicit initialization for those types. Floating point and character values, however, should generally be explicitly initialized or assigned to as soon as possible. -->

ちなみに、デフォルト初期化の目的は便利なデフォルト値を提供することではなく、
未初期化の値をわかりやすくすることです
（将来あなたがデバッグをするとき感謝することになるでしょう）。
よくある勘違いは、`float`や`char`の「非数」（`float.nan`）や無効なUTF-8（`0xFF`）
などという初期値を奇妙な外れ値だと思うことです。
そうではありません。
これらの値はそれ以外で役に立たないために、未初期化メモリの素晴らしい目印になるのです。
整数型（と`bool`）はこのパターンを乱しています。
これらの型は、その値のすべての範囲が意味を持つため、普遍的に「おーい！ボクは初期化されてないよ！」
と叫んでくれるような単一の値がありません。
整数や`bool`変数は、`0`や`false`が明示的な初期化の際によく選ばれる値であるため、
しばしばデフォルト初期値のままにされます。
浮動小数点数や文字型は一般に、できるだけ速やかに明示的初期化や代入をしなければなりません。

<!-- ### Explicit array initialization -->

### 配列の明示的初期化

<!-- C allows arrays to be explicitly initialized in different ways: -->

Cでは配列の明示的初期化がさまざまな方法でできます。

```c
int ci0[3] = {0, 1, 2};  // [0, 1, 2]

int ci1[3] = {1};        // [1, 0, 0]

int ci2[]  = {0, 1, 2};  // [0, 1, 2]

int ci3[3] = {[2] = 2, [0] = 1}; // [1, 0, 2]

int ci4[]  = {[2] = 2, [0] = 1}; // [1, 0, 2]
```

<!-- What we can see here is: -->

ここからわかることは以下のとおりです。

<!-- *   elements are initialized sequentially with the constant values in the initializer list
*   if there are fewer values in the list than array elements, then all remaining elements are initialized to `0` (as seen in `ci1`)
*   if the array length is omitted from the declaration, the array takes the length of the initializer list (`ci2`)
*   designated initializers, as in `ci3`, allow specific elements to be initialized with `[index] = value` pairs, and indexes not in the list are initialized to `0`
*   when the length is omitted from the declaration and a designated initializer is used, the array length is based on the highest index in the initializer and elements at all unlisted indexes are initialized to `0`, as seen in `ci4` -->

- 要素は初期化子リストの定数値で順に初期化されます
- リストの要素が配列の要素よりも少ない時は、残りの要素はすべて`0`で初期化されます（`ci1`のとおりです）
- 配列の長さが宣言で省略されている場合、配列は初期化子リストの長さをとります（`ci2`）
- `ci3`のような指示初期化子では特定の要素の`[index] = value`というペアでの初期化が可能で、
    リストに現れなかったインデックスは`0`で初期化されます
- 長さが宣言で省略されており指示初期化子が使われている場合は`ci4`のように、
    配列の長さは初期化子の最大のインデックスを元に決まり、
    リストにないインデックスは`0`で初期化されます

<!-- Initializers aren’t supposed to be longer than the array (`gcc` gives a warning and initializes a three\-element array to the first three initializers in the list, ignoring the rest). -->

初期化子は配列より長くなることを想定されていません（`gcc`では警告を出した上で、
たとえば3要素の配列なら初期化子リストの最初の3つを使って初期化して、残りを無視します）

<!-- Note that it’s possible to mix the designated and non\-designated syntaxes in a single initializer: -->

ちなみに指示初期化子とそうでないものとを混ぜて使うこともできます。

```c
// [0, 1, 0, 5, 0, 0, 0, 8, 44]

int ci5[] = {0, 1, [3] = 5, [7] = 8, 44};
```

<!-- Each value without a designation is applied in sequential order as normal. If there is a designated initializer immediately preceding it, then it becomes the value for the next index, and all other elements are initialized to `0`. Here, `0` and `1` go to indexes `ci5[0]` and `ci5[1]` as normal, since they are the first two values in the list. Next comes a designator for `ci5[3]`, so `ci5[2]` has no corresponding value in this list and is initialized to `0`. Next comes the designator for `ci5[7]`.  We have skipped `ci5[4]`, `ci5[5]`, and `ci5[6]`,  so they are all initialized to `0`. Finally, `44` lacks a designator, but immediately follows `[7]`, so it becomes the value for the element at `ci5[8]`. In the end, `ci5` is initialized to a length of `9` elements. -->

指示のない普通の初期化子は通常通り出現順に適用されます。
指示初期化子がその直前にある場合、それは指示初期化子の次のインデックスの値になり、
それ以外の要素は`0`で初期化されます。
この例で、`0`と`1`はリストの値の最初の2つのため通常通り`ci5[0]`と`ci5[1]`を指します。
次に`ci5[3]`に対する指示初期化子が来るため、このリストに`ci5[2]`に対応する値はなく、`0`に初期化されます。
次には`ci5[7]`に対する指示初期化子が来ます。
`ci5[4]`、`ci5[5]`、`ci5[6]`はスキップされたので、ぜんぶ`0`に初期化されます。
最後に`44`は指示がなく、`[7]`の直後にあるため、この値は`ci5[8]`の値になります。
最終的に`ci5`は`9`要素で初期化されます。

<!-- Also note that designated array initializers were added to C in C99. Some C compiler versions either don’t support the syntax or require a special command line flag to enable it. As such, it’s probably not something you’ll encounter very much in the wild, but still useful to know about when you do. -->

指示配列初期化子はC99でCに追加されました。
Cコンパイラのバージョンによってはサポートされていなかったり、
有効化するためにコマンドラインフラグを必要としたりします。
現実のコードで遭遇するようなものではないかもしれませんが、あなたのC言語歴を推し量る役には立ちます。

<!-- Translating all of these to D opens the door to more gotchas. Thankfully, the first one is a compiler error and won’t cause any heisenbugs down the road: -->

これらをDに翻訳しようとするとさらに混乱します。
幸いにも最初のひとつはコンパイルエラーになり、ハイゼンバグは未然に防がれます。

```d
int[3] wrong = {0, 1, 2};

int[3] right = [0, 1, 2];
```

<!-- Array initializers in D are array literals. The same syntax can be used to pass anonymous arrays to functions, as in `writeln([0, 1, 2])`. For the curious, the declaration of `wrong` produces the following compiler error: -->

Dにおける配列初期化子は配列リテラルです。
関数に無名配列を渡すときも、`writeln([0, 1, 2])`のように同じ構文が使えます。
興味深いことに、`wrong`の宣言は以下のコンパイルエラーを出します。

```
Error: a struct is not a valid initializer for a int[3]
```

<!-- The `{}` syntax [is used for `struct` initialization](https://dlang.org/spec/struct.html#static_struct_init) in D (not to be confused with struct literals, which can also [be used to initialize a `struct` instance](https://dlang.org/spec/struct.html#struct-literal)). -->

Dにおいて`{}`構文は
[`struct`の初期化に使われます](https://dlang.org/spec/struct.html#static_struct_init)
（
[`struct`のインスタンスの初期化にも使える](https://dlang.org/spec/struct.html#struct-literal)
構造体リテラルと混同しないでください
）。

<!-- The next surprise comes in the translation of `ci1`. -->

`ci1`の翻訳をしたときにも驚くことでしょう。

```d
// int ci1[3] = {1};

int[3] di1 = [1];
```

<!-- This actually produces a compiler error: -->

これはコンパイラエラーを出します。

```
Error: mismatched array lengths, 3 and 1
```

<!-- What gives? First, take a look at the translation of `ci2`: -->

一体どうなっているんでしょう？
まず、`ci2`の翻訳を見てみましょう。

```d
// int ci2[] = {0, 1, 2};

int[] di2 = [0, 1, 2];
```

<!-- In the C code, there is no difference between `ci1` and `ci2`. They both are fixed\-length, three\-element arrays allocated on the stack. In D, this is one case where that general rule of thumb about pasting C code into D source modules breaks down. -->

Cのコードにおいて、`ci1`と`ci2`の間に違いはありません。
両方とも固定長で、スタックに確保される3要素の配列です。
これがDにおける、CのコードをDのモジュールにコピペしてくるという経験則が壊れるケースのひとつです。

<!-- Unlike C, D [actually makes a distinction between arrays](https://dlang.org/spec/arrays.html#static-arrays) of types `int[3]` and `int[]`. The former is, like C, a fixed\-length array, commonly referred to in D as a static array. The latter, unlike C, is a dynamic\-length array, commonly referred to as a dynamic array or a slice. Its length can grow and shrink as needed. -->

Cと違い、Dでは`int[3]`と`int[]`の間に違いが存在します。
前者はCのような固定長配列であり、一般にDでは静的配列と呼ばれます。
後者はCと違い可変長配列であり、動的配列やスライスと呼ばれています。
その長さは必要に応じて伸びたり縮んだりします。

<!-- Initializers for static arrays must have the same length as the array. D simply does not allow initializers shorter than the declared array length. Dynamic arrays take the length of their initializers. `di2` is initialized with three elements, but more can be appended. Moreover, the initializer is not required for a dynamic array. In C, `int foo[];` is illegal, as the length can only be omitted from the declaration when an initializer is present. -->

静的配列の初期化子は配列と同じ長さでなければなりません。
Dは宣言された長さより短い初期化子を単に禁止しています。
動的配列は初期化子から長さをとります。
`di2`は3要素で初期化されますが、さらに後から追加することもできます。
さらに、動的配列に初期化子は必須ではありません。
Cにおいては、配列の長さの宣言が省略できるのは初期化子がある場合のみなので、`int foo[]`は違法です。

<!-- ```d
// gcc says "error: array size missing in 'illegalC'"

// int illegalC\[\]

int\[\] legalD;

legalD ~= 10;
``` -->

```d
// gccは"error: array size missing in 'illegalC'"と出力します

// int illegalC[]

int[] legalD;

legalD ~= 10;
```

<!-- `legalD` is an empty array, with no memory allocated for its elements. Elements can be added via the append operator, `~=`. -->

`legalD`は空の配列であり、その要素のためのメモリは確保されていません。
要素は追加演算子`~=`で追加できます。

<!-- Memory for dynamic arrays is allocated at the point of declaration only when an explicit initializer is provided, as with `di2`. If no initializer is present, memory is allocated when the first element is appended. By default, dynamic array memory is allocated from the GC heap (though the compiler may determine that it’s safe to allocate on the stack as an optimization) and space for more elements than needed is initialized in order to reduce the need for future allocations ([the `reserve` function can be used](https://dlang.org/phobos/object.html#.reserve) to allocate a large block in one go, without initializing any elements). Appended elements go into the preallocated slots until none remain, then the next append triggers a new allocation. [Steven Schveighoffer’s excellent array article](https://dlang.org/articles/d-array-article.html) goes into the details, and also describes array features we’ll touch on in the next part. -->

`di2`のように明示的な初期化子がある場合、動的配列のメモリは宣言がされた時点で確保されます。
初期化子がない場合、メモリは最初の要素が追加された時点で確保されます。
デフォルトでは、動的配列のメモリはGCヒープに確保され
（ただし最適化の結果安全にスタックに確保できるとコンパイラが判断することもあります）、
その後の割り当てをへらすために要素数に対して必要なメモリよりも多くのメモリが初期化されます
（要素の初期化をせずに大きいブロックを一度に確保するのに
[`reserve`関数が使えます](https://dlang.org/phobos/object.html#.reserve)）。
追加された要素は事前に確保されたスロットがなくなるまでそこに配置され、
その次の追加が新しい領域の確保を引き起こします。
[Steven Schveighofferの配列に関する素晴らしい記事](https://dlang.org/articles/d-array-article.html)
ではさらに詳細に触れられており、次のパートで扱う配列の機能についても説明しています
（訳注：[翻訳版はこちら](http://www.kmonos.net/alang/d/d-array-article.html)）。

<!-- Often, when translating a declaration like `ci2` to D, the difference between the fixed\-length, stack\-allocated C array and the dynamic\-length, GC\-allocated D array isn’t going to matter one iota. One case where it does matter is when the D array is declared inside a function marked `@nogc`: -->

多くの場合、固定長のスタックに確保されるCの配列と可変長のGCで確保されるDの配列の違いは、
`ci2`のような宣言をDに翻訳する時は大きな問題になりません。
問題になるのはDの配列が`@nogc`付きの関数のなかで宣言されたときです。

```d
@nogc void main()

{

    int[] di2 = [0, 1, 2];

}
```

<!-- _[Try it online](https://run.dlang.io/is/4AO9vT)_ -->

_[オンラインで試す](https://run.dlang.io/is/4AO9vT)_

<!-- The compiler ain’t letting you get away with that: -->

コンパイラはズルを許しません。

```
Error: array literal in @nogc function D main may cause a GC allocation
```

<!-- The same error isn’t triggered when the array is static, since it’s allocated on the stack and the literal elements are just shoved right in there. New C programmers coming to D for the first time tend to reach for `@nogc` almost as if it goes against their very nature not to, so this is something they will bump into until they eventually come to the realization that [the GC is not the enemy of the people](https://dlang.org/blog/the-gc-series/). -->

配列がstaticのときは、リテラルの要素はその場で解決されスタックに確保されるため、
同じようなエラーは起きません。
DにやってきたばかりのCプログラマーは最初、
そうしないことがまるで自然に反しているかのようになんにでも`@nogc`を付けたがる傾向があり、
そのため[GCが人類の敵ではない](https://dlang.org/blog/the-gc-series/)
とわかるまで壁にぶち当たり続けることになります（訳注：[翻訳版はこちら](/tags/dlang_gc_series/)）。

<!-- To wrap this up, that big paragraph on designated array initializers in C is about to pull double duty. D also supports designated array initializers, just with a different syntax. -->

これを解決するために先程のCの指示初期化子の大きなパラグラフが役立ちます。
Dは指示初期化子を、Cと違う構文でサポートしています。

```d
// [0, 1, 0, 5, 0, 0, 0, 8, 44]

// int ci5[] = {0, 1, [3] = 5, [7] = 8, 44};

int[] di5 = [0, 1, 3:5, 7:8, 44];

int[9] di6 = [0, 1, 3:5, 7:8, 44];
```

<!-- _[Try it online](https://run.dlang.io/is/4kAt6u)_ -->

_[オンラインで試す](https://run.dlang.io/is/4kAt6u)_

<!-- It works with both static and dynamic arrays, following the same rules and producing the same initialization values as in C. -->

これは静的、動的の両方で動作し、Cと同じルールに準じて、Cと同じ初期値になります。

<!-- The main takeaways from this section are: -->

このセクションで主に覚えておいてほしいことは次のとおりです。

<!-- *   there is a distinction in D between static and dynamic arrays, in C there is not
*   static arrays are allocated on the stack
*   dynamic arrays are allocated on the GC heap
*   uninitialized static arrays are default initialized to the `init` property of the array elements
*   dynamic arrays can be explicitly initialized and take the length of the initializer
*   dynamic arrays cannot be explicitly initialized in `@nogc` scopes
*   uninitialized dynamic arrays are empty -->

- Dにおいて静的配列と、Cにない動的配列には、違いがあります
- 静的配列はスタックに確保されます
- 動的配列はGCヒープに確保されます
- 未初期化の静的配列はデフォルトで配列の要素の`init`プロパティで初期化されます
- 動的配列は明示的に初期化が可能であり、初期化子から長さをとります
- 動的配列は`@nogc`スコープ内での明示的初期化ができません
- 未初期化の動的配列は空です


<!-- ### This is the time on the D Blog where we dance -->

### 次回に続く

<!-- There are a lot more words in the preceding sections than I had originally intended to write about array declarations and initialization, and I still have quite a bit more to say about arrays. In the next post, we’ll look at multidimensional arrays, the anatomy of a D array, and what it means when people say that “C arrays decay to pointers”. Those last two topics will set the stage for part three, where we’ll dig into the art of passing D and C arrays across the language divide. -->

当初の予定より配列の宣言と初期化についてたくさん書くことになりました。
そしてまだまだ配列について書くことはたくさんあります。
次の記事では、多次元配列、Dの配列の内部構造、
そして人々が「Cの配列はただのポインタでしかない」という時意味していることについて見ていきます。
最後の2つは、DとCの配列を言語間でやり取りする技術について触れるパート3への伏線になっています。
