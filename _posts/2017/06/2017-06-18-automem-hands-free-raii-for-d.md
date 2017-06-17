---
layout: post
title: "automem: DのハンズフリーRAII"
date: 2017-06-18 6:00:00 +0900
tags: dlang tech translation
---

この記事は、

[automem: Hands-Free RAII for D – The D Blog](http://dlang.org/blog/2017/04/28/automem-hands-free-raii-for-d/)

を自分用に翻訳したものを
[許可を得て](http://dlang.org/blog/2017/04/28/automem-hands-free-raii-for-d/#comment-1616)
公開するものである。
誤字や誤訳などを見つけたら今すぐ
[Pull request](https://github.com/{{ site.github.repository_nwo }}/edit/{{ site.branch }}/{{ page.path }})だ!

---

Atila NevesはC++とDの両方をプロとして使っていました。
[unit-threaded](https://github.com/atilaneves/unit-threaded)、
[cerealed](https://github.com/atilaneves/cerealed)、
[reggae](https://github.com/atilaneves/reggae)
のようなDのライブラリやツールに関わっています。

---

ガベージコレクトをする言語はフレーム問題に苦しむ傾向があり、Dもその例外ではありません。
マーク・アンド・スイープ・ガベージコレクタを取り入れることは簡単かつ便利な安全メモリ管理を実現しますが、
しかし、GCが一般的にパフォーマンスキラーであるという広まった認識、
たったそれだけのために多くの潜在的ユーザを遠ざけてしまいます。

私がC++からDに来た時、最初にこの言語について好きでなかったものの1つがGCでした。
私はその後その恐れがほとんど根拠のないものだと気づきましたが、実際には、
多くの人にとって、GCはその言語を避ける十分な理由になります。
そのユースケースが合理的かどうかには議論の余地があります(し、合理的な人々が反対するかも知れないものです)が、
認識の存在についてはそうではありません。

数年の間にDのコードをGCに依存せず書けるようにする多くの作業が行われました。
`@nogc`アノテーションはここで特に重要なもので、私はこれが十分に宣伝されていないと考えます。
`@nogc main`関数はプログラムが絶対にGCメモリをアロケートしないというコンパイル時の保証です。
その種の保証が必要なタイプのアプリケーションにおいて、これは非常に重要です。

しかしGCヒープからアロケーティングをしないなら、どこからメモリを得れば良いのでしょうか?
いまだ標準ライブラリのエクスペリメンタルパッケージにある
[`std.experimental.allocator`](https://dlang.org/phobos/std_experimental_allocator.html)
はGCが不適当だと考えられるところでのあらゆるメモリアロケーションのニーズを満たす必要があるアロケータを構成するためのビルディングブロックを提供します。
さらに良いことには、
[`IAllocator`](https://dlang.org/phobos/std_experimental_allocator.html#.IAllocator)
インターフェースによって、実行時に必要に応じてGCとカスタムアロケーション戦略の間をスイッチすることもできます。

私は最近`@nogc`保証を得るために`std.experimental.allocator`を使い、作業の間、
C++やRustを使っている時に比べスムースでない領域がありました。
メモリの破棄です。
C++やRustのように、DにはRAIIがあります。
3つ全てで通常、明示的なリソースの開放は悪いやり方とみなされます。
にもかかわらず、現状では、`std.experimental.allocator`
を使うならDの標準ライブラリを使用している間は手動でメモリの破棄をしなければなりません。
それはDでは[`scope(exit)`](https://dlang.org/spec/statement.html#ScopeGuardStatement)
により、例外をサポートする殆どの言語よりも簡単になりますが、RAIIのある言語ではそれはただの定型文です。
そして私のような優れた怠惰なプログラマーは、書く必要がなく、書くべきでないコードを書くことを嫌います。
開発の意欲が湧きました。

解決策のインスピレーションはC++から思いつきました。
C++11以来私は`std::unique_ptr`と`std::shared_ptr`を使うことで喜びに満たされており、
基本的にもう手動管理メモリについて心配することはなくなりました。
Dの標準ライブラリには[`std.typecons`](https://dlang.org/phobos/std_typecons.html)
に`Unique`や`RefCounted`がありますが、それらは`std.experimental.allocator`に先行し、
アロケーション戦略に「焼き付けられて」います。
我々のアロケーションケーキをもらって食べることはできないのでしょうか?

私が書いた、`std.experimental.allocator`と一体化したC++スタイルのスマートポインタを提供するライブラリ
[automem](https://github.com/atilaneves/automem)に入りましょう。
インスピレーションを得たスマートポインタとは異なるデザインが必要なのは明らかでした。
C++では、メモリは`new`でアロケートされ、`delete`で開放されるものと(両方共オーバーライド可能ですが)想定されました。
カスタムアロケータと明らかでないデフォルトのチョイスに、スマートポインタがそれ自身のメモリをアロケートするようにしました。
これによりあるアロケータでアロケートして、別のものでデアロケートできなくなるという利点が生まれます。

もうひとつのゴールは`std::unique_ptr`のような、`Unique`のゼロコスト抽象化の可能性を保つことです。
その意味でアロケータの型は明示的でなければなりません(デフォルトでは`IAllocator`です)。
状態のない値型ならば、スペースをとりません。
実際、シングルトンならば(`Allocator.instance`が存在するかどうかを調べることによりコンパイル時に決まる)、
それはコンストラクタに渡す必要がありません!
モダンなDのコードにあるような、[イントロスペクションによる設計](http://dconf.org/2015/talks/alexandrescu.html)
はここで費用を払っています。
サンプルコードです:

```d
struct Point {
    int x;
    int y;
}

{
    // 含むオブジェクトを初期化するための引数を渡す必要がありますが、
    // Mallocatorはインスタンスのみを返す
    // シングルトンのため(Mallocator.instance)
    // アロケータインスタンスではありません
    
    auto u1 = Unique!(Point, Mallocator)(2, 3);
    assert(*u1 == Point(2, 3));
    assert(u1.y == 3); // 格納しているオブジェクトを転送

    // auto u2 = u1; // コンパイルされません。moveのみができます
    typeof(u1) u2;
    move(u1, u2);
    assert(cast(bool)u1 == false); // u1はこの時点で空です
}
// ブロック内で作られたPoint構造体のメモリは開放されました
```

`RefCounted`はautomemにおけるC++の`std::shared_ptr`です。
しかし`std::shared_ptr`とは違い、
常にはアトミックな参照カウントのインクリメント/デクリメントをしません。
それがいつ必要かをDの型システムを活用して判断するためです。
ペイロードが`shared`の場合、参照カウントはアトミックなものに切り替えられます。
そうでないなら、それは他のスレッドに送ることはできず、パフォーマンスペナルティを負う必要はありません。
C++は常にアトミックなインクリメント/デクリメントをしています。
Rustはこれを2つの型、`Arc`と`Rc`で回避します。
Dでは型システムが一義化します。
イントロスペクションによる設計によるもうひとつの利益は、Dでのみ可能なものです。
サンプルコードです:

```d
{
    auto s1 = RefCounted!(Point, Mallocator)(4, 5);
    assert(*s1 == Point(4, 5));
    assert(s1.x == 4);
    {
        auto s2 = s1; // コピーできます、アトミックでない参照カウントです
    } // 参照カウントはここで1になります

} // 参照カウントはここで0になり、メモリは開放されます
```

アロケータの型は通常明示的であることを考えると、`@nogc`アロケータを使う時(殆どの場合)、
automemを使ったコードはそれ自身が`@nogc`になり、RAIIはメモリ管理の責任を負います。
これはそれが必要なアプリケーションのGCアロケーションがないというコンパイル時保証を意味します。

automemと`std.experimental.allocator`の管理がDのGCフレーム問題を解決すると期待しています。
Dで、C++やRustのように、手動メモリ管理なしで`@nogc`のコードを書くことができるはずです。