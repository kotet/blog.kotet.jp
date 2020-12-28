---
title: "DとCのインターフェース：配列 Part 2【翻訳】"
date: 2020-12-28
tags:
- dlang
- tech
- translation
- d_blog
- d_and_c
- advent_calendar
- cpplang
---

[Interfacing D with C: Arrays and Functions (Arrays Part 2) – The D Blog](https://dlang.org/blog/2020/04/28/interfacing-d-with-c-arrays-and-functions-arrays-part-two/)
を
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
翻訳しました。

これは
[D言語 Advent Calendar 2020](https://qiita.com/advent-calendar/2020/dlang)
の4日目の記事です。

---

<!-- This post is part of an ongoing series on working with both D and C in the same project. [The previous post explored the differences](https://dlang.org/blog/2018/10/17/interfacing-d-with-c-arrays-part-1/) in array declaration and initialization. This post takes the next step: declaring and calling C functions that take arrays as parameters. -->

この投稿はDとCを同じプロジェクトで動かすシリーズの一部です。
前回の投稿では配列の宣言と初期化に関するDとCの
[違いを確認しました](https://dlang.org/blog/2018/10/17/interfacing-d-with-c-arrays-part-1/)
(
訳注: [日本語訳はこちら](/2018/12/interfacing-d-with-c-arrays-part-1)
)
。

<!-- Arrays and C function declarations
---------------------------------- -->

### 配列とCの関数宣言

<!-- Using C libraries in D is extremely easy. Most of the time, things work exactly as one would expect, but as we saw in the previous article there can be subtle differences. When working with C functions that expect arrays, it’s necessary to fully understand these differences. -->

CのライブラリをDから使うことはとても簡単です。
ほとんどの場合で期待したとおりに動作しますが、前回見てきたとおり少し違いがあります。
配列を受け取るCの関数を取り扱う場合は、その違いを深く理解する必要があります。

<!-- The most straightforward and common way of declaring a C function that accepts an array as a parameter is to to use a pointer in the parameter list. For example, this hypothetical C function: -->

引数として配列を受け取るCの関数を宣言する最も素直で一般的な方法は、
引数リストの中でポインタを使うものです。
たとえば、このようなCの関数があるとします。

```c
void f0(int *arr);
```

<!-- Any array of `int` can be passed to this function, no matter how it was declared, e.g., as a pointer or using C’s array syntax (like `int a[]` or `int b[3]`). Using the lingo of C programmers, arrays _decay_ to pointers. All that means for our purposes is that in a function call such as `f0(a)` or `f0(b)`, a pointer to the first element of the array is passed to the function. -->

この関数には`int`の配列ならば、それがどのように宣言されたかに関わらず渡すことができます。
たとえばポインタとしてでも、またCの配列構文(`int a[]`や`int b[3]`)を使っても同じです。
Cプログラマの言葉で言うと、配列はポインタに**減衰**されます。
つまり`f0(a)`や`f0(b)`のような関数呼び出しにおいて、
関数には配列の最初の要素へのポインタが渡されます。

<!-- Typically, in a function like `f0`, the implementer will expect the array to have been terminated with a marker appropriate to the context. For example, strings in C are arrays of `char` that are terminated with the `\0` character (we’ll look at D strings vs. C strings in a future post). This is necessary because, without that character, the implementation of `f0` has no way to know which element in the array is the last one. Sometimes, a function is simply documented to expect a certain length, either in comments or in the function name, e.g., a `vector3f_add` will expect exactly 3 elements. Another option is to require the length of the array as a separate argument: -->

通常`f0`のような関数では、配列は文脈に応じた適切なマーカーで終了することが求められます。
たとえばCの文字列は文字`\0`で終了する`char`の配列です
(Dの文字列とCの文字列の差については将来の投稿で取り扱います)
。
もし終端文字がなければ`f0`は配列のどの要素が最後の要素か知ることができないため、
このような文字が必要になります。
そうではなく、コメントや関数名によって、関数が特定の長さを期待していることを記述することもあります。
たとえば`vector3f_add`はちょうど3要素を期待します。
もう一つの選択肢は別の引数として配列の長さを要求することです。

```c
void f1(int *arr, size_t len);
```

<!-- None of these approaches is foolproof. If `f0` receives an array with no end marker or which is shorter than documented, or if `f1` receives an array with an actual length shorter than `len`, then the door is open for memory corruption. D arrays take this possibility into account, making it much easier to avoid such problems. But again, even D’s safety features aren’t 100% foolproof when calling C functions from D. -->

これらのアプローチにはフールプルーフがありません。
`f0`にマーカーが無い、または指示されたよりも短い配列が渡されたとき、
もしくは`f1`に渡された配列の実際の長さが`len`よりも短いときには、
メモリ破壊への扉が開かれることになります。
Dの配列ではこの可能性を考慮し、そのような問題を簡単に回避できるようにしました。
しかしやはり、Cの関数をDから呼ぶときにおいてDの安全機能は100%のフールプルーフにはなりません。

<!-- There are other, less common, ways array parameters may be declared in C: -->

少々一般的ではなくなりますが、他にもCにおける配列引数の宣言方法があります。

```c
void f2(int arr[]);
void f3(int arr[9]);
void f4(int arr[static 9]);
```

<!-- Altough these parameters are declared using C’s array syntax, they boil down to the exact same function signature as `f0` because of the aforementioned pointer decay. The `9` in the brackets in `f3` provides no special enforcement by the compiler; `arr` is still efectively a pointer to `int` with unknown length. The `9` serves as documentation of what the function expects, and the implementation cannot rely on the array having nine elements. -->

しかしこれらのCの配列構文で宣言された引数は、
前述のポインタ減衰によって`f0`の関数シグネチャと同じになります。
`f3`の角括弧内の`9`はコンパイラに対して何ら制約を与えません。
`arr`は事実上、不明な長さの`int`の配列のままです。
`9`は関数がなにを期待するかのドキュメントとして役立ちますが、
その実装は配列が9つの要素を持つことに期待してはいけません。

<!-- The only difference is in `f4`. The `static` added to the declaration tells the compiler that the function must take an array of _at least_ nine elements. It could have more than nine, but it can’t have fewer. That also rules out null pointers. The problem is, this isn’t necessarily enforced. Depending on which C compiler you use, you might see warnings if they are enabled, but the compiler might not complain at all. (I haven’t tested current compilers for this article to see if any are actually reporting errors for this, or which ones provide warnings.) -->

`f4`だけ違いが生じます。
宣言に追加された`static`は、
**少なくとも**9要素の配列を受け取らなければならないことをコンパイラに伝えます。
9要素よりも多くなることはできますが、少なくなることはできません。
ヌルポインタは例外です。
問題は、これが強制されないことです。
使っているCコンパイラによっては、有効にしたときにだけ警告が見られるようになっているかもしれません
(エラーが出てくるのか警告が出てくるのか、この記事を書くにあたって最新のコンパイラでテストしてはいません)
。

<!-- The behavior of C compilers doesn’t matter from the D side. All we need be concerned with is declaring these functions appropriately so that we can call them from D such that there are no crashes or unexpected results. Because they are all effectively the same, we could declare them all in D like so: -->

Cコンパイラの挙動はD側には関係ありません。
関係あるのはこれらの関数が適切に宣言され、
クラッシュや予期しない結果がないようにDから呼び出せるようになっていることです。
なぜならこれらすべては事実上同じであり、Dではこのように宣言できるからです。

```d
extern(C):
void f0(int* arr);
void f1(int* arr, size_t len);
void f2(int* arr);
void f3(int* arr);
void f4(int* arr);
```

<!-- But just because we can do a thing doesn’t mean we should. Consider these alternative declarations of `f2`, `f3`, and `f4`: -->

しかしできるからといってそうしなければならないわけではありません。
このような`f2`、`f3`、`f4`の宣言を考えてみましょう。

```d
extern(C):
void f2(int[] arr);
void f3(int[9] arr);
void f4(int[9] arr);
```

<!-- Are there any consequences of taking this approach? The answer is yes, but that doesn’t mean we should default to `int*` in each case. To understand why, we need first to explore the innards of D arrays. -->

このアプローチによって何か問題が起きるでしょうか?
答えはイエスですが、それは全部を`int*`に戻さなければならないということを意味しません。
その理由を理解するには、まずDの配列の内部にふみ込んでいく必要があります。

<!-- The anatomy of a D array
------------------------ -->

### 大解剖 Dの配列

<!-- The previous article showed that D makes a distinction between dynamic and static arrays: -->

前回、Dは動的配列と静的配列を区別するということを見てきました。

```d
int[] a0;
int[9] a1;
```

<!-- `a0` is a dynamic array and `a1` is a static array. Both have the properties `.ptr` and `.length`. Both may be indexed using the same syntax. But there are some key differences between them. -->

`a0`は動的配列で、`a1`は静的配列です。
両者とも`.ptr`と`.length`というプロパティを持ちます。
両者とも同じ構文でインデクシングができます。
しかし両者の間には重要な違いがあります。

<!-- ### Dynamic arrays -->

#### 動的配列

<!-- Dynamic arrays are usually allocated on the heap (though that isn’t a requirement). In the above case, no memory for `a0` has been allocated. It would need to be initialized with memory allocated via `new` or `malloc`, or some other allocator, or with an array literal. Because `a0` is uninitialized, `a0.ptr` is `null` and `a0.length` is `0`. -->

動的配列は通常ヒープに確保されます(必ずしもそうしないといけないわけではありません)。
上の例では、`a0`に関してメモリ割当は発生しません。
この配列は`new`、`malloc`、その他アロケータや配列リテラルによってメモリを確保される必要があります。
`a0`が初期化されない場合、`a0.ptr`は`null`であり`a0.length`は`0`です。

<!-- A dynamic array in D is an aggregate type that contains the two properties as members. Something like this: -->

Dにおける動的配列は以下のような、2つのプロパティをメンバとして持つ複合型です。

```d
struct DynamicArray {
    size_t length;
    size_t ptr;
}
```

<!-- In other words, a dynamic array is essentially a reference type, with the pointer/length pair serving as a handle that refers to the elements in the memory address contained in the `ptr` member. Every built-in D type has a `.sizeof` property, so if we take `a0.sizeof`, we’ll find it to be `8` on 32-bit systems, where `size_t` is a 4-byte `uint`, and `16` on 64-bit systems, where `size_t` is an 8-byte `ulong`. In short, it’s the size of the handle and not the cumulative size of the array elements. -->

言い換えると、動的配列は本質的に参照型であり、
`ptr`メンバに格納されたアドレスにある要素を参照するためのポインタと長さのペアを持ちます。
すべての組み込みのD型は`.sizeof`プロパティを持ち、
`a0.sizeof`とすると32bitシステムなら`size_t`が4バイトの`uint`のため`8`が、
64bitシステムなら`size_t`が8バイトの`ulong`のため`16`が得られます。
とどのつまり、これは管理領域のサイズであり配列の要素全体のサイズではありません。

<!-- ### Static arrays -->

#### 静的配列

<!-- Static arrays are generally allocated on the stack. In the declaration of `a1`, stack space is allocated for nine `int` values, all of which are initialized to `int.init` (which is `0`) by default. Because `a1` is initialized, `a1.ptr` points to the allocated space and `a1.length` is `9`. Although these two properties are the same as those of the dynamic array, the implementation details differ. -->

静的配列は一般にスタックに確保されます。
`a1`の宣言で、9要素の`int`値のためのスタック領域が確保され、
それらすべてがデフォルトでは`int.init`(`0`)に初期化されます。
`a1`の初期化時に、`a1.ptr`はその確保された領域を指し、`a1.length`は`9`になります。
これら2つのプロパティは動的配列のそれと同じですが、その実装は異なります。

<!-- A static array is a value type, with the value being _all of its elements_. So given the declaration of `a1` above, its nine `int` elements indicate that `a1.sizeof` is `9 * int.sizeof`, or `36`. The `.length` property is a compile-time constant that never changes, and the `.ptr` property, though not readable at compile time, is also a constant that never changes (it’s not even an lvalue, which means it’s impossible to make it point somewhere else). -->

静的配列は値型であり、その値は**配列の要素全体**です。
したがって上のような`a1`の宣言を考えると、9つの`int`の要素は`a1.sizeof`が`9 * int.sizeof`、
つまり`36`であることを示しています。
`.length`プロパティは決して変化しないコンパイル時定数であり、
`.ptr`プロパティはコンパイル時に読むことはできないものの、
やはり決して変化しない定数です(左辺値ではないので、他の場所を指すようにすることは不可能です)。

<!-- These implementation details are why we must pay attention when we cut and paste C array declarations into D source modules. -->

この実装が、DのソースモジュールにCの配列の宣言をコピペするときに気をつけなければならない理由です。

<!-- Passing D arrays to C
--------------------- -->

### Cの配列をDに渡す

<!-- Let’s go back to the declaration of `f2` in C and give it an implementation: -->

Cにおける`f2`の宣言を見返して、実装を与えてみます。

```c
void f2(int arr[]) {
    for(int i=0; i<3; ++i)
     printf("%d\n", arr[i]);
}
```

<!-- A naïve declaration in D: -->

Dにおける素直な宣言は以下のようになります。

```d
extern(C) void f2(int[]);
void main() {
    int[] a = [10, 20, 30];
    f2(a);
}
```

<!-- I say naïve because this is never the right answer. Compiling `f2.c` with `df2.d` on Windows (`cl /c f2.c` in the “x64 Native Tools” command prompt for Visual Studio, followed by `dmd -m64 df2.d f2.obj`), then running `df2.exe`, shows me the following output: -->

素直な、と言ったのはこれが正しい答えではないからです。
`f2.c`と`df2.d`をWindowsでコンパイルし、
(Visual Studioの"x64 Native Tools"で`cl /c f2.c`として、その後`dmd -m64 df2.d f2.obj`です)
`df2.exe`を実行すると、以下のような出力が得られます。

```
3
0
1970470928
```

<!-- There is no compiler error because the declaration of `f2` is pefectly valid D. The `extern(C)` indicates that this function uses the `cdecl` calling convention. Calling conventions affect the way arguments are passed to functions and how the function’s symbol is mangled. In this case, the symbol will be either `_f2` or `f2` (other calling conventions, like `stdcall`—`extern(Windows)` in D—have different mangling schemes). The declaration still has to be valid D. (In fact, any D function can be marked as `extern(C)`, something which is necessary when creating a D library that will be called from other languages.) -->

`f2`の宣言はDにおいて完全に正しいためコンパイラエラーは発生しません。
`extern(C)`はこの関数が`cdecl`呼び出し規約を使うことを示します。
呼び出し規約は関数に引数が渡される方法と、関数のシンボルがマングリングされる方法に関わります。
この例では、シンボルは`_f2`か`f2`になります
(Dで`extern(Windows)`としたときの`stdcall`のような、
他の呼び出し規約はまた異なるマングリングスキームを持ちます)。
Dにおいて、宣言はやはり正しいままです
(実際、任意のDの関数に`extern(C)`をつけることができます。
これは他の言語から呼ばれるDのライブラリを作る際に必要になります)。

<!-- There is also no linker error. DMD is calling out to the system linker (in this case, Microsoft’s `link.exe`), the same linker used by the system’s C and C++ compilers. That means the linker has no special knowledge about D functions. All it knows is that there is a call to a symbol, `f2` or `_f2`, that needs to be linked with the implementation. Since the type and number of parameters are not mangled into the symbol name, the linker will happily link with any matching symbol it finds (which, by the way, is the same thing it would do if a C program tried to call a C function which was declared with an incorrect parameter list). -->

リンカエラーも発生しません。
DMDはシステムのリンカを呼び出し
(この場合Microsoftの`link.exe`です)
、システムのC/C++コンパイラも同じリンカを使います。
つまりリンカはDの関数に関して特になにも知りません。
関数の実装をリンクするのに必要なこと、つまりシンボル`f2`か`_f2`に対する呼び出しがあることが、
リンカの知るすべてです。
パラメータの型と個数はシンボル名にマングルされていないため、
リンカは愉快なことに名前がマッチしたもの全部を見境なくリンクしてくれます
(ところで、正しくない引数リストで宣言されたCの関数をCのプログラムから呼び出しても、
これと同じことが起きます)。

<!-- The C function is expecting a single pointer as an argument, but it’s instead receiving two values: the array length followed by the array pointer. -->

Cの関数は引数としてポインタ1つを受け取ることを期待していますが、実際は2つです。
つまり、配列のポインタと長さです。

<!-- The moral of this story is that any C function with array parameters declared using array syntax, like `int[]`, should be declared to accept pointers in D. Change the D source to the following and recompile using the same command line as before (there’s no need to recompile the C file): -->

この話の教訓は、`int[]`のような配列構文を使って宣言された配列の引数をもつCの関数は、
D側では配列を受け取るように宣言すべきということです。
Dのソースを以下のように書き換え、先程と同じコマンドで再コンパイルしましょう
(Cファイルを再コンパイルする必要はありません)。

```d
extern(C) void f2(int*);
void main() {
    int[] a = [10, 20, 30];
    f2(a.ptr);
}
```

<!-- Note the use of `a.ptr`. It’s an error to try to pass a D array argument where a pointer is expected (with one very special exception, string literals, which I’ll cover in the next article in this series), so the array’s `.ptr` property must be used instead. -->

`a.ptr`を使っていますね。
ポインタを期待しているところにDの配列を渡してもエラーになります
(特別な例外として文字列リテラルがありますが、これはこのシリーズの次の記事で取り扱います)。
したがって、代わりに配列の`.ptr`プロパティを使う必要があります。

<!-- The story for `f3` and `f4` is similar: -->

`f3`と`f4`にも似たようなことが言えます。

```c
void f3(int arr[9]);
void f4(int arr[static 9]);
```

<!-- Remember, `int[9]` in D is a static array, not a dynamic array. The following do not match the C declarations: -->

Dにおける`int[9]`は動的配列でなく静的配列です。
以下のような宣言はCの宣言とマッチしません。

```d
void f3(int[9]);

void f4(int[9]);
```

<!-- Try it yourself. The C implementation: -->

試してみましょう。

```c
void f3(int arr[9]) {
    for(int i=0; i<9; ++i)
     printf("%d\n", arr[i]);
}
```

<!-- And the D implementation: -->

Dの実装は以下のとおりです。

```d
extern(C) void f3(int[9]);
void main() {
    int[9] a = [10, 20, 30, 40, 50, 60, 70, 80, 90];
    f3(a);
}
```

<!-- This is likely to crash, depending on the system. Rather than passing a pointer to the array, this code is instead passing all nine array elements by value! Now consider a C library that does something like this: -->

これはシステムによってはクラッシュします。
配列へのポインタを渡す代わりに、このコードは配列の9つの要素すべてを値として渡しています！
では、以下のようなことをするCのライブラリについて考えてみましょう。

```c
typedef float[16] mat4f;
void do_stuff(mat4f mat);
```

<!-- Generally, when writing D bindings to C libraries, it’s a good idea to keep the same interface as the C library. But if the above is translated like the following in D: -->

一般に、Cのライブラリに対するDのバインディングを書くときは、
Cのライブラリと同じインターフェースを保つべきです。
しかし上のコードを以下のようなDのコードに翻訳すると問題が起きます。

```d
alias mat4f = float[16];
extern(C) void do_stuff(mat4f);
```

<!-- The sixteen floats will be passed to `do_stuff` every time it’s called. The same for all functions that take a `mat4f` parameter. One solution is just to do the same as in the `int[]` case and declare the function to take a pointer. However, that’s no better than C, as it allows the function to be called with an array that has fewer elements than expected. We can’t do anything about that in the `int[]` case, but that will usually be accompanied by a length parameter on the C side anyway. C functions that take typedef’d types like `mat4f` usually don’t have a length parameter and rely on the caller to get it right. -->

`do_stuff`が呼ばれるたびに、16個の浮動小数点数が渡されます。
これは`mat4f`型の引数を受け取るすべての関数で同じです。
`int[]`の例と同じようにして、ポインタを受け取るように関数を宣言するのもひとつの方法です。
しかし、期待するよりも少ない要素数の配列を受け入れてしまう点でこれはCに劣ります。
`int[]`の例ではどうしようもありませんが、通常はC側で長さパラメータを付けます。
`mat4f`のような`typedef`された型を受け取るCの関数は通常長さパラメータを持たず、
呼び出し側が正しく呼び出すことに依存します。

<!-- In D, we can do better: -->

Dでは以下のようにしたほうが良いでしょう。

```d
void do_stuff(ref mat4f);
```

<!-- Not only does this match the API implementor’s intent, the compiler will guarantee that any arrays passed to `do_stuff` are static float arrays with 16 elements. Since a `ref` parameter is just a pointer under the hood, all is as it should be on the C side. -->

API実装者の意図に沿うだけでなく、
コンパイラも`do_stuff`に渡される配列が16の浮動小数点数を要素とする静的配列であると保証するようになります。
`ref`パラメータは内部的にただのポインタなので、C側との連携はうまくいきます。

<!-- With that, we can rewrite the `f3` example: -->

これをもとに、`f3`の例も書き直すことができます。

```d
extern(C) void f3(ref int[9]);
void main() {
    int[9] a = [10, 20, 30, 40, 50, 60, 70, 80, 90];
    f3(a);
}
```

<!-- ### Conclusion -->

#### 結論

<!-- Most of the time, when interfacing with C from D, the C API declarations and any example code can be copied verbatim in D. But _most of the time_ is not _all of the time_, so care must be taken to account for those exceptional cases. As we saw in the previous article, carelessness when declaring array variables can usually be caught by the compiler. As this article shows, the same is not the case for C function declarations. Interfacing D with C requires the same care as when writing C code. -->

ほとんどの場合、DからCへのインターフェーシングを行うときは、
CのAPIの宣言とサンプルコードをDにそのままコピーするだけですみます。
しかし**ほとんどの場合**というのは**すべての場合**のことではないため、
そのような例外的ケースにおいては注意が必要となります。
前回見たように、配列変数における注意はコンパイラに受け持たせることができます。
今回見てきたように、Cの関数宣言においては同じようには行きません。
DとCとのインターフェーシングにはCのコードを書くときと同じような注意が必要です。

<!-- In the next article in this series, we’ll look at mixing D strings and C strings in the same program and some of the pitfalls that may arise. In the meantime, Steven Schveighoffer’s excellent article, “D Slices”, [is a great place to start](https://dlang.org/articles/d-array-article.html) for more details about D arrays. -->

本シリーズの次回の記事では、Dの文字列とCの文字列を同じプログラムでまぜこぜにし、
落とし穴が生じるようすを見ていきます。
それまで、Steven Schveighofferの素晴らしい記事
"D Slices"
がDの配列についてより深く掘り下げる
[よい開始地点となるでしょう](https://dlang.org/articles/d-array-article.html)。

<!-- _Thanks to Walter Bright and Átila Neves for their valuable feedback on this article._ -->

*Walter BrightとÁtila Nevesのこの記事に関する価値あるフィードバックに感謝します。*
