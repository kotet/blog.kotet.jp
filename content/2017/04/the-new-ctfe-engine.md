---
date: 2017-04-13
aliases:
- /2017/04/12/the-new-ctfe-engine.html
- /2017/04/13/the-new-ctfe-engine.html
title: "新・CTFEエンジンについて【翻訳】"
tags:
- dlang
- tech
- translation
- d_blog
excerpt: "9ヶ月前、私はNewCTFEと呼ばれる、Dコンパイラフロントエンドのコンパイル時関数実行(CTFE) 機能の再実装のプロジェクトで作業をしていました。 CTFEはDの革新的機能とされています。"
---

この記事は

[The New CTFE Engine – The D Blog](https://dlang.org/blog/2017/04/10/the-new-ctfe-engine/)

の翻訳である。
ぼーっと読んでたら途中でわけがわからなくなってきたので、しっかり翻訳しようと思って書いた。
その後[翻訳の公開の許可を取り、](https://dlang.org/blog/2017/04/10/the-new-ctfe-engine/#comment-1333)
[無事承諾していただけた](https://dlang.org/blog/2017/04/10/the-new-ctfe-engine/#comment-1335)
のでここに公開する。
翻訳できていないところや訳の怪しいところがあるので、気になったら今すぐ
[Pull request](https://github.com/kotet/blog.kotet.jp)
だ!

---


Stefan KochはDのネイティヴな[sqlite](https://www.sqlite.org/)リーダー、[sqlite-d](https://github.com/UplinkCoder/sqlite-d)
のメンテナーであり、[SDC](https://github.com/SDC-Developers/SDC)(the Stupid D Compiler)や
[vibe.d](http://vibed.org/)のようなプロジェクトに貢献していました。
彼はDの現在のCTFE実装の10%のパフォーマンス改善のかつての責任者でもあり、現在はこの投稿の対象である新CTFEエンジンを書いています。

---


9ヶ月前、私はNewCTFEと呼ばれる、Dコンパイラフロントエンドの[コンパイル時関数実行(CTFE)](https://dlang.org/spec/function.html#interpretation)
機能の再実装のプロジェクトで作業をしていました。
CTFEはDの革新的機能とされています。

その名前が示すように、CTFEは関数が実装されているソースコードのコンパイル時にコンパイラが関数を実行できるようにします。
関数のすべての引数がコンパイル時に利用可能で、関数が純粋(副作用を持たない)な限り、関数はCTFEの資格を持ちます。
コンパイラは関数呼び出しをその結果で置き換えます。

これは言語の切り離せない部分のため、コンパイル時定数の行くところどこでも純粋関数を実行できます。
シンプルな例を[標準ライブラリ](https://dlang.org/phobos/index.html)モジュール、
[`std.uri`](https://dlang.org/phobos/std_uri.html)に見ることができ、ここでCTFEはルックアップテーブルを計算するために使われています。
[このようなものです](https://github.com/dlang/Phobos/blob/master/std/uri.d):

```d
private immutable ubyte[128] uri_flags = // indexed by character
({

    ubyte[128] uflags;

    // Compile time initialize
    uflags['#'] |= URI_Hash;

    foreach (c; 'A' .. 'Z' + 1)
    {
        uflags[c] |= URI_Alpha;
        uflags[c + 0x20] |= URI_Alpha; // lowercase letters

    }

    foreach (c; '0' .. '9' + 1) uflags[c] |= URI_Digit;

    foreach (c; ";/?:@&=+$,") uflags[c] |= URI_Reserved;

    foreach (c; "-_.!~*'()") uflags[c] |= URI_Mark;

    return uflags;

})();
```

テーブルにマジックバリューを入れる代わりに、シンプルで意味のある[関数リテラル](https://dlang.org/spec/expression.html#FunctionLiteral)
が使われています。
これは不透明な静的配列より理解とデバッグが簡単です。
`({`で関数リテラルが始まり、`})`で閉じられます。
最後の`()`は`uri_flags`がリテラルの結果になるようコンパイラにリテラルを即座に呼びださせます。

関数は必要な時のみコンパイル時に実行されます。
上のスニペットの`uri_flags`はモジュールスコープで宣言されています。
このマナーの中でモジュールスコープ変数が初期化される時、初期化子はコンパイル時に利用可能でなければなりません。
このケースで、初期化子は関数リテラルのため、CTFEの実行が試みられます。
この独特なリテラルは引数を持たず純粋のため、試みは成功します。

CTFEのより詳細な議論については、D wikiのH. S. Teohの
[このアーティクル](https://wiki.dlang.org/User:Quickfur/Compile-time_vs._compile-time)を見てください。

もちろん、より複雑な問題にも同じテクニックが適用できます。
たとえば、[`std.regex`](https://dlang.org/phobos/std_regex.html)は正規表現にスペシャライズされたオートマトンをCTFEを使いコンパイル時にビルドできます。
しかし、`std.regex`が非自明なパターンのCTFEで使われるとすぐに、コンパイル時間が非常に長くなることがあります(Dではコンパイルに1秒以上かかるすべてがブロートウェアです:))。
結局、パターンがより複雑になれば、コンパイラはメモリ不足になりすべてのシステムをダウンさせるかもしれません。

これに対する責任は現在のCTFEインタプリタのアーキテクチャのものにできます。
それはASTインタプリタ、ASTをトラバースする間それを解釈するものです。
解釈された式の結果を表現するために、DMDのASTノードクラスを使います。
これは遭遇するすべての式が1つ以上のASTノードをアロケートすることを意味します。
最奥ループ内で、インタプリタはたやすく`100_000_000`以上のノードを生成し、RAMの数ギガバイトを食いつぶします。
それはメモリを非常に速く消耗させます。

[Issue 12844](https://issues.dlang.org/show_bug.cgi?id=12844)は`std.regex`がRAMを16ギガバイト以上消費することについてのものです。
ひとつのパターンで、です。
単純な`0`から`10_000_000`までのwhileループをCTFEで実行するとメモリ不足に陥る[Issue 6498](https://issues.dlang.org/show_bug.cgi?id=6498)もあります。

単純にノードを解放することは問題を解決しません。
どのノードがフリーかはわからず、ガベージコレクタを有効にするとコンパイラ全体が非常に遅くなります。
幸いにも式に遭遇するたびに毎回アロケートしないという別のアプローチがあります。
それは関数をバーチャルISA(命令セットアーキテクチャ)にコンパイルすることを含みます。
バイトコードとしても知られるこのISAは、そのISAに向けて専門化されたインタプリタに渡されます
(このケースで、バーチャルISAの中でホストのISAと同じことがおこり、それをJIT(Just in Time)インタプリタと呼びます)。

NewCTFEプロジェクトはそのようなバイトコードインタプリタを扱うものです。
実際にインタプリタ(バーチャルCPU/ISA用CPUエミュレータ)を書くことは割とシンプルです。
しかし、コードをバーチャルISAにコンパイルすることはリアルISAにコンパイルすることと同じ仕事量です
(が、バーチャルISAは個別のニーズのために拡張できるという追加のベネフィットがあります。しかしそれにより後でJITをするのに困難が伴います)。
それが最初のシンプルなサンプルが新CTFEエンジン上で走るだけで1ヶ月を要した理由で、ちょっと複雑なものは開発9ヶ月後まで動かなかった理由です。
ポストの最後で、今までの仕事のおおよそのタイムラインを見ることができます。

私は[DConf 2017](http://dconf.org/2017/index.html)で[プレゼンテーション](http://dconf.org/2017/talks/koch.html)を行い、
エンジンの実装の経験について話し、技術的詳細、特に私が作ったトレードオフとデザインチョイスに関することを説明します。
現在の見積もりでは1.0のゴールはその時には間に合いませんが、完了するまでコーディングを続けます。

私の進捗を追うことに興味がある人は[Dフォーラム](http://forum.dlang.org/thread/btqjnieachntljobzrho@forum.dlang.org)
で私のステータスアップデートをフォローできます。
将来のある時点で、私は実装の技術的詳細について別のアーティクルを書きます。
その間、下のリストがNewCTFEの実装にどれだけの作業をしているか明らかにしてくれるでしょう🙂

 - 5月 9日 2016  
    CTFE改善の計画のアナウンスメント。
 - 5月 27日 2016  
    新エンジンの作業が始まったことのアナウンスメント。
 - 5月 28日 2016  
    シンプルなメモリ管理の変更が失敗。
 - 6月 3rd 2016  
    バイトコードインタプリタの実装の決定。
 - 6月 30日 2016  
    単純な整数演算からなる最初のコード([Issue 6498](https://issues.dlang.org/show_bug.cgi?id=6498)より)が走る。
 - 7月 14日 2016  
    ASCII文字列インデクシングが動作。
 - 7月 15日 2016  
    初期の`struct`のサポート
 - 7月から8月の間のどこか  
    はじめてswitchが動作。
 - 8月 17日 2016  
    特殊なケース`if(__ctfe)` と `if(!__ctfe)`のサポート
 - 8月から9月の間のどこか  
    三項式がサポートされる
 - 9月 08日 2016  
    Phobosのユニットテストが初めて通る。
 - 9月 25日 2016  
    文字列と三項式を返すことのサポート。
 - 10月 16日 2016  
    最初のLLVMバックエンドのほとんど動作するバージョン。
 - 10月 30日 2016  
    最初の関数呼び出しのサポートの試みの失敗。
 - 11月 01日  
    DRuntimeのユニットテストが初めて通る。
 - 11月 10日 2016  
    文字列連結の実装の試みの失敗
 - 11月 14日 2016  
    `length`プロパティへの代入などによる配列の拡張がサポートされる。
 - 11月 14日 2016  
    配列インデックスへの代入がサポートされる。
 - 11月 18日 2016  
    関数パラメータとしての配列サポート。
 - 11月 19日 2016  
    パフォーマンスフィックス。
 - 11月 20日 2016  
    壊れた `while(true)` / `for (;;)` ループを修正; 今はぬけ出すことができます🙂
 - 11月 25日 2016  
    `goto`と`switch`のハンドリングを修正。
 - 11月 29日 2016  
    `continue`と`break`のハンドリングを修正。
 - 11月 30日 2016  
    `assert`の最初のサポート
 - 12月 02日 2016  
    `void`で初期化された値の救済(未定義動作に繋がる恐れがあるためです)。
 - 12月 03日 2016  
    `struct`リテラルを返すことのサポート。
 - 12月 05日 2016  
    バイトコードジェネレータのパフォーマンスフィックス。
 - 12月 07日 2016  
    `for`ステートメントの`continue`と`break`を修正(`continue`はインクリメントステップをスキップしてはいけません。)
 - 12月 08日 2016  
    変数入り配列リテラルがサポートされました: [1, n, 3]
 - 12月 08日 2016  
    `switch`ステートメントのバグを修正。
 - 12月 10日 2016  
    厄介な評価順序のバグを修正。
 - 12月 13日 2016  
    関数呼び出しに進捗あり。
 - 12月 14日 2016  
    switch内の文字列の最初のサポート。
 - 12月 15日 2016  
    静的配列の代入がサポートされました。
 - 12月 17日 2016  
    `goto`ステートメントの修正(ラベルへの最後の`goto`を無視していました:))。
 - 12月 17日 2016  
    De-macrofied string-equals.
 - 12月 20日 2016  
    ヌルポインタへのデリファレンスを防ぐチェックを実装(yes… that one was oh so fun)。
 - 12月 22日 2016  
    ポインタの最初のサポート。
 - 12月 25日 2016  
    `static immutable`変数にアクセスできます(yes the result is recomputed … who cares)。
 - 1月 02日 2017  
    最初の関数呼び出しがサポートされました!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 - 1月 17日 2017  
    再帰的関数呼び出しは動作します🙂
 - 1月 23日 2017  
    **interpret3.d**のユニットテストが通りました。
 - 1月 24日 2017  
    64bitでグリーンです!
 - 1月 25日 2017  
    (ブラックリスト式ですが)すべてのプラットフォームでグリーンです!!!!!
 - 1月 26日 2017  
    特殊なケース`cast(void*) size_t.max`を修正(これは通常のポインタのサポートを経由することはできず、デリファレンスに有効ななにかを持っていると仮定します)。
 - 1月 26日 2017  
    メンバ関数呼び出しがサポートされました!
 - 1月 31日 2017  
    `switch`ハンドリングのバグを修正。
 - 2月 03日 2017  
    最初の関数ポインタサポート。
 - 2月の間 2017  
    [Issue #17220](https://issues.dlang.org/show_bug.cgi?id=17220)についての骨折り損。
 - 3月 11日 2017  
    スライスの最初のサポート。
 - 3月 15日 2017  
    文字列スライスが動作します。
 - 3月 18日 2017  
    スライス式内の`$`がサポートされました。
 - 3月 19日 2017  
    結合演算子`(c = a ~ b)`が動作します。
 - 3月 22日 2017  
    `switch`のフォールスルーバグを修正。