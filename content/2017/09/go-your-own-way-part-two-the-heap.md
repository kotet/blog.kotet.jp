---
date: 2017-09-30
aliases:
- /2017/09/30/go-your-own-way-part-two-the-heap.html
title: "オウン・ウェイ - GCを避けたアロケーション (Part2: ヒープ)【翻訳】"
tags:
- dlang
- tech
- translation
- dlang_gc_series
- d_blog
excerpt: "この投稿はD プログラミング言語のガベージコレクションについての進行中のシリーズの一部であり、 GCの外のメモリのアロケーションに関する2番目の投稿です。 パート1ではスタックアロケーションについて論じました。 今回は非GCヒープからのメモリのアロケーティングについて見て行きます。"
---

この記事は、

[Go Your Own Way (Part Two: The Heap) – The D Blog](https://dlang.org/blog/2017/09/25/go-your-own-way-part-two-the-heap/)

を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

今回からソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/kotet/blog.kotet.jp)だ!

---

<!-- This post is part of [an ongoing series](https://dlang.org/blog/the-gc-series/)
on garbage collection in the D Programming Language,
and the second of two regarding the allocation of memory outside of the GC.
[Part One](https://dlang.org/blog/2017/07/07/go-your-own-way-part-one-the-stack/)
discusses stack allocation. Here, we’ll look at allocating memory from the non-GC heap. -->

この投稿はD プログラミング言語のガベージコレクションについての
[進行中のシリーズ](https://dlang.org/blog/the-gc-series/)の一部であり、
GCの外のメモリのアロケーションに関する2番目の投稿です。
[パート1](/2017/07/go-your-own-way-part-one-the-stack)[^1]
ではスタックアロケーションについて論じました。
今回は非GCヒープからのメモリのアロケーティングについて見て行きます。

[^1]:原文:[Go Your Own Way (Part One: The Stack) – The D Blog](https://dlang.org/blog/2017/07/07/go-your-own-way-part-one-the-stack/)

<!-- Although this is only my fourth post in the series,
it’s the third in which I talk about ways to _avoid_ the GC.
Lest anyone jump to the wrong conclusion,
that fact does not signify an intent to warn programmers away from the D garbage collector.
Quite the contrary.
Knowing how and when to avoid the GC is integral to understanding how to efficiently embrace it. -->

まだシリーズ4番目の投稿なのにも関わらず、
これはGCを**回避する**方法について話す3番目の投稿です。
早合点しないで欲しいのですが、
この事実はDのガベージコレクタから離れようとするプログラマに対する警告ではありません。
全く逆のものです。
いつ、どのようにGCを回避するか知ることは、
どのようにGCを効率的に受け入れるかを理解するために不可欠なものです。

<!-- To hammer home a repeated point, efficient garbage collection requires reducing stress on the GC.
As highlighted in [the first](https://dlang.org/blog/2017/03/20/dont-fear-the-reaper/)
and subsequent posts in this series, that doesn’t necessarily mean avoiding it completely.
It means being judicious in how often and how much GC memory is allocated.
Fewer GC allocations means fewer opportunities for a collection to trigger.
Less total memory allocated from the GC heap means less total memory to scan. -->

何度でも力説しますが、効率的なガベージコレクションにはGCへのストレスを減らすことが必要です。
[最初](/2017/04/dont-fear-the-reaper)[^2]からこのシリーズで続けて強調しているように、
それは必ずしもGCを完全に回避することを意味しません。
どれくらいの頻度で、どれくらいの量のGCメモリをアロケートするかについて考えるということです。
GCアロケーションの回数を減らす事はコレクションが発生する可能性を減らす事を意味します。
GCヒープからアロケートする量を減らす事はスキャンするメモリの量を減らす事を意味します。

[^2]:原文:[Don’t Fear the Reaper – The D Blog](https://dlang.org/blog/2017/03/20/dont-fear-the-reaper/)

<!-- It’s impossible to make any accurate,
generalized statement about what sort of applications may or may not feel an impact from the GC;
such is highly application specific.
What can be said is that it may not be necessary for many applications to temporarily avoid or disable the GC,
but when it is, it’s important to know how.
Allocating from the stack is an obvious approach, but D also allows allocating from the non-GC heap. -->

どのような種類のアプリケーションがGCの影響を受けるのか、受けないのかを、正確かつ一般的に述べる事はできません。
それはアプリケーションによります。
ただ、多くのアプリケーションでは一時的にGCを回避したり無効化したりする必要はないものの、
必要な時にどうすればいいのか知る事は重要だ、という事は言えます。
スタックからのアロケーティングは明らかなアプローチですが、Dでは非GCヒープからのアロケーティングも可能です。

<!-- ### The ubiquitous C -->

### 遍在するC

<!-- For better or worse, C is everywhere.
Any software written today, no matter the source language, is probably interacting with a C API at some level.
Despite the C specification defining no standard ABI,
its platform-specific quirks and differences are understood well enough that most languages know how to interface with it.
D is no exception. In fact, all D programs have access to the C standard library by default. -->

良くも悪くも、Cはあらゆるところに存在しています。
こんにち書かれるソフトウェアは、ソースの言語にかかわらず殆どがCのAPIといくらかのレベルで交流するものです。
Cの仕様書が標準ABIを定義していないにもかかわらず、プラットフォーム特有の癖や違いはよく理解されており、多くの言語ではCとやりとりができます。
Dも例外ではありません。
実際、全てのD言語のプログラムはデフォルトでCの標準ライブラリにアクセスできます。

<!-- [The `core.stdc` package](https://github.com/dlang/druntime/tree/master/src/core/stdc),
part of [DRuntime](https://github.com/dlang/druntime),
is a collection of D modules translated from C standard library headers.
When a D executable is linked, the C standard library is linked along with it.
All that need be done to gain access is to import the appropriate modules. -->

[DRuntime](https://github.com/dlang/druntime)の一部である
[`core.stdc`パッケージ](https://github.com/dlang/druntime/tree/master/src/core/stdc)は、
Cの標準ライブラリから変換したDのモジュールのコレクションです。
Dの実行ファイルがリンクされる時、Cの標準ライブラリも一緒にリンクされます。
アクセスに必要なことは、適切なモジュールのインポートだけです。

<!-- 
```d
import core.stdc.stdio : puts;
void main() 
{
    puts("Hello C standard library.");
}
```
-->

```d
import core.stdc.stdio : puts;
void main() 
{
    puts("Hello C standard library.");
}
```

<!-- Some who are new to D may be laboring under a misunderstanding that
functions which call into C require an `extern(C)` annotation, or,
after Walter’s Bright’s recent ‘[D as a Better C](https://dlang.org/blog/2017/08/23/d-as-a-better-c/)’ article,
must be compiled with `-betterC` on the command line.
Neither is true.
Normal D functions can call into C without any special effort beyond the presence of an `extern(C)` declaration
of the function being called.
In the snippet above,
[the declaration of `puts`](https://github.com/dlang/druntime/blob/master/src/core/stdc/stdio.d#L1063)
is in the `core.stdc.stdio` module, and that’s all we need to call it. -->

Dに慣れていない人の中には、Cの関数を呼ぶ時は`extern(C)`アノテーションをつけたり、
Walter Brightの最新の‘[D as a Better C](https://dlang.org/blog/2017/08/23/d-as-a-better-c/)’記事のように、
コマンドラインから`-betterC`でコンパイルする必要があるという誤解により無駄な労力を払っている人がいます。
そのどちらも正しくありません。
通常のDの関数は呼ばれる関数の`extern(C)`宣言以外何ら特殊な努力なしにCの関数を呼ぶことができます。
上記のスニペットでは、
[`puts`の宣言](https://github.com/dlang/druntime/blob/master/src/core/stdc/stdio.d#L1063)
は`core.stdc.stdio`の中にあり、それ以上何もしなくても呼び出しができます。

<!-- (_For a deeper dive into what `extern(C)` and `-betterC` actually do,
see [the extended content](http://dblog-ext.info/articles/gc-part4.html) from this post at
[dblog-ext.info](http://dblog-ext.info/).)_ -->

(`extern(C)`や`-betterC`が実際に何をしているのか詳しく知りたい場合、
[dblog-ext.info](http://dblog-ext.info/)にあるこの投稿の
[拡張コンテンツ](http://dblog-ext.info/articles/gc-part4.html)をご覧ください。)

<!-- #### `malloc` and friends -->

#### `malloc`とゆかいななかまたち

<!-- Given that we have access to C’s standard library in D, we therefore have access to the functions
`malloc`, `calloc`, `realloc` and `free`.
All of these can be made available by importing `core.stdc.stdlib`.
And thanks to D’s slicing magic, using these functions as the foundation of a non-GC memory management strategy is a breeze.
-->

DからCの標準ライブラリにアクセスできるという事は、つまり`malloc`、`calloc`、`realloc`、`free`などの関数にもアクセスできるという事です。
これら全ては`core.stdc.stdlib`をインポートする事で利用できるようになります。
また、Dのスライスマジックのおかげで、これらの関数を非GCメモリ管理戦略の基礎として使う事は非常に簡単になります。

<!-- 
```d
import core.stdc.stdlib;
void main() 
{
    enum totalInts = 10;
    
    // Allocate memory for 10 ints
    int* intPtr = cast(int*)malloc(int.sizeof * totalInts);

    // assert(0) (and assert(false)) will always remain in the binary,
    // even when asserts are disabled, which makes it nice for handling
    // malloc failures    
    if(!intPtr) assert(0, "Out of memory!");

    // Free when the function exits. Not necessary for this example, but
    // a potentially useful strategy for temporary allocations in functions 
    // other than main.
    scope(exit) free(intPtr);

    // Slice the D pointer to get a more manageable length/pointer pair.
    int[] intArray = intPtr[0 .. totalInts];
}
```
-->

```d
import core.stdc.stdlib;
void main() 
{
    enum totalInts = 10;
    
    // int 10個分のメモリをアロケート
    int* intPtr = cast(int*)malloc(int.sizeof * totalInts);

    // assert(0) (と assert(false))は常にバイナリの中に残り、
    // アサートが無効の場合でも、mallocの失敗をハンドリングできます
    if(!intPtr) assert(0, "Out of memory!");

    // 関数を抜ける時に解放。この例では必要ありませんが、
    // main以外の関数での一時アロケーション戦略
    // において便利です。
    scope(exit) free(intPtr);

    // より扱いやすい長さとポインタのペアを得るためDのポインタをスライス
    int[] intArray = intPtr[0 .. totalInts];
}
```

<!-- Not only does this bypass the GC, it also bypasses D’s default initialization.
A GC-allocated array of type `T` would have all of its elements initialized to `T.init`, which is `0` for `int`.
If mimicking D’s default initialization is the desired behavior, more work needs to be done.
In this example, we could replace `malloc` with `calloc` for the same effect, but that would only be correct for integrals.
`float.init`, for example, is `float.nan` rather than `0.0f`. We’ll come back to this later in the article.-->

これはGCだけでなく、Dのデフォルトの初期化も回避します。
GCによりアロケートされた型`T`の配列は全ての要素が`T.init`に初期化されます。
`int`の場合`0`になります。
Dのデフォルトの初期化と同じ振る舞いを望むなら、一手間必要です。
この例では`malloc`を`calloc`に置き換えることで同じ効果が得られますが、これは整数型の場合だけの話です。
例えば`float.init`は`0.0f`ではなく`float.nan`です。
これについては後で述べます。

<!-- (_For more on handling failed memory allocations,
see [the extended content](http://dblog-ext.info/articles/gc-part4.html) from this post._) -->

(メモリアロケーションの失敗のハンドリングについての詳細はこの投稿の[拡張コンテンツ](http://dblog-ext.info/articles/gc-part4.html)を確認してください。)

<!-- Of course, it would be more idiomatic to wrap both `malloc` and `free` and work with slices of memory.
A minimal example: -->

もちろん、`malloc`と`free`をメモリのスライス用にラップしてよりイディオマティックにできます。
単純な例です:

<!--
```d
import core.stdc.stdlib;

// Allocate a block of untyped bytes that can be managed
// as a slice.
void[] allocate(size_t size)
{
    // malloc(0) is implementation defined (might return null 
    // or an address), but is almost certainly not what we want.
    assert(size != 0);

    void* ptr = malloc(size);
    if(!ptr) assert(0, "Out of memory!");
    
    // Return a slice of the pointer so that the address is coupled
    // with the size of the memory block.
    return ptr[0 .. size];
}

T[] allocArray(T)(size_t count) 
{ 
    // Make sure to account for the size of the
    // array element type!
    return cast(T[])allocate(T.sizeof * count); 
}

// Two versions of deallocate for convenience
void deallocate(void* ptr)
{	
    // free handles null pointers fine.
    free(ptr);
}

void deallocate(void[] mem) 
{ 
    deallocate(mem.ptr); 
}

void main() {
    import std.stdio : writeln;
    int[] ints = allocArray!int(10);
    scope(exit) deallocate(ints);
	
    foreach(i; 0 .. 10) {
        ints[i] = i;
    }

    foreach(i; ints[]) {
        writeln(i);
    }
}
```
-->

```d
import core.stdc.stdlib;

// スライスとして管理できる型のないバイト列の
// ブロックをアロケートします。
void[] allocate(size_t size)
{
    // malloc(0)の実装は定義されています(nullまたはアドレスを返す)が、
    // まず求めるものではありません。
    assert(size != 0);

    void* ptr = malloc(size);
    if(!ptr) assert(0, "Out of memory!");
    
    // メモリブロックのサイズと結びつけられたアドレスである
    // ポインタのスライスを返します。
    return ptr[0 .. size];
}

T[] allocArray(T)(size_t count) 
{ 
    // 配列の要素の型のサイズを考慮に入れてください！
    return cast(T[])allocate(T.sizeof * count); 
}

// 利便性のため2つあるデアロケート
void deallocate(void* ptr)
{	
    // freeはnullポインタをよしなに扱ってくれます
    free(ptr);
}

void deallocate(void[] mem) 
{ 
    deallocate(mem.ptr); 
}

void main() {
    import std.stdio : writeln;
    int[] ints = allocArray!int(10);
    scope(exit) deallocate(ints);
	
    foreach(i; 0 .. 10) {
        ints[i] = i;
    }

    foreach(i; ints[]) {
        writeln(i);
    }
}
```

<!-- `allocate` returns `void[]` rather than `void*` because it carries with it the number of allocated bytes
in its `length` property. In this case, since we’re allocating an array, we could instead rewrite `allocArray`
to slice the returned pointer immediately, but anyone calling `allocate` directly would still have to take into
account the size of the memory.
The disassociation between arrays and their length in C is
[a major source of bugs](https://digitalmars.com/articles/b44.html),
so the sooner we can associate them the better.
Toss in some templates for `calloc` and `realloc` and you’ve got the foundation of a memory manager based on the C heap. -->

`void[]`はアロケートされたバイト数を`length`プロパティにもつため、
`allocate`は`void*`ではなく`void[]`を返します。
今回の場合配列をアロケートするので、スライスを返す`allocArray`の代わりに直接ポインタを返すよう書き換えることもできますが、
`allocate`を直接呼ぶ人はメモリのサイズを考慮し続けなければなりません。
Cにおいて配列とその長さの乖離は
[主要なバグの原因](https://digitalmars.com/articles/b44.html)であり、
したがってそれらを結びつけるのは早ければ早いほど望ましいことです。
`calloc`や`realloc`のテンプレートを除けば、あなたはCのヒープを基にしたメモリマネージャの基礎を習得しました。

<!-- On a side note, the preceding three snippets (yes, even the one with the `allocArray` template)
work with and without `-betterC`. But from here on out, we’ll restrict ourselves to features in normal D code. -->

ついでに言うと、前述の3つのスニペット(そう、`allocArray`テンプレートもです)は`-betterC`があってもなくても動作します。しかし通常のDのコードでは、しだいに機能を制限されてきます。

<!-- #### Avoid leaking like a sieve -->

#### リークを防ぐ

<!-- When working directly with slices of memory allocated outside of the GC heap,
be careful about appending, concatenating, and resizing.
By default, the append (`~=`) and concatenate (`~`) operators on built-in dynamic arrays and slices
will allocate from the GC heap.
Concatenation will always allocate a new memory block for the combined string.
Normally, the append operator will allocate to expand the backing memory only when it needs to.
As the following example demonstrates, it always needs to when it’s given a slice of non-GC memory.-->

GCヒープの外からアロケートされたメモリのスライスを直接扱うときは、追加、結合、リサイズに注意してください。
デフォルトでは動的配列とスライス組み込みの追加(`~=`)と結合(`~`)演算子はGCヒープからアロケートをします。
結合は常に結合した結果の文字列のための新しいメモリブロックをアロケートします。
通常、追加演算子は必要な時のみメモリ拡張のためアロケートをします。
下記の例が示すように、非GCメモリのスライスが与えられた時は常にアロケーションが必要です。

<!--
```d
import core.stdc.stdlib : malloc;
import std.stdio : writeln;

void main()
{
    int[] ints = (cast(int*)malloc(int.sizeof * 10))[0 .. 10];
    writeln("Capacity: ", ints.capacity);

    // Save the array pointer for comparison
    int* ptr = ints.ptr;
    ints ~= 22;
    writeln(ptr == ints.ptr);
}
```
-->

```d
import core.stdc.stdlib : malloc;
import std.stdio : writeln;

void main()
{
    int[] ints = (cast(int*)malloc(int.sizeof * 10))[0 .. 10];
    writeln("Capacity: ", ints.capacity);

    // 比較のため配列ポインタを保存します
    int* ptr = ints.ptr;
    ints ~= 22;
    writeln(ptr == ints.ptr);
}
```

<!-- This should print the following: -->

これは以下のような結果を出力します:

<!--
```
Capacity: 0
false
```
-->

```
Capacity: 0
false
```

<!-- A capacity of `0` on a slice indicates that the next append will trigger an allocation.
Arrays allocated from the GC heap normally have space for extra elements beyond what was requested,
meaning some appending can occur without triggering a new allocation.
It’s more like a property of the memory backing the array rather than of the array itself.
Memory allocated from the GC does some internal bookkeeping to keep track of how many elements the memory block can hold
so that it knows at any given time if a new allocation is needed.
Here, because the memory for `ints` was not allocated by the GC,
none of that bookkeeping is being done by the runtime on the existing memory block,
so it _must_ allocate on the next append
(see Steven Schveighoffer’s ’[D Slices](https://dlang.org/d-array-article.html) article for more info). -->

スライスのキャパシティが`0`というのは、次の追加はアロケーション引き起こす、ということを示しています。
GCヒープからアロケートされた配列は通常要求されたよりも多い追加要素のためのスペースを持ち、追加は新しいアロケーションを伴わず起きることがあります。
これは配列そのものよりもその背後のメモリの性質に似ています。
GCからアロケートされたメモリは、メモリブロックがいくつの要素を保持できるかを追跡するために内部で計算と記録を行うため、新しくアロケーションが必要かどうかをいつでも知ることができます。
ここで、`ints`のメモリはGCからアロケートされたものでは無いため、実行時に存在するメモリブロックには計算が行われておらず、
次の追加ではアロケートを**しなければなりません**(より詳しい情報はSteven Schveighofferの[D言語のスライス機能](http://www.kmonos.net/alang/d/d-array-article.html)[^3]の記事を見てください)。

[^3]:原文:[D Slices - D Programming Language](https://dlang.org/d-array-article.html)

<!-- This isn’t necessarily a bad thing when it’s the desired behavior,
but anyone who’s not prepared for it can easily run into ballooning memory usage thanks to leaks
from `malloc`ed memory never being deallocated. Consider these two functions: -->

それが望ましい振る舞いの場合これは必ずしも悪いことではありませんが、そうでなかった場合、
`malloc`されたメモリは二度とデアロケートされないがために起きるリークによってメモリ使用量は簡単に膨らんでいきます。
こちらのような2つの関数を考えてみましょう:

<!-- 
```d
void leaker(ref int[] arr)
{
    ...
    arr ~= 10;
    ...
}

void cleaner(int[] arr)
{
    ...
    arr ~= 10;
    ...
}
```
-->

```d
void leaker(ref int[] arr)
{
    ...
    arr ~= 10;
    ...
}

void cleaner(int[] arr)
{
    ...
    arr ~= 10;
    ...
}
```

<!-- Although arrays are reference types, meaning that modifying existing elements of an array argument inside a function
will modify the elements in the original array, they are passed by value as function parameters.
Any activity that modifies the structure of an array argument, i.e. its `length` and `ptr` properties,
only affects the local variable inside the function.
The original will remain unchanged unless the array is passed by reference. -->

配列は参照型、つまり関数内で配列引数の既存の要素を変更するとオリジナルの配列の要素を変更される、
にもかかわらずこれらは関数パラメータとして値渡しされます。
`length`や`ptr`のような、配列引数の構造を変更するようなアクティビティは関数の中のローカル変数にのみ影響します。
オリジナルは配列が参照渡しされない限り変更されません。

<!-- So if an array backed by the C heap is passed to `leaker`, the append will cause a new array to be allocated
from the GC heap. Worse, if `free` is subsequently called on the `ptr` property of the original array,
which now points into the GC heap rather than the C heap, we’re in undefined behavior territory.
`cleaner`, on the other hand, is fine. Any array passed into it will remain unchanged.
Internally, the GC will allocate, but the `ptr` property of the original array still points to the original memory block. -->

Cのヒープからなる配列が`leaker`に渡された場合、追加はGCヒープからの新しい配列のアロケートを引き起こします。
さらに悪いことに、その後`free`がオリジナルの配列のプロパティ`ptr`に対して呼ばれると、`ptr`がCのヒープではなくGCのヒープを指しているため、未定義動作になります。
一方`cleaner`は大丈夫です。
渡された配列は変更されません。
内部では、GCはアロケートをしますが、オリジナルの配列の`ptr`プロパティはオリジナルのメモリブロックを指したままです。

<!-- As long as the original array isn’t overwritten or allowed to go out of scope,
this is a non-issue. Functions like `cleaner` can do what they want
with their local slice and things will be fine externally.
Otherwise, if the original array is to be discarded,
you can prevent all of this by tagging functions which you control with `@nogc`.
Where that’s either not possible or not desirable, then either a copy of the pointer to the original `malloc`ed memory
must be kept and `free`ed at some point after the reallocation takes place,
custom appending and concatenation needs to be implemented, or the allocation strategy needs to be reevaulated. -->

オリジナルの配列が上書きされない、またはスコープの外側に出て良い場合、問題はありません。
`cleaner`のような関数はローカルのスライスを自由にでき、物事は外部でうまく行くでしょう。
そうでなく、オリジナルの配列が破棄される場合、`@nogc`の関数がそれを妨げることがあります。
それが不可能か望ましくない場合、オリジナルの`malloc`されたメモリへのポインタのコピーを保持して再アロケーションが行われた後に`free`するために、
カスタムの追加と結合を実装するか、アロケーション戦略を再評価する必要があります。

<!-- Note that [`std.container.array`](https://dlang.org/phobos/std_container_array.html)
contains an `Array` type that does not rely on the GC and may be preferable over managing all of this manually. -->

[`std.container.array`](https://dlang.org/phobos/std_container_array.html)にはGCに頼らない、全てを手動で管理するのに適した`Array`型があります。

<!-- #### Other APIs -->

#### その他のAPI

<!-- The C standard library isn’t the only game in town for heap allocations.
A number of alternative `malloc` implemenations exist and any of those can be used instead.
This requires manually compiling the source and linking with the resultant objects, but that’s not an onerous task.
Heap memory can also be allocated through system APIs,
like [the Win32 HeapAlloc](https://msdn.microsoft.com/en-us/library/windows/desktop/aa366711(v=vs.85).aspx)
function on Windows (available by importing
[`core.sys.windows.windows`](https://github.com/dlang/druntime/blob/master/src/core/sys/windows/windows.d).
As long as there’s a way to get a pointer to a block of heap memory,
it can be sliced and manipulated in a D program in place of a block of GC memory. -->

C標準ライブラリはヒープアロケーションの唯一の選択肢ではありません。
他にもたくさんの`malloc`実装が存在し、代わりに利用できます。
それらは手動でコンパイルし、コンパイル結果であるオブジェクトをリンクする必要がありますが、決して大変な仕事ではありません。
ヒープメモリはWindowsの[Win32 HeapAlloc](https://msdn.microsoft.com/en-us/library/windows/desktop/aa366711(v=vs.85).aspx)
関数([`core.sys.windows.windows`](https://github.com/dlang/druntime/blob/master/src/core/sys/windows/windows.d)をインポートして利用できます)のようなシステムAPIを通してアロケートすることもできます。
ヒープメモリへのポインタを取得する方法がある限り、そのメモリをスライスしてGCメモリのブロックの代わりにDで操作することができます。

<!-- ### Aggregate types -->

### 集約型

<!-- If we only had to worry about allocating arrays in D, then we could jump straight on to the next section.
However, we also need to concern ourselves with `struct` and `class` types. For this discussion, however,
we will only focus on the former. In my previous post, I left out an example of allocating classes on the stack.
Here, I’m also going to leave them out of the heap discussion.
The next post will focus exclusively on classes and how to manage them with and without the GC. -->

Dで配列をアロケートすること以外考えなくていいなら、次のセクションまで飛ばしてもいいです。
しかし、`struct`や`class`型について考える必要もあります。
この議論では前者、構造体にのみ焦点を当てて行きます。
以前の投稿で、私はスタックからクラスをアロケートする例を省略しました。
今回のヒープの議論でもクラスには触れません。
次回の投稿はクラスと、クラスをどのようにGCで、もしくはGCなしで管理するかのみを取り上げます。

<!-- Allocating an array of `struct` types, or a single instance of one,
is often no different than when the type is `int`. -->

`struct`型の配列、または単一のインスタンスのアロケーティングは、大抵の場合型が`int`の時と変わりません。

<!-- 
```d
struct Point { int x, y; }
Point* onePoint = cast(Point*)malloc(Point.sizeof);
Point* tenPoints = cast(Point*)malloc(Point.sizeof * 10);
```
-->

```d
struct Point { int x, y; }
Point* onePoint = cast(Point*)malloc(Point.sizeof);
Point* tenPoints = cast(Point*)malloc(Point.sizeof * 10);
```

<!-- Where things break down is when contructors enter the mix.
`malloc` and friends know nothing about constructing D object instances.
Thankfully, Phobos provides us with a function template that does. -->

おかしくなるのはコンストラクタが入った時です。
`malloc`とその仲間はDのオブジェクトのインスタンスのコンストラクティングについて何も知りません。
ありがたいことに、Phobosはそのための関数テンプレートを提供しています。

<!-- [`std.conv.emplace`](https://dlang.org/phobos/std_conv.html#emplace)
can take either a pointer to typed memory or an untyped `void[]`, along with an optional number of arguments,
and return a pointer to a single, fully initialized and constructed instance of that type.
This example shows how to do so using both `malloc` and the `allocate` function template from above: -->

[`std.conv.emplace`](https://dlang.org/phobos/std_conv.html#emplace)は型付けされたメモリへのポインタ、
または型のない`void[]`を任意の長さの引数とともにとり、その型の完全に初期化、構築されたインスタンスへのポインタを返します。
これは`malloc`と上記の`allocate`関数テンプレートの使用例です:

<!--
```d
struct Vertex4f 
{ 
    float x, y, z, w; 
    this(float x, float y, float z, float w = 1.0f)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }
}

void main()
{
    import core.stdc.stdlib : malloc;
    import std.conv : emplace;
    import std.stdio : writeln;
    
    Vertex4f* temp1 = cast(Vertex4f*)malloc(Vertex4f.sizeof);
    Vertex4f* vert1 = emplace(temp1, 4.0f, 3.0f, 2.0f); 
    writeln(*vert1);

    void[] temp2 = allocate(Vertex4f.sizeof);
    Vertex4f* vert2 = emplace!Vertex4f(temp2, 10.0f, 9.0f, 8.0f);
    writeln(*vert2);
}
```
-->

```d
struct Vertex4f 
{ 
    float x, y, z, w; 
    this(float x, float y, float z, float w = 1.0f)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }
}

void main()
{
    import core.stdc.stdlib : malloc;
    import std.conv : emplace;
    import std.stdio : writeln;
    
    Vertex4f* temp1 = cast(Vertex4f*)malloc(Vertex4f.sizeof);
    Vertex4f* vert1 = emplace(temp1, 4.0f, 3.0f, 2.0f); 
    writeln(*vert1);

    void[] temp2 = allocate(Vertex4f.sizeof);
    Vertex4f* vert2 = emplace!Vertex4f(temp2, 10.0f, 9.0f, 8.0f);
    writeln(*vert2);
}
```

<!-- Another feature of `emplace` is that it also handles default initialization.
Consider that `struct` types in D need not implement constructors.
Here’s what happens when we change the implementation of `Vertex4f` to remove the constructor: -->

`emplace`のもう一つの機能はデフォルトの初期化をハンドルすることです。
Dでは`struct`型はコンストラクタを実装する必要がないことを思い出してください。
`Vertex4f`の実装からコンストラクタを削除した時、このようなことが起こります:

<!--
```d
struct Vertex4f 
{
    // x, y, z are default inited to float.nan
    float x, y, z;

    // w is default inited to 1.0f
    float w = 1.0f;
}

void main()
{
    import core.stdc.stdlib : malloc;
    import std.conv : emplace;
    import std.stdio : writeln;

    Vertex4f vert1, vert2 = Vertex4f(4.0f, 3.0f, 2.0f);
    writeln(vert1);
    writeln(vert2);    
    
    auto vert3 = emplace!Vertex4f(allocate(Vertex4f.sizeof));
    auto vert4 = emplace!Vertex4f(allocate(Vertex4f.sizeof), 4.0f, 3.0f, 2.0f);
    writeln(*vert3);
    writeln(*vert4);
}
```
-->

```d
struct Vertex4f 
{
    // x, y, z はデフォルトのfloat.nanへの初期化がされます
    float x, y, z;

    // w はデフォルトの1.0fへの初期化がされます
    float w = 1.0f;
}

void main()
{
    import core.stdc.stdlib : malloc;
    import std.conv : emplace;
    import std.stdio : writeln;

    Vertex4f vert1, vert2 = Vertex4f(4.0f, 3.0f, 2.0f);
    writeln(vert1);
    writeln(vert2);    
    
    auto vert3 = emplace!Vertex4f(allocate(Vertex4f.sizeof));
    auto vert4 = emplace!Vertex4f(allocate(Vertex4f.sizeof), 4.0f, 3.0f, 2.0f);
    writeln(*vert3);
    writeln(*vert4);
}
```

<!-- This prints the following: -->

出力は以下のようになります:

<!--
```
Vertex4f(nan, nan, nan, 1)
Vertex4f(4, 3, 2, 1)
Vertex4f(nan, nan, nan, 1)
Vertex4f(4, 3, 2, 1)
```
-->

```
Vertex4f(nan, nan, nan, 1)
Vertex4f(4, 3, 2, 1)
Vertex4f(nan, nan, nan, 1)
Vertex4f(4, 3, 2, 1)
```

<!-- So `emplace` allows heap-allocated struct instances to be initialized in the same manner
as stack allocated struct instances, with or without a constructor.
It also works with the built-in types like `int` and `float`.
There’s also a version that’s specialized for class references, but we’ll look at that in the next post.
Just always remember that `emplace` is intended to initialize and construct a _single instance_, not an array of instances.-->

コンストラクタがあってもなくても、`emplace`はスタックからアロケートされた構造体インスタンスと同じやり方でヒープからアロケートされた構造体インスタンスを初期化することができます。
これは`int`や`float`のような組み込み型でも動作します。
クラスの参照に特殊化されたものもありますが、それは次の投稿で見ていきましょう。
`emplace`は**単一のインスタンス**を初期化、構築するものであり、インスタンスの配列は対象ではないことを忘れないでください。

<!-- ### std.experimental.allocator -->

### std.experimental.allocator

<!-- The entirety of the text above describes the fundamental building blocks of a custom memory manager.
For many use cases, it may be sufficient to forego cobbling something together by hand and instead take advantage
of the D standard library’s
[`std.experimental.allocator`](https://dlang.org/phobos/std_experimental_allocator.html) package.
This is a high-level API that makes use of low-level techniques like those described above, along with
[Design by Introspection](https://www.youtube.com/watch?v=es6U7WAlKpQ),
to facilitate the assembly of different types of allocators
that know how to allocate, initialize, and construct arrays and type instances.
Allocators like [`Mallocator`](https://dlang.org/phobos/std_experimental_allocator_mallocator.html)
and [`GCAllocator`](https://dlang.org/phobos/std_experimental_allocator_gc_allocator.html)
can be used to grab chunks of memory directly, or combined with other
[building blocks](https://dlang.org/phobos/std_experimental_allocator_building_blocks.html)
for specialized behavior.
See the [emsi-containers library](https://github.com/economicmodeling/containers) for a real-world example. -->

上の文章の全体はカスタムメモリマネージャーのビルディングブロックの根幹を説明しています。
多くのケースでは、手作業でまとめる代わりにDの標準ライブラリの[`std.experimental.allocator`](https://dlang.org/phobos/std_experimental_allocator.html)
パッケージを利用するので充分かもしれません。
これは上で説明したような低レベルの技術を
[Design by Introspection](https://www.youtube.com/watch?v=es6U7WAlKpQ)
とともに使い、配列や型インスタンスのアロケート、初期化、および構築方法を知っているさまざまなタイプのアロケータのアセンブリを容易にする高レベルのAPIです。
[`Mallocator`](https://dlang.org/phobos/std_experimental_allocator_mallocator.html)や
[`GCAllocator`](https://dlang.org/phobos/std_experimental_allocator_gc_allocator.html)のようなアロケータは特殊な振る舞いのために直接メモリのまとまりを取得したり、
他の[ビルディングブロック](https://dlang.org/phobos/std_experimental_allocator_building_blocks.html)とまとめたりできます。
実例は[emsi-containers ライブラリ](https://github.com/economicmodeling/containers)をご覧ください。

<!-- ### Keeping the GC informed -->

### GCに情報を伝える

<!-- Given that it’s rarely recommended to disable the GC entirely,
most D programs allocating outside the GC heap will likely also be using memory from the GC heap in the same program.
In order for the GC to properly do its job, it needs to be informed of any non-GC memory that contains,
or may potentially contain, references to memory from the GC heap.
For example, a linked list whose nodes are allocated with `malloc`
might contain references to classes allocated with `new`. -->

GCの完全な無効化が推奨される事は稀なため、GCヒープの外からアロケートするDのプログラムの多くは同時にGCヒープからのメモリも使用します。
そこでGCが適切に動作するために、GCヒープのメモリへの参照を含む、または潜在的に含む可能性がある非GCメモリを通知する必要があります。
例えば、ノードが`malloc`でアロケートされた連結リストは`new`でアロケートされたクラスへの参照を含むことがあります。

<!-- The GC can be given the news via `GC.addRange`. -->

GCは`GC.addRange`で情報を受け取ります。

<!-- 
```d
import core.memory;
enum size = int.sizeof * 10;
void* p1 = malloc(size);
GC.addRange(p1, size);

void[] p2 = allocate!int(10);
GC.addRange(p2.ptr, p2.length);
```
-->

```d
import core.memory;
enum size = int.sizeof * 10;
void* p1 = malloc(size);
GC.addRange(p1, size);

void[] p2 = allocate!int(10);
GC.addRange(p2.ptr, p2.length);
```

<!-- When the memory block is no longer needed,
the corresponding `GC.removeRange` can be called to prevent it from being scanned.
This **does not deallocate** the memory block.
That will need to be done manually via `free` or whatever allocator interface was used to allocate it.
Be sure to [read the documentation](https://dlang.org/phobos/core_memory.html#addRange) before using either function. -->

メモリブロックが必要なくなった場合は、それに伴ってそのメモリブロックがスキャンされないように`GC.removeRange`を呼べます。
これはメモリブロックを**デアロケートしません**。
それは`free`かメモリブロックをアロケートしたアロケータインタフェースを使い手動で行う必要があります。
これらの関数を使う前には必ず[ドキュメントを読んでください](https://dlang.org/phobos/core_memory.html#addRange)。

<!-- Given that one of the goals of allocating from outside the GC heap
is to reduce the amount of memory the GC must scan, this may seem self-defeating.
That’s the wrong way to look at it.
If non-GC memory is going to hold references to GC memory, then it’s vital to let the GC know about it.
Not doing so can cause the GC to free up memory to which a reference still exists.
`addRange` is a tool specifically designed for that situation.
If it can be guaranteed that no GC-memory references live inside a non-GC memory block,
such as a `malloc`ed array of vertices, then `addRange` need not be called on that memory block. -->

GCヒープの外からのアロケーティングの目的がGCのスキャンしなければならないメモリの量を減らすことだと言うことを考えると、これは自滅的なように思えます。
一見して間違った方法にも思えます。
非GCメモリがGCメモリへの参照を持つとき、GCはそれを知っていなければなりません。
`addRange`はそのような場面のために設計されたツールです。
`malloc` された頂点配列のように、非GCメモリブロックへのGCメモリの参照が無いと保証できる場合、`addRange`をメモリブロックに対して呼ぶ必要はありません。

<!-- #### A word of warning -->

#### 忠告

<!-- Be careful when passing typed pointers to `addRange`.
Because the function was implemented with the C like approach of taking a pointer to a block of memory
and the number of bytes it contains, there is an opportunity for error. -->

型のあるポインタを`addRange`に渡す際は気をつけてください。
この関数はCのようにメモリのブロックへのポインタとそのブロックが含むバイト数をとるやり方で実装されており、エラーを引き起こす可能性があります。

<!--
```d
struct Item { SomeClass foo; }
auto items = (cast(Item*)malloc(Item.sizeof * 10))[0 .. 10];
GC.addRange(items.ptr, items.length);
```
-->

```d
struct Item { SomeClass foo; }
auto items = (cast(Item*)malloc(Item.sizeof * 10))[0 .. 10];
GC.addRange(items.ptr, items.length);
```

<!-- With this, the GC would be scanning a block of memory exactly ten bytes in size.
The `length` property returns the number of elements the slice refers to.
Only when the type is `void` (or the element type is one-byte long, like `byte` and `ubyte`)
does it equate to the size of the memory block the slice refers to. The correct thing to do here is: -->

ここで、GCはメモリブロックを10バイトしかスキャンしません。
`length`プロパティはそのスライスが参照している要素の個数を返します。
スライスが参照しているメモリブロックのサイズと`length`プロパティの値が等価になるのは、型が `void`(または`byte`や`ubyte`のように要素の長さが1バイト)の時のみです。
正しい方法は:

<!--
```d
GC.addRange(items.ptr, items.length * Item.sizeof);
```
-->

```d
GC.addRange(items.ptr, items.length * Item.sizeof);
```

<!-- However, until DRuntime is updated with an alternative,
it may be best to implement a wrapper that takes a `void[]` parameter. -->

DRuntimeが新しくアップデートされるまでは、`void[]`パラメータを受け取るラッパーを実装するのが良いでしょう。

<!-- 
```d
void addRange(void[] mem) 
{
	import core.memory;
	GC.addRange(mem.ptr, mem.length);
}
```
-->

```d
void addRange(void[] mem) 
{
	import core.memory;
	GC.addRange(mem.ptr, mem.length);
}
```

<!-- Then calling `addRange(items)` will do the correct thing.
The implicit conversion of the slice to `void[]` in the function call will mean that `mem.length`
is the same as `items.length * Item.sizeof`. -->

そうして`addRange(items)`を呼ぶと良いでしょう。
関数呼び出しでのスライスから`void[]`への暗黙の変換により`mem.length`は`items.length * Item.sizeof`と同じになります。

<!-- ### The GC series marches on -->

### GCシリーズは進む

<!-- This post has covered the very basics of using the non-GC heap in D programs.
One glaring omission, in addition to `class` types, is what to do about destructors.
I’m saving that topic for the post about classes, where it is highly relevant.
That’s the next scheduled post in the GC series. Stay tuned! -->

この投稿ではDのプログラムにおける非GCヒープの使い方を扱いました。
`class`型に加えて、デストラクタについての記述も抜けています。
それは関係の深いクラスについての投稿にとっておきます。
これが次の投稿の予定です。
乞うご期待！

<!-- Thanks to Walter Bright, Guillaume Piolat, Adam D. Ruppe, and Steven Schveighoffer
for their valuable feedback on a draft of this article. -->

この記事の草稿について価値あるフィードバックをしてくれたWalter Bright、Guillaume Piolat、Adam D. Ruppe、Steven Schveighofferに感謝します。