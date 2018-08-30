---
date: 2017-07-09
title: "Dにおけるコンパイル時ソート【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "DフォーラムでのRussel Winderの挑発的な問い、「きっとDならもっとうまくやる」が私の目にとまりました。
 「本当に何もする必要はありません。ただ標準ライブラリのソートを使ってください」 彼はそう言って、コードを続けました"
---

この記事は、

[Compile-Time Sort in D – The D Blog](http://dlang.org/blog/2017/06/05/compile-time-sort-in-d/)

を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

最近Björn Fahllerが
[C++17でコンパイル時クイックソート](http://playfulprogramming.blogspot.kr/2017/06/constexpr-quicksort-in-c17.html)
を実装する方法のブログ記事を書きました。
簡潔ではないものの、前回のイテレーションよりも効率化されているコードを書くための、
進化したC++機能セットを用いた巧妙なデモンストレーションです。
彼はこう結論づけています。
「実用性には欠けますが、なかなかクールじゃないですか?」

コンパイルの間にコードを評価することにはかなりの実用性があります。
そこから現れる可能性から、(たくさんの)クールさが発生します。
Björnの例から出発して、この記事はD言語におけるコンパイル時評価の興味深い側面をいくらか提示します。

Andrei Alexandrescuが"No Story"スタイルの答えで素早く解決した、
DフォーラムでのRussel Winderの挑発的な問い、「きっとDならもっとうまくやる」が私の目にとまりました。
「本当に何もする必要はありません。ただ標準ライブラリのソートを使ってください」
彼はそう言って、コードを続けました:

#### 例1

```d
void main() {
    import std.algorithm, std.stdio;
    enum a = [ 3, 1, 2, 4, 0 ];
    static b = sort(a);
    writeln(b); // [0, 1, 2, 3, 4]
}
```

Dに疎い人にはわからないかもしれませんが、`sort`の呼び出しは確かにコンパイル時に起きています。
なぜなのか見ていきましょう。

### コンパイル時コードは実行時コード

これは本当のことです。
Dでコンパイル時に実行されるようにするために超えなければならないハードルはありません。
あらゆるコンパイル時関数は実行時関数でもあり、両方のコンテキストで実行できます。
しかし、すべての実行時関数にCTFE(Compile-Time Function Evaluation、
コンパイル時関数評価)の資格があるわけではありません。

CTFEの資格を持つ根本的必要条件は関数がポータブルであること、副作用のないこと、
インラインアセンブリを含まないこと、ソースコードが利用可能であることです。
そのうえで、関数がコンパイル時と実行時どちらで評価されるかを決めるのはそれが呼ばれたコンテキストです。

[CTFEドキュメント](http://dlang.org/spec/function.html#interpretation)には以下の文があります:

> 処理をコンパイル時に走らせるには、関数呼び出しが、 コンパイル時に必ず評価されねばならない文脈に現れるようにします[^1]

[^1]:翻訳を[関数 - プログラミング言語 D (日本語訳)](http://www.kmonos.net/alang/d/function.html)から引用

続けてそれが真となるいくつかの例を列挙しています。
このように要約されるものです:
コンパイル時に実行しなければならないコンテキストにある関数がコンパイル時に実行できるときは、そうします。
実行できない時(たとえばCTFE要件に合わない時)は、コンパイラはエラーを送出します。

### コンパイル時ソートを分解する

もう一度**例1**を見てみましょう。

```d
void main() {
    import std.algorithm, std.stdio;
    enum a = [ 3, 1, 2, 4, 0 ];
    static b = sort(a);
    writeln(b);
}
```

CTFEマジックを可能にするのに関係がある点は3行目と4行目です。
3行目の`enum`は[記号定数](http://dlang.org/spec/enum.html#manifest_constants)です。
これはDの他の定数(`immutable`や`const`とマークされたもの)とは異なり、コンパイル時にのみ存在します。
アドレスを取ろうとするあらゆる試みはエラーになります。
それが全く使われなかった時、値はコード中に現れません。

`enum`が使われた時、コンパイラは本質的に、シンボル名の場所にその値をペーストします。

```d
enum xinit = 10;
int x = xinit;

immutable yinit = 11;
int y = yinit;
```

ここで、`x`はリテラル`10`に初期化されます。
`int x = 10`と書くのと全く同じです。
定数`yinit`は`int`リテラルで初期化されますが、コンパイル時にわかっているのにもかかわらず、
`y`はリテラル自身ではなく`yinit`の値で初期化されます。
`yinit`は実行時にも存在しますが、`xinit`は存在しません。

**例1**で、静的変数`b`は記号定数で初期化されます。
[CTFEドキュメント](http://dlang.org/spec/function.html#interpretation)に、
これが関数がコンパイル時に評価されなければならないシナリオの例としてリストされています。
関数内で宣言された静的変数はコンパイル時の値のみで初期化できます。
これをコンパイルしようとした時:

#### 例2

```d
void main() {
    int x = 10;
    static y = x;
}
```

このような結果になります:

```
Error: variable x cannot be read at compile time
```

静的変数の初期化に関数呼び出しを使うことは関数がコンパイル時に実行されなければならないことを意味し、
従って、その資格があることを意味します。

パズルの2つのピース、記号定数と静的初期化子が、
なぜ**例1**の`sort`の呼び出しがコンパイル時にメタプログラミングをこねくり回すこと無しに発生するかを説明します。
実際、この例は1行短くすることができます:

#### 例3

```d
void main() {
    import std.algorithm, std.stdio;
    static b = sort([ 3, 1, 2, 4, 0 ]);
    writeln(b);
}
```

そして実行時に`b`をとどめておく必要がない場合、静的変数の代わりに`enum`にできます:

#### 例4

```d
void main() {
    import std.algorithm, std.stdio;
    enum b = sort([ 3, 1, 2, 4, 0 ]);
    writeln(b);
}
```

両方のケースで、`sort`への呼び出しはコンパイル時に発生しますが、結果の扱いが異なります。
これを考慮すると、`enum`の性質上、この変更は以下に相当するものを生成します:
`writeln([ 0, 1, 2, 3, 4 ])`
`writeln`の呼び出しは実行時に発生するため、配列リテラルは
[GCアロケーション](http://dlang.org/blog/2017/03/20/dont-fear-the-reaper/)
(訳注:[翻訳版]({% include relative %}{% post_url 2017/04/2017-04-16-dont-fear-the-reaper %}))
を引き起こす可能性があります(可能性はありますが、時には最適化されます)。
静的初期化子により、変数を初期化するために関数呼び出しの結果がコンパイル時に使われるため、実行時アロケーションはありません。

`sort`が直接`int[]`型の値を返さないことは注目に値します。
[ドキュメント](https://dlang.org/library/std/algorithm/sorting/sort.html)
を覗き見ると返されるものが
[`SortedRange`](https://dlang.org/library/std/range/sorted_range.html)
であることがわかるでしょう。
特に我々の使用法では、それは`SortedRange!(int[], "a < b")`です。
この型はDの配列のように
[ランダムアクセスレンジ](https://dlang.org/library/std/range/primitives/is_random_access_range.html)
の関数を公開していますが、それに加えてソートされたレンジでのみ動く関数を提供し、
それらの命令を活用することができます
(例: [trisect](https://dlang.org/library/std/range/sorted_range.trisect.html))。
配列はまだこの中にあり、強化されたAPIでラップされています。

### CTFEかCTFEでないか

上で私はすべてのコンパイル時関数は実行時関数でもあると述べました。
時々、関数から2つを区別できれば便利です。
Dは`__ctfe`変数でそのようなことを可能にします。
こちらは私の本「[Learning D](http://amzn.to/1IlQkZX)」から持ってきた例です。

#### 例5

```d
string genDebugMsg(string msg) {
    if(__ctfe)
        return "CTFE_" ~ msg;
    else
        return "DBG_" ~ msg;
}

pragma(msg, genDebugMsg("Running at compile-time."));
void main() {
    writeln(genDebugMsg("Running at runtime."));
}
```

[`msg`プラグマ](https://dlang.org/spec/pragma.html#msg)はコンパイル時に`stderr`にメッセージをプリントします。
`genDebugMsg`がこの2番めの引数として呼ばれた時、関数の中の変数`__ctfe`は`true`になります。
関数が`writeln`の引数として呼ばれた時、それは実行時のコンテキストで発生し、`__ctfe`は`false`になります。

特に注意すべきこととして、`__ctfe`はコンパイル時の値**ではありません。**
それがコンパイル時に実行されているか、実行時に実行されているか知っている関数はありません。
前者では、それはコンパイラの内部で実行されるインタプリタによって評価されます。
それでも、関数内のコンパイル時と実行時の値を区別することができます。
しかし、関数の結果は、それがコンパイル時に実行された場合コンパイル時の値になります。

### 複雑なコンパイル時保証

標準ライブラリのすぐに使える関数を使わないものを見てみましょう。

数年前、Andreiは[The D Programming Language](http://amzn.to/1ZTDmqH)を出版しました。
CTFEを説明するセクションで、彼は仮言的な
[線形合同法](https://en.wikipedia.org/wiki/Linear_congruential_generator)
に渡されるパラメータを検証するのに使える3つの関数を実装しました。
アイデアは、パラメータが彼が本の中で示した(コメンタリのために買ってください -- その価値があるものです)、
可能ななかで最大の周期を生成する、一連の基準を満たしている必要があるというものです。
ここでは、ユニットテストを除いてあります:

#### 例6

```d
// ユークリッドの互除法の実装
ulong gcd(ulong a, ulong b) { 
    while (b) {
        auto t = b; b = a % b; a = t;
    }
    return a; 
}

ulong primeFactorsOnly(ulong n) {
    ulong accum = 1;
    ulong iter = 2;
    for (; n >= iter * iter; iter += 2 - (iter == 2)) {
        if (n % iter) continue;
        accum *= iter;
        do n /= iter; while (n % iter == 0);
    }
    return accum * n;
}

bool properLinearCongruentialParameters(ulong m, ulong a, ulong c) { 
    // 境界チェック
    if (m == 0 || a == 0 || a >= m || c == 0 || c >= m) return false; 
    // cとmは互いに素
    if (gcd(c, m) != 1) return false;
    // a - 1 はmのすべての素因数で割り切れる
    if ((a - 1) % primeFactorsOnly(m)) return false;
    // a - 1 が4の倍数の時、mも4の倍数。
    if ((a - 1) % 4 == 0 && m % 4) return false;
    // すべてのテストを通過
    return true;
}
```

このコードのキーポイントは以前私がこの記事中で作ったものと同じものを作ることを意図しています:
`properLinearCongruentialParameters`はコンパイル時のコンテキストと実行時のコンテキスト両方で使える関数です。
それを動作させるために特殊な構文が要求されることはなく、2つの異なるバージョンを作る必要はありません。

渡されたRNGパラメータをテンプレート引数としてテンプレート化された構造体として線形合同法を実装したい?
パラメータを検証するために`properLinearCongruentialParameters`を使ってください。
引数を実行時にとるバージョンを実装したい?
`properLinearCongruentialParameters`はそれも対象です。
コンパイル時と実行時両方で使えるRNGを実装したい?
もうわかるでしょう?

完全性の確認のため、ここに両方のコンテキストでパラメータを検証する例を示します。

#### 例7

```d
void main() {
    enum ulong m = 1UL << 32, a = 1664525, c = 1013904223;
    static ctVal = properLinearCongruentialParameters(m, a, c);
    writeln(properLinearCongruentialParameters(m, a, c));
}
```

注意深く見たならば、`ctVal`がコンパイル時に初期化されなければならず、
したがって関数呼び出しにおいてCTFEが強制されることがわかるでしょう。
そして`writeln`への引数としての同じ関数呼び出しは実行時に発生します。
あなたが自分で同じようなことをすることもできます。

### 結論

Dにおけるコンパイル時関数評価は便利で簡単です。
[テンプレート](https://dlang.org/spec/template.html)
(テンプレートパラメータと制約に特に便利です)、
[文字列Mixin](http://dlang.org/spec/statement.html#MixinStatement)、
[import式](http://dlang.org/spec/expression.html#ImportExpression)
のような他の言語機能と組み合わせて、それがなければ極めて複雑になったかもしれない、
多くの言語ではプリプロセッサなしにはできないこともあるコードを単純化できます。
ボーナスとして、Stefan Kochが現在Dフロントエンドをより便利にするための
[より性能の高いCTFEエンジン](https://dlang.org/blog/2017/04/10/the-new-ctfe-engine/)
(訳注:[翻訳版]({% include relative %}{% post_url /2017/04/2017-04-13-the-new-ctfe-engine %}))
を開発しています。
さらなるニュースをお楽しみに。

*この記事をレビューした複数のDコミュニティのメンバーに感謝します。*