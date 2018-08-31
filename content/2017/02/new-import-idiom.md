---
date: 2017-02-15
title: "Lazyな新しいimportについての議論"
tags:
- dlang
- tech
---
最近は英語のD言語情報を読めるようになってきて楽しい。
特にGoogle翻訳の改善により、自分の貧弱な英語力でも大半はスラスラとストレスのない速度で読めるようになった。  
そういうわけで読んだものを自分の中で解釈し、自分の言葉でゆるく日本語にした記事を書いている。
技術関係だから記事でcontributionを伸ばしても何も後ろめたくないのがいいところだ。

というわけで今回はこちらを読んだ。一部コードをこちらから引用している。

[A New Import Idiom` - D Programming Language Discussion Forum](https://forum.dlang.org/thread/iprikkrpishsudltbdpy@forum.dlang.org)

[A New Import Idiom – The D Blog](https://dlang.org/blog/2017/02/13/a-new-import-idiom/)

## はじめに
現在importは2つの範囲でできる。
module-level importとlocal importである。

```d
// A module-level import
import std.datetime;
  
void fun(SysTime time)
{
  import std.stdio; // A local import
  ...
}
```

しかしたとえば関数`fun`の引数`time`に使われている型`SysTime`はmodule-level importされていないといけない。
ちなみにスコープ文を使って下のようなことができるんじゃないかと思ってやってみたがやはりできなかった。

```d
{
    import std.datetime;
    void fun(SysTime time)
    {
        import std.stdio;
        writeln("hello");
    }
}
```
```
source/app.d(1,1): Error: declaration expected, not '{'
source/app.d(8,1): Error: unrecognized declaration
```

そこで
[言語へのInline importsの導入が提案された](https://github.com/dlang/DIPs/blob/master/DIPs/DIP1005.md#inline-imports)
。
今回読んだものはInline importを今までのものから新しい構文を追加せずにできる形を見つけたという話である。

## A New Import Idiom
つまりこういうことである。

```d
template from(string moduleName)
{
  mixin("import from = " ~ moduleName ~ ";");
}

void fun(from!"std.datetime".SysTime time)
{
  import std.stdio;
  ...
}
```

要素を一つ一つ解説する。

### 1 `!`オペレータ
`!`オペレータでテンプレートをインスタンス化するとき、引数がひとつだけならカッコを省略できる。
つまり`from!"std.datetime"`は`from!("std.datetime")`と同じである。
読みやすい。

### 2 改名import
[改名import](https://dlang.org/spec/module.html#renamed_imports)。
importするモジュールにローカルな名前を与えて、 その名前で修飾したアクセスを強制することができる。

```d
void printSomething(string s) {
    import io = std.stdio;
    io.writeln(s);         // この形でのみアクセスできる
    writeln(s);            // Error
    std.stdio.writeln(s);  // Error
}
```

### 3 Eponymous Templates
[Eponymous Templates](https://dlang.org/spec/template.html#implicit_template_properties)
といって、テンプレートの名前と同じ名前のメンバだけがある場合、省略できる。
これによってたとえばテンプレートが

```d
template from()
{
    import kotet = std.datetime;
}
```

となっている場合
`from!().kotet.SysTime`
と書かなければいけないところが、改名importで`kotet`というところをテンプレート名と同じ`from`にすることで
`from!().SysTime`
でよくなる。

ここまでのものを組み合わせるとこのようなコードが書ける。

```d
template dt() {
    import dt = std.datetime; 
}
void fun(dt!().SysTime time) {}
```

更にこれを一般化する。

### 4 `~`オペレータ
`~`オペレータで文字列を結合できる。

### 5 文字列mixin
文字列mixinでコンパイル時にコードを生成できる。
この場合は必要なモジュールを`from`として改名importするコードを作る。
たとえば`moduleName`が`std.datetime`なら
`mixin("import from = " ~ moduleName ~ ";");`
で
`import from = std.datetime;`
というコードが生成される。
つよい。

すべてを組み合わせると前述の

```d
template from(string moduleName)
{
  mixin("import from = " ~ moduleName ~ ";");
}
```

こちらのコードができる。
インスタンス化すると、モジュールの中のシンボルが`from`の修飾付きでテンプレートのインスタンスのスコープ内にロードされる。

## 話し合い

これを使うことでバイナリサイズが元の41%に減少し、コンパイル時間は30%にまで早くなったと
[書かれているが](https://dlang.org/blog/2017/02/13/a-new-import-idiom/)
、それはどうやら
[勘違いだったらしい](https://forum.dlang.org/post/cbtjmdxtzyoajhngmlzj@forum.dlang.org)
。

これを標準ライブラリに追加することについては反対する人がいる。
おもな理由としては

 > [PhobosをC++ STLのような恐ろしいシロモノにするのはやめよう](https://forum.dlang.org/post/o8028m$10o5$1@digitalmars.com)

 > [それが引き起こす混乱に見合ったメリットがあるとは思えない](https://forum.dlang.org/post/mailman.463.1487115250.31550.digitalmars-d-announce@puremagic.com)

と言った感じである。
一方

 > [DのテンプレートはC++のそれよりはるかに読みやすく直感的だと信じている](https://forum.dlang.org/post/zmufkhhoscvopdqbpomj@forum.dlang.org)

 という反論がある。
