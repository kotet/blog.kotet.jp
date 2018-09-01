---
date: 2018-03-04
aliases:
- /2018/03/04/vanquish-forever-these-bugs-that-blasted-your-kingdom.html
title: "プログラムの城を粉々にしてしまうバグを永久に克服する【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "簡単に発生し、チェックが難しく、たいていテストにも引っかからず、 デプロイされるとあなたの城を粉砕する、 そんなバグに苦労したことはありませんか? そういうバグはあなたの時間と金銭を何度も奪ってゆきます。 自分がもっと優れたプログラマならこんなことは起こらないのに、そうでしょう?"
---

この記事は、
[Vanquish Forever These Bugs That Blasted Your Kingdom – The D Blog](https://dlang.org/blog/2018/02/07/vanquish-forever-these-bugs-that-blasted-your-kingdom/)
を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

ソース中にコメントの形で原文を残している。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

<!-- _Walter Bright is the BDFL of the D Programming Language and founder of Digital Mars. He has decades of experience implementing compilers and interpreters for multiple languages, including Zortech C++, the first native C++ compiler. He also created Empire, the Wargame of the Century. This post is the first in a series on how [D’s BetterC mode](https://dlang.org/blog/2017/08/23/d-as-a-better-c/) can be used to exterminate and prevent bugs in existing C code._ -->

Walter BrightはD言語のBDFL[^1]でありDigital Marsのファウンダーです。
彼は最初のネイティブC++コンパイラであるZortech C++などの様々な言語のコンパイラやインタプリタを実装した10年の経験があります。
また、Empire, the Wargame of the Century[^2] [^3]の作者でもあります。
この投稿は、[DのBetterCモード](https://dlang.org/blog/2017/08/23/d-as-a-better-c/)を使うと既存のCのコードからいかにしてバグをなくし、回避することができるかについてのシリーズの最初のものです。

[^1]: 訳注:[優しい終身の独裁者 - Wikipedia](https://ja.wikipedia.org/wiki/%E5%84%AA%E3%81%97%E3%81%84%E7%B5%82%E8%BA%AB%E3%81%AE%E7%8B%AC%E8%A3%81%E8%80%85)
[^2]: 訳注:[Classic Empire - Wikipedia](https://en.wikipedia.org/wiki/Classic_Empire)
[^3]: 訳注:[EMPIRE, Wargame of the Century (tm) index](http://www.classicempire.com/)

---

<!-- ![](https://i0.wp.com/dlang.org/blog/wp-content/uploads/2018/02/bug.jpg?resize=256%2C156) -->

![Bug](/assets/2018/03/bug.jpg)

<!-- Do you ever get tired of bugs that are easy to make, hard to check for, often don’t show up in testing, and [blast your kingdom](https://getyarn.io/yarn-clip/ac6765ca-f2c6-49ec-a1ba-a7e9b0f692bf) once they are widely deployed? They cost you time and money again and again. If you were only a better programmer, these things wouldn’t happen, right? -->

簡単に発生し、チェックが難しく、たいていテストにも引っかからず、
デプロイされると[あなたの城を粉砕する](https://getyarn.io/yarn-clip/ac6765ca-f2c6-49ec-a1ba-a7e9b0f692bf)、
そんなバグに苦労したことはありませんか?
そういうバグはあなたの時間と金銭を何度も奪ってゆきます。
自分がもっと優れたプログラマならこんなことは起こらないのに、そうでしょう?

<!-- Maybe it’s not you at all. I’ll show how these bugs are not your fault – they’re the tools’ fault, and by improving the tools you’ll never have your kingdom blasted by them again. -->

そうではありません。
私はそれらのバグに二度とあなたの城が壊されないようにツールを改善することによって、バグがあなたのせいではなくツールのせいで起きているのだと証明します。

<!-- And you won’t have to compromise, either. -->

そして、あなたは妥協する必要もありません。

<!-- ### Array Overflow -->

### 配列のオーバーフロー

<!-- Consider this conventional program to calculate the sum of an array: -->

このような配列の合計値を計算する伝統的プログラムを考えてみましょう:

```c
#include <stdio.h>

#define MAX 10

int sumArray(int* p) {
    int sum = 0;
    int i;
    for (i = 0; i <= MAX; ++i)
        sum += p[i];
    return sum;
}

int main() {
    static int values[MAX] = { 7,10,58,62,93,100,8,17,77,17 };
    printf("sum = %d\n", sumArray(values));
    return 0;
}
```

<!-- The program should print: -->

このプログラムの出力は以下のようでなければなりません:

```
sum = 449
```

<!-- And indeed it does, on my Ubuntu Linux system, with both `gcc` and `clang` and `-Wall`. I’m sure you already know what the bug is: -->

そして実際、私のUbuntu Linuxシステムで、`gcc`、`clang`、`-Wall`を使うとそのように出力されます。
何がバグかもうおわかりでしょう:

```c
for (i = 0; i <= MAX; ++i)
               ^^
```

<!-- This is the classic “[fencepost problem](https://en.wikipedia.org/wiki/Off-by-one_error#Fencepost_error)”. It goes through the loop 11 times instead of 10. It should properly be: -->

これは古典的な「[植木算問題](https://ja.wikipedia.org/wiki/Off-by-one%E3%82%A8%E3%83%A9%E3%83%BC#%E6%A4%8D%E6%9C%A8%E7%AE%97%E3%82%A8%E3%83%A9%E3%83%BC)」です。
ループは10回ではなく11回まわります。
正しくはこうすべきです:

```c
for (i = 0; i < MAX; ++i)
```

<!-- Note that even with the bug, the program still produced the correct result! On my system, anyway. So I wouldn’t have detected it. On the customer’s system, well, then it mysteriously fails, and I have a remote [heisenbug](https://en.wikipedia.org/wiki/Heisenbug). I’m already tensing up anticipating the time and money this is going to cost me. -->

これはバグですが、それでもこのプログラムは正しい結果を返します!
とにかく、私のシステムにおいては。
したがって私はこのバグに気づきません。
顧客のシステムでは、えっと、なぜか動作せず、私はリモート
[ハイゼンバグ](https://ja.wikipedia.org/wiki/%E7%89%B9%E7%95%B0%E3%81%AA%E3%83%90%E3%82%B0#%E3%83%8F%E3%82%A4%E3%82%BC%E3%83%B3%E3%83%90%E3%82%B0_(Heisenbugs))
を抱えてしまいました。
どれほどの時間とお金が消えてゆくのか今からすでに心配です。

<!-- It’s such a rotten bug that over the years I have reprogrammed my brain to: -->

こういう不愉快なバグが何年もかけて私の脳を以下のようにリプログラミングしました:

<!-- 1.  Never, ever use “inclusive” upper bounds.
2.  Never, ever use `<=` in a for loop condition. -->

1. 絶対に「閉じた」終端を使わない
2. 絶対にループ条件に`<=`を使わない

<!-- By making myself a better programmer, I have solved the problem! Or have I? Not really. Let’s look again at the code from the perspective of the poor schlub who has to review it. He wants to ensure that `sumArray()` is correct. He must: -->

私は優れたプログラマになることで問題を解決しました!
でも、本当にそうでしょうか?
実は問題は解決していません。
コードをもう一度、それをレビューしなければならないかわいそうな無能の視点から見てみましょう。
`sumArray()`に問題がないことを確かめるために、彼は以下のことをしなければなりません:

<!-- 1.  Look at all callers of `sumArray()` to see what kind of pointer is being passed.
2.  Verify that the pointer actually is pointing to an array.
3.  Verify that the size of the array is indeed `MAX`. -->

1. どのようなポインタが渡されるか、`sumArray()`のすべての呼び出し元を見に行く
2. ポインタが配列を指していることを確認する
3. 配列の大きさが実際に`MAX`であるか確認する

<!-- While this is trivial for the trivial program as presented here, it doesn’t really scale as the program complexity goes up. The more callers there are of `sumArray`, and the more indirect the data structures being passed to `sumArray`, the harder it is to do what amounts to data flow analysis in your head to ensure it is correct. -->

これは今回のような小さなプログラムでは小さな作業ですが、実際のプログラムの複雑さの増加に対してはスケールしません。
`sumArray`の呼び出し元が増え、`sumArray`に渡されるデータ構造が間接的になるに従って、この関数が正しいと証明するために頭の中で解析しなくてはならないデータフローは複雑になってゆきます。

<!-- Even if you get it right, are you sure? What about when someone else checks in a change, is it still right? Do you want to do that analysis again? I’m sure you have better things to do. This is a tooling problem. -->

それでもあなたはレビューをやり遂げました、しかし本当に?
誰か他の人が変更をチェックしたとき、それもちゃんと行われるでしょうか?
自分でチェックし直したくなりませんか?
もっといい方法があります。
これはツールの問題です。

<!-- The fundamental issue with this particular problem is that a C array decays to a pointer when it’s an argument to a function, even if the function parameter is declared to be an array. There’s just no escaping it. There’s no detecting it, either. (At least gcc and clang don’t detect it, maybe someone has developed an analyzer that does). -->

この問題の根本的な点は、Cにおいて関数のパラメータがたとえ配列として宣言されていても、配列が関数にポインタとして渡されることにあります。
回避することも、検出することもできません(少なくともgccとclangは検出しませんが、誰かがアナライザを開発しているかもしれません)。

<!-- And so the tool to fix it is [D as a BetterC](https://dlang.org/blog/2017/08/23/d-as-a-better-c/) compiler. D has the notion of a _dynamic array_, which is simply a fat pointer, that is laid out like: -->

そしてこれを解決するのは[BetterC](https://dlang.org/blog/2017/08/23/d-as-a-better-c/)コンパイラとしてのD言語です。
Dは**動的配列**の概念を持ち、それはこんな感じのfatポインタです:

```c
struct DynamicArray {
    T* ptr;
    size_t length;
}
```

<!-- It’s declared like: -->

以下のように宣言し:

```d
int[] a;
```

<!-- and with that the example becomes: -->

例はこのようになります:

<!-- ```d
import core.stdc.stdio;

extern (C):   // use C ABI for declarations

enum MAX = 10;

int sumArray(int[] a) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += a[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(values));
    return 0;
}
``` -->

```d
import core.stdc.stdio;

extern (C):   // 宣言のためにCのABIを使用

enum MAX = 10;

int sumArray(int[] a) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += a[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(values));
    return 0;
}
```

<!-- Compiling: -->

コンパイルし:

```
dmd -betterC sum.d
```

<!-- Running: -->

実行します:

```
./sum
Assertion failure: 'array overflow' on line 11 in file 'sum.d'
```

<!-- That’s more like it. Replacing the <= with < we get: -->

いいですね、<= を < に置き換えるとこうなります:

```
./sum
sum = 449
```

<!-- What’s happening is the dynamic array `a` is carrying its dimension along with it and the compiler inserts an array bounds overflow check. -->

動的配列 `a` はその範囲を持ち、コンパイラは配列の境界オーバーフローチェックを挿入します。

<!-- But wait, there’s more. -->

それだけではありません。

<!-- There’s that pesky `MAX` thing. Since the `a` is carrying its dimension, that can be used instead: -->

迷惑な`MAX`が残っています。
`a`はその範囲を持っているため、代わりにそれを使えます:

```d
for (int i = 0; i < a.length; ++i)
```

<!-- This is such a common idiom, D has special syntax for it: -->

これは一般的なイディオムであり、Dにはそのための特殊な構文があります:

```d
foreach (value; a)
    sum += value;
```

<!-- The whole function `sumArray()` now looks like: -->

関数`sumArray()`全体は以下のようになります:

```d
int sumArray(int[] a) {
    int sum = 0;
    foreach (value; a)
        sum += value;
    return sum;
}
```

<!-- and now `sumArray()` can be reviewed in isolation from the rest of the program. You can get more done in less time with more reliability, and so can justify getting a pay raise. Or at least you won’t have to come in on weekends on an emergency call to fix the bug. -->

そして`sumArray()`はそれが置かれたプログラムと分離してレビューできるようになりました。
あなたはより短時間で、より信頼性の高い方法で、より多くのことができるようになり、給料を上げてもらう理由ができました。
給料は上がらなくても、少なくとも週末にバグ修正の緊急連絡が入ることはなくなったわけです。

<!-- “Objection!” you say. “Passing `a` to `sumArray()` requires two pushes to the stack, and passing `p` is only one. You said no compromise, but I’m losing speed here.” -->

「異議あり!」あなたはこう言います。
「`a`を`sumArray()`に渡すためにはスタックをのプッシュが2回必要です。
しかし`p`の場合1度で済みます。
あなたは妥協は必要ないと言いましたが、私はここでスピードを失っています。」

<!-- Indeed you are, in cases where `MAX` is a manifest constant, and not itself passed to the function, as in: -->

確かに、`MAX`がマニフェスト定数であり、関数に渡されない場合、以下のようになります:

```c
int sumArray(int *p, size_t length);
```

<!-- But let’s get back to “no compromise.” D allows parameters to be passed by reference,   -->
<!-- and that includes arrays of fixed length. So: -->

しかし「妥協」はさせません。
Dはパラメータを参照として渡すことができ、配列の長さを固定することができます。
つまり以下のようになります:

```d
int sumArray(ref int[MAX] a) {
    int sum = 0;
    foreach (value; a)
        sum += value;
    return sum;
}
```

<!-- What happens here is that `a`, being a `ref` parameter, is at runtime a mere pointer. It is typed, though, to be a pointer to an array of `MAX` elements, and so the accesses can be array bounds checked. You don’t need to go checking the callers, as the compiler’s type system will verify that, indeed, correctly sized arrays are being passed. -->

`ref`パラメータになった`a`は実行時にただのポインタになります。
これには`MAX`要素の配列という型があり、アクセスには配列境界チェックがなされます。
コンパイラの型システムがやってくれるため呼び出し元をチェックする必要はなく、正しいサイズの配列が渡されます。

<!-- “Objection!” you say. “D supports pointers. Can’t I just write it the original way? What’s to stop that from happening? I thought you said this was a mechanical guarantee!” -->

「異議あり!」また言います。
「Dはポインタをサポートしています。
そのまま書くことはできないのですか?
理由はなんですか?
機械的保証が行われたというふうに聞こえましたが?」

<!-- Yes, you can write the code as: -->

そうです、以下のようにコードを書くこともできます:

<!-- ```d
import core.stdc.stdio;

extern (C):   // use C ABI for declarations

enum MAX = 10;

int sumArray(int* p) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += p[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(&values[0]));
    return 0;
}
``` -->

```d
import core.stdc.stdio;

extern (C):   // 宣言のためにCのABIを使用

enum MAX = 10;

int sumArray(int* p) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += p[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(&values[0]));
    return 0;
}
```

<!-- It will compile without complaint, and the awful bug will still be there. Though this time I get: -->

恐ろしいバグが潜んでいるのにもかかわらず、これは何事もなくコンパイルされます。
そして以下のような結果が得られます:

```
sum = 39479
```

<!-- which looks suspicious, but it could have just as easily printed 449 and I’d be none the wiser. -->

不思議ですね、しかし誰も賢くならずとも簡単に449を印刷するようにできます。

<!-- How can this be guaranteed not to happen? By adding the attribute `@safe` to the code: -->

どのようにこれを阻止するのでしょうか?
コードに`@safe`属性をつけるのです:

<!-- ```d
import core.stdc.stdio;

extern (C):   // use C ABI for declarations

enum MAX = 10;

@safe int sumArray(int* p) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += p[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(&values[0]));
    return 0;
}
``` -->


```d
import core.stdc.stdio;

extern (C):   // 宣言のためCのABIを使用

enum MAX = 10;

@safe int sumArray(int* p) {
    int sum = 0;
    for (int i = 0; i <= MAX; ++i)
        sum += p[i];
    return sum;
}

int main() {
    __gshared int[MAX] values = [ 7,10,58,62,93,100,8,17,77,17 ];
    printf("sum = %d\n", sumArray(&values[0]));
    return 0;
}
```

<!-- Compiling it gives: -->

コンパイルすると以下のようになります:

```
sum.d(10): Error: safe function 'sum.sumArray' cannot index pointer 'p'
```

<!-- Granted, a code review will need to include a grep to ensure `@safe` is being used, but that’s about it. -->

`@safe`が使われていることを確かめるためのgrepをコードレビューに含めなくてはなりませんが、それだけです。

<!-- In summary, this bug is vanquished by preventing an array from decaying to a pointer when passed as an argument, and is vanquished forever by disallowing indirections after arithmetic is performed on a pointer. I’m sure a rare few of you have never been blasted by buffer overflow errors. Stay tuned for the next installment in this series. Maybe your moat got breached by the next bug! (Or maybe your tool doesn’t even have a moat.) -->

まとめると、このバグは引数として渡される際に配列がポインタになってしまうことを防ぐことで倒すことができ、ポインタへの間接的な演算を禁止することで永遠に亡きものにできます。
バッファオーバーフローエラーによって台無しにされることはほぼなくなるでしょう。
シリーズの次回作にご期待ください。
次のバグが堀を超えてくるかもしれませんよ!(もしくは、あなたのツールには堀がないかもしれません。)