---
date: 2017-07-15
title: "オウン・ウェイ - GCを避けたアロケーション (Part1: スタック)【翻訳】"
tags:
- dlang
- tech
- translation
- dlang_gc_series
- d_blog
---

この記事は、

[Go Your Own Way (Part One: The Stack) – The D Blog](http://dlang.org/blog/2017/07/07/go-your-own-way-part-one-the-stack/)[^1]

[^1]: おそらく[フリートウッド・マック](https://ja.wikipedia.org/wiki/%E3%83%95%E3%83%AA%E3%83%BC%E3%83%88%E3%82%A6%E3%83%83%E3%83%89%E3%83%BB%E3%83%9E%E3%83%83%E3%82%AF)
    の同名の曲が題の元ネタと思われる

を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/06/16/life-in-the-fast-lane/#comment-1631)
公開するものである。

誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.github.source.branch }}/{{ page.path }})だ!

---

これは[GCシリーズ](https://dlang.org/blog/category/gc/)
(訳注: [翻訳版](/tags/#dlang_gc_series))の3番めの投稿です。
[最初の投稿](https://dlang.org/blog/2017/03/20/dont-fear-the-reaper/)
(訳注: [翻訳版](/2017/04/2017-04-16-dont-fear-the-reaper))で、
私はDのガベージコレクタとそれを必要とする言語機能を紹介し、
それを効率的に使うシンプルな戦略に触れました。
[2番めの投稿](https://dlang.org/blog/2017/06/16/life-in-the-fast-lane/)
(訳注: [翻訳版](/2017/06/2017-06-26-life-in-the-fast-lane))では、
言語機能とライブラリによって提供される、コードベースの特定の部分でGCを無効にしたり禁止したりするツールや、
そのような努力の助けになるコンパイラの使い方を紹介し、
また最初からGCを含むようDプログラムを書き、その影響を軽減するためのシンプルな戦略を利用し、
プロファイリングがそれを正当化する結果を示した時にはじめてGCを避けるよう調整したり、
その使い方を深く最適化することを推奨しました。

ガベージコレクションが`GC.disable`によって切られたり`@nogc`関数アノテーションによて防がれた時でも、
メモリはどこからかアロケートする必要があります。
GCを完全に含む時であっても、GCヒープアロケーションのサイズと回数を減らすのは望ましいことです。
つまりスタックか、非GCヒープからアロケーティングをするということです。
この投稿では前者に注目します。
非GCヒープアロケーションはシリーズの次の投稿でカバーします。

### スタックアロケーション

Dにおける最もシンプルなアロケーション戦略はCのそれと同じものです:
ヒープを避け、可能な限りスタックを使う。
ローカル配列が必要でそのサイズがコンパイル時にわかっている場合は、動的配列よりも静的配列を使ってください。
値型でありデフォルトではスタックからアロケートされる構造体は、可能であれば、
参照型であり通常はヒープからアロケートされるクラスなどよりも好ましいものです。
ここでDのコンパイル時言語機能はそれがなければできなかった可能性を与えてくれます。

### 静的配列

Dの静的配列の宣言にはコンパイル時にわかる長さが必要です。

```d
// OK
int[10] nums;

// Error: variable x cannot be read at compile time
int x = 10;
int[x] err;
```

動的配列とは違い、静的配列はGCヒープからのアロケーションなしに配列リテラルで初期化可能です。
その長さはぴったり合っていなければならず、そうでなければコンパイラはエラーを送出します。

```d
@nogc void main() {
    int[3] nums = [1, 2, 3];
}
```

静的配列はスライスをパラメータにとる関数に渡される時に自動的にスライスされ、
動的配列と交換可能です。

```d
void printNums(int[] nums) {
    import std.stdio : writeln;
    writeln(nums);
}

void main() {
    int[]  dnums = [0, 1, 2];
    int[3] snums = [0, 1, 2];
    printNums(dnums);
    printNums(snums);
}
```

`-vgc`でコンパイルするとプログラム中の潜在的GCアロケーションがわかり、
なくせるところはなくす、これは非常に簡単なことです。
以下のようなシチュエーションを注意深く見てください:

```d
int[] foo() {
    auto nums = [0, 1, 2];

    // numsでなにかしらをする...

    return nums;
}
```

この例の`nums`を静的配列に変換するのは間違いでしょう。
このケースでreturn文はスタックからアロケートされた配列のスライスを返す可能性があり、それはプログラミングエラーです。
幸い、このようなことをするとコンパイルエラーが生成されます。

一方で、returnが条件つきである場合、関数が呼び出されるたびに毎回、ではなく、
絶対に必要なときのみ配列をヒープアロケートすることが望ましいかもしれません。
その場合、静的配列をローカルに宣言して、returnで動的コピーをすることができます。
`.dup`プロパティを入力しましょう:

```d
int[] foo() {
    int[3] nums = [0, 1, 2];
    
    // Let x = numsでの何かしらの作業の結果
    bool condtion = x;

    if(condition) return nums.dup;
    else return [];
}
```

この関数はGCを`.dup`で使いますが、する必要があるときのみアロケートをし、そうでない時はアロケーションを避けます。
`[]`はこのケースで`null`と等価で、`.length`が`0`で`.ptr`が`null`のスライス(または動的配列)です。

### 構造体とクラス

Dでは構造体のインスタンスはデフォルトでスタックにアロケートされますが、それが望ましい時はヒープにアロケートできます。
スタックにアロケートされた構造体はデストラクトが保証されており(have deterministic destruction)、
デストラクタは囲まれているスコープから出ると即座に呼ばれます。

```d
struct Foo {
    int x;
    ~this() {
        import std.stdio;
        writefln("#%s says bye!", x);
    }
}
void main() {
    Foo f1 = Foo(1);
    Foo f2 = Foo(2);
    Foo f3 = Foo(3);
}
```

予想通り、これはこう出力します:

```
#3 says bye!
#2 says bye!
#1 says bye!
```

参照型であるクラスはほぼ常にヒープからアロケートされます。
ふつうそれは`new`によるGCヒープなのですが、カスタムアロケータによる非GCヒープにもできます。
しかしクラスがスタックからアロケートできないというルールはありません。
標準ライブラリのテンプレート
[std.typecons.scoped](https://dlang.org/phobos/std_typecons.html#.scoped)
で簡単にそれを行うことができます。

```d
class Foo {
    int x;

    this(int x) { 
        this.x = x; 
    }
    
    ~this() {
        import std.stdio;
        writefln("#%s says bye!", x);
    }
}
void main() {
    import std.typecons : scoped;
    auto f1 = scoped!Foo(1);
    auto f2 = scoped!Foo(2);
    auto f3 = scoped!Foo(3);
}
```

機能的に、これは上の`struct`の例と全く同じです;
同じ結果が出力されます。
デストラクトの保証は、デストラクタがGCコレクションの外側で呼ばれるようにする
`core.object.destroy`関数によってなされています。

現時点では`scoped`も`destroy`も`@nogc`関数内で使えないことに注意してください。
GCを避けるために関数にアノテートする必要はないので、これは必ずしも問題にはなりませんが、
すべてを`@nogc`コールツリーにすべてを入れようとするときには頭痛の種になりえます。
将来の投稿で、`@nogc`を使用する時に現れる設計上の問題とその回避法を見ていきます。

一般的に、Dでカスタム型を実装するときには、
それを使用する意図によって`struct`と`class`のどちらを選ぶか決めます。
POD[^2]型は明らかに`struct`が候補になるのに対して、

[^2]: Plain old data structure - Cの構造体と互換性をもつデータ構造

GUIシステム等の、継承ヒエラルキーやランタイムインタフェースが極めて役に立つ場面では、
`class`がより適した選択になります。
これらの明らかなケース以外にも、そのトピックのために別の記事が書けるようなたくさんの考慮事項があります。
我々の目的には、型を`struct`と`class`どちらで実装するかは必ずしもインスタンスがスタックにアロケートされうるかどうかでは決まらない、
ということだけ覚えておいてください。

### alloca

DがDruntimeで標準Cライブラリを使えるようにしていることを考えれば、
`alloca`もスタックアロケーションの選択肢です。
これは特にローカルGCアロケーションを避けたり取り除いたりしたいけれど、
配列のサイズが実行時にしかわからない時に候補になります。
下記の例はスタックから動的配列を実行時のサイズでアロケートします。

```d
import core.stdc.stdlib : alloca;

void main() {
    size_t size = 10;
    void* mem = alloca(size);

    // メモリブロックをスライス
    int[] arr = cast(int[])mem[0 .. size];
}
```

Cで`alloca`を使う時と同じ注意事項がここでも言えます:
スタックを爆発させないよう気をつけてください。
そして静的配列と同様に、`arr`のスライスを返り値にしないでください。
かわりに`arr.dup`を返すようにしてください。

### シンプルな例

`Queue`データ型の実装を考えてみましょう。
Dにおける慣用的な実装は内部に含む型でテンプレート化された構造体になります。
Javaでは、コレクションの使用はインタフェースが重く、
インスタンスを実装型ではなくインタフェース型で宣言することが推奨されています。
Dの構造体はインタフェースを実装できませんが、多くのケースでは
[イントロスペクションによる設計](https://youtu.be/es6U7WAlKpQ)(DbI)
によってインタフェースのプログラムに使えます。
これによってインタフェース型の必要なしに、
コンパイル時イントロスペクションによって保証された、
構造体、クラス、
そして[統一関数呼び出し構文](http://www.drdobbs.com/cpp/uniform-function-call-syntax/232700394)
(UFCS)によって、自由な関数でさえも動く(関数がスコープ内にある場合)、
一般的なインタフェースのプログラミングを可能にします。

`Queue`の実装のバックの格納場所としてDの配列は明らかな選択肢です。
その上、キューが一定のサイズに限られるなら、
バックの格納場所を静的配列にできます。
すでにそれがテンプレート化された型の場合、追加のデフォルト値つきの
[テンプレート値パラメータ](http://dlang.org/spec/template.html#TemplateValueParameter)
を、配列を静的にすべきか否か、
静的にするならどれくらいのスペースが必要かをコンパイル時に決めるために簡単に追加できます。

```d
// デフォルトのサイズである0はバックの格納場所に
// 動的配列を使うことを意味します;非ゼロは静的配列を表します。
struct Queue(T, size_t Size = 0) 
{
    // この定数はbool値であると推論されます。publicにすることによって、
    // このモジュールの外部のDbIテンプレートはキューが成長しうるかどうか
    // 判断できます。
    enum isFixedSize = Size > 0;

    void enqueue(T item) 
    {
        static if(isFixedSize) {
            assert(_itemCount < _items.length);
        }
        else {
            ensureCapacity();
        }
        push(item);
    }

    T dequeue() {
        assert(_itemCount != 0);
        static if(isFixedSize) {
            return pop();
        }
        else {
            auto ret = pop();
            ensurePacked();
            return ret;
        }
    }

    // 成長できる配列でのみ利用できます
    static if(!isFixedSize) {
        void reserve(size_t capacity) { /* 新しいアイテムのためのスペースをアロケートする */ }
    }

private:   
    static if(isFixedSize) {
        T[Size] _items;     
    }
    else T[] _items;
    size_t _head, _tail;
    size_t _itemCount;

    void push(T item) { 
        /* アイテムを追加し、_headと_tailの更新をします */
        static if(isFixedSize) { ... }
        else { ... }
    }

    T pop() { 
        /* アイテムを削除し、_headと_tailの更新をします */ 
        static if(isFixedSize) { ... }
        else { ... }
    }

    // これらは成長できる配列でのみ利用できます
    static if(!isFixedSize) {
        void ensureCapacity() { /* 必要に応じてメモリをアロケートします */ }
        void ensurePacked() { /* 必要に応じて配列を縮小します */}
    }
}
```

これによって、クライアントはインスタンスをこのように宣言できます:

```d
Queue!Foo qUnbounded;
Queue!(Foo, 128) qBounded;
```

`qBounded`はヒープアロケーションを必要としません。
`qUnbounded`で何が起こるかは実装によります。
さらに、インスタンスのサイズが固定かそうでないか、
コンパイル時イントロスペクションを使ってテストできます。
`isFixedSize`定数はその役に立つでしょう。
クライアントはかわりに組み込みの`__traits(hasMember, T, "reserve")`
や標準ライブラリの関数`std.traits.hasMember!T("reserve")`
をコンパイル時構築などに使うこともできます
([__traits](https://dlang.org/spec/traits.html)と
[std.traits](https://dlang.org/phobos/std_traits.html)
はDbIに最適で、同じ機能を提供するなら後者がより好ましいです)が、
その型の中の定数を含むほうが便利です。

```d
void doSomethingWithQueueInterface(T)(T queue)
{
    static if(T.isFixedSize) { ... }
    else { ... }
}
```

### 結論

これがGCヒープからのアロケーションを避けるための、
Dにおけるスタックアロケーションの選択肢のかいつまんだ概要です。
可能な時にこれらを使うことはGCアロケーションのサイズと回数を最小化する簡単な方法であり、
ガベージコレクションによるパフォーマンスへの潜在的悪影響を軽減する先を見越した戦略です。

このシリーズの次の投稿では非GCヒープアロケーションを可能にするいくつかの選択肢をカバーします。
